import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socialize/resources/database.dart';
import 'package:socialize/resources/myWidgets.dart';
import 'package:socialize/resources/user_details.dart';
import 'package:socialize/storyUi.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as Path;

import 'addStoryUi.dart';
import 'feedCard.dart';
import 'resources/colors.dart';
import 'services/pickImage.dart';
import 'services/storage_methods.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({Key? key}) : super(key: key);

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  bool isLoading = false;
  String username = '';
  Uint8List? _file = null;
  File? videoFile;
  Stream? postStream;
  List followingUsers = [];
  final descriptionController = TextEditingController();
  final dbMethod = DatabaseMethods();
  QuerySnapshot<Map<String, dynamic>>? userData;
  DocumentSnapshot<Map<String, dynamic>>? users;
  UploadTask? task;
  File? docFile;
  Stream? storyStream;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool fetchingData = false;
  @override
  void initState() {
    getUserDetailsFromPreference();
    getFollowingUsersPosts();
    super.initState();
  }

  Future<void> getFollowingUsersPosts() async {
    return await dbMethod.getUsersIAmFollowing().then((value) {
      setState(() {
        users = value;
        followingUsers = users!.data()!['following'];
        followingUsers.add(FirebaseAuth.instance.currentUser!.uid);
        dbMethod.getPosts(followingUsers).then((value) {
          postStream = value;
        });
        dbMethod.getStory(followingUsers).then((value) {
          storyStream = value;
        });

        fetchingData = false;
      });
    });
  }

  Widget buildUploadStatus(UploadTask task) {
    // print('In Build Upload status');
    return StreamBuilder<TaskSnapshot>(
      stream: task.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final snap = snapshot.data;
          final progress = snap!.bytesTransferred / snap.totalBytes;
          final percentage = (progress * 100).toStringAsFixed(2);

          return percentage != '100.00'
              ? Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                    ),
                    Text(
                      percentage + ' %',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Container();
        } else {
          return Container();
        }
      },
    );
  }

  Future selectFile() async {
    _file = null;
    videoFile = null;
    setState(() {});
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'ppt'],
    );
    if (result == null) return;
    final path = result.files.single.path;
    setState(() {
      docFile = File(path!);
      // print('=======================');
      // print(file!.name);
    });
  }

  selectPhoto(BuildContext context) {
    docFile = null;
    videoFile = null;
    setState(() {});
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          height: MediaQuery.of(context).size.height * 0.25,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Image',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          Uint8List file = await pickImage(ImageSource.gallery);
                          setState(() {
                            _file = file;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: Color(0xFFFCE0EA),
                          radius: 30,
                          child: SvgPicture.asset(
                            'lib/assets/image/picture.svg',
                            color: Colors.pink.shade600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        'Gallery',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          Uint8List file = await pickImage(ImageSource.camera);
                          setState(() {
                            _file = file;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 220, 239, 255),
                          radius: 30,
                          child: SvgPicture.asset(
                            'lib/assets/image/camera.svg',
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future uploadDocFile() async {
    if (docFile == null) return;
    final docFileName = Path.basename(docFile!.path);
    final destination =
        'posts/' + UserDetails.uid + '/' + DateTime.now().toString();
    task = null;
    task = FirebaseApi.uploadFile(destination, docFile!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download Link for doc--- $urlDownload');

    dbMethod.uploadDocPost(
        urlDownload, descriptionController.text, docFileName, 'doc');
    setState(() {
      docFile = null;
      descriptionController.clear();
    });
  }

  pickVideo() async {
    _file = null;
    docFile = null;
    setState(() {});
    final result = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(minutes: 15, hours: 0),
    );
    if (result == null) return;
    final path = result.path;
    setState(() {
      videoFile = File(path);
    });
    if (videoFile != null) {
      _file = null;
      docFile = null;
      setState(() {});
      //================================================================================
      _controller = VideoPlayerController.file(File(videoFile!.path));
      _initializeVideoPlayerFuture = _controller.initialize();
      _controller.setLooping(true);
      _controller.setVolume(1.0);
      //================================================================================

      setState(() {});
    } else {
      print("No video selected");
    }
  }

  Future uploadVideoFile() async {
    if (videoFile == null) return;
    final docFileName = Path.basename(videoFile!.path);
    final destination =
        'posts/' + UserDetails.uid + '/' + DateTime.now().toString();
    task = FirebaseApi.uploadFile(destination, videoFile!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download Link for video--- $urlDownload');

    dbMethod.uploadDocPost(
        urlDownload, descriptionController.text, docFileName, 'video');
    setState(() {
      videoFile = null;
      descriptionController.clear();
    });
  }

  getUserDetailsFromPreference() async {
    fetchingData = true;
    setState(() {});
    PageRouteTransition.effect = TransitionEffect.rightToLeft;
    await dbMethod
        .getUserDataFromDatabase(FirebaseAuth.instance.currentUser!.uid)
        .then((value) {
      setState(() {
        userData = value;
      });
    });

    /// SETTINGS EVERY THING TO LOCAL VARAIBLES

    setState(() {
      UserDetails.userName = userData!.docs[0].data()['username'];
      UserDetails.uid = userData!.docs[0].data()['uid'];
      UserDetails.userProfilePic = userData!.docs[0].data()['profilePhoto'];
      UserDetails.followers = userData!.docs[0].data()['followers'];
      UserDetails.following = userData!.docs[0].data()['following'];
      UserDetails.bio = userData!.docs[0].data()['bio'];
      UserDetails.userEmail = userData!.docs[0].data()['email'];
      UserDetails.myTokenId = userData!.docs[0].data()['tokenId'];
      followingUsers.add(UserDetails.uid);
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(UserDetails.uid)
        .update({"active": "1"});
  }

  onPostButtonClick() async {
    if (_file != null || descriptionController.text.isNotEmpty) {
      //  WHEN POSTING BOTH TEXT WITH IMAGE
      if (_file != null) {
        try {
          setState(() {
            isLoading = true;
          });

          String res =
              await dbMethod.uploadPost(_file!, descriptionController.text);

          if (res == 'success') {
            setState(() {
              isLoading = false;
              _file = null;
              descriptionController.clear();
            });
            FocusScope.of(context).unfocus();
            showSnackBar(
              context,
              content: 'Posted!',
              color: Colors.green.shade800,
              svgIcon: 'success.svg',
            );
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print(e.toString());
          showSnackBar(
            context,
            content: 'Error Occurred',
            color: Colors.red.shade800,
            svgIcon: 'error.svg',
          );
        }
      }
      //  WHEN POSTING ONLY TEXT WITHOUT IMAGE
      else {
        try {
          setState(() {
            isLoading = true;
          });
          _file = null;
          String res =
              await dbMethod.uploadPost(_file, descriptionController.text);

          if (res == 'success') {
            setState(() {
              isLoading = false;
              descriptionController.clear();
            });

            //UNFOCUSSING THE TEXTFIELD
            FocusScope.of(context).unfocus();
            showSnackBar(
              context,
              content: 'Posted!',
              color: Colors.green.shade800,
              svgIcon: 'success.svg',
            );
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print(e.toString());
          showSnackBar(
            context,
            content: 'Error Occurred',
            color: Colors.red.shade800,
            svgIcon: 'error.svg',
          );
        }
      }
    }
  }

  Widget PostList() {
    return StreamBuilder<dynamic>(
      stream: postStream,
      builder: (context, snapshot) {
        return (snapshot.hasData) //TODO
            ? (snapshot.data.docs.length == 0)
                ? Container()
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      // print('yes');
                      return FeedCard(
                        snap: ds,
                      );
                    },
                  )
            : Shimmer(
                child: DummyPostCard(),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade300,
                  ],
                ),
              );
      },
    );
  }

  Widget BuildStoriesCard(final ds) {
    return GestureDetector(
      onTap: () {
        PageRouteTransition.effect = TransitionEffect.fade;
        PageRouteTransition.push(
            context,
            StoryUi(
              snap: ds,
            )).then((value) => setState(() {}));
      },
      child: Hero(
        tag: ds['postImage'],
        child: Container(
          height: 150,
          width: 100,
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade300,
          ),
          child: CachedNetworkImage(
            imageUrl: ds['postImage'],
            imageBuilder: (context, image) => Container(
              height: 150,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade300,
                image: DecorationImage(
                  image: image,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.05),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: ds['profileImage'],
                        imageBuilder: (context, image) => Container(
                          // margin: EdgeInsets.only(top: 10, left: 10),
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(10),
                            ),
                            image: DecorationImage(
                              image: image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget StoryList() {
    return StreamBuilder<dynamic>(
      stream: storyStream,
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data.docs.length == 0)
                ? Container()
                : Row(
                    children: List.generate(
                      snapshot.data.docs.length,
                      (index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];
                        return BuildStoriesCard(ds);
                      },
                    ),
                  )
            : Shimmer(
                child: DummyStoryCard(),
                gradient: LinearGradient(
                  colors: [
                    Colors.grey,
                    Colors.white,
                  ],
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'Socialize',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: primaryColor,
            fontSize: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Stack(
                      children: [
                        UserDetails.userProfilePic == ''
                            ? Container()
                            : CachedNetworkImage(
                                imageUrl:
                                    'https://media.istockphoto.com/photos/mountain-landscape-picture-id517188688?k=20&m=517188688&s=612x612&w=0&h=i38qBm2P-6V4vZVEaMy_TaTEaoCMkYhvLCysE7yJQ5Q=',
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 150,
                                  width: 100,
                                  margin: EdgeInsets.only(
                                    right: 10,
                                    left: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.4),
                                        BlendMode.colorBurn,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  PageRouteTransition.push(
                                                      context, AddStoryUi());
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'Add Story',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                    StoryList(),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              // margin: EdgeInsets.only(bottom: 0),
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextFormField(
                              controller: descriptionController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Post Something...',
                                hintStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey
                                      : Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        isLoading
                            ? Container()
                            : MaterialButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (_file != null ||
                                      (_file == null &&
                                          docFile == null &&
                                          videoFile == null &&
                                          descriptionController
                                              .text.isNotEmpty)) {
                                    onPostButtonClick();
                                  }
                                  if (docFile != null) {
                                    uploadDocFile();
                                  }
                                  if (videoFile != null) {
                                    uploadVideoFile();
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                color: primaryColor,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                                child: Text(
                                  'Post',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  isLoading
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: LinearProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : Container(),
                  _file == null
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: MemoryImage(_file!),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 65,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _file = null;
                                        });
                                      },
                                      child: CircleAvatar(
                                        radius: 17,
                                        backgroundColor: Colors.black,
                                        child: Icon(Icons.close),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                  docFile == null
                      ? Container()
                      : Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          margin: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.amber.withOpacity(0.3)
                                : Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: Colors.amber.shade600,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  Path.basename(docFile!.path),
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    docFile = null;
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                  videoFile == null
                      ? Container()
                      : Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                FutureBuilder(
                                  future: _initializeVideoPlayerFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Padding(
                                        padding: EdgeInsets.all(15),
                                        child: AspectRatio(
                                          aspectRatio:
                                              _controller.value.aspectRatio,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: VideoPlayer(_controller),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return CustomProgressIndicator();
                                    }
                                  },
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.black,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_controller.value.isPlaying) {
                                          _controller.pause();
                                        } else {
                                          _controller.play();
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      _controller.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.black,
                              child: IconButton(
                                onPressed: () {
                                  _controller.pause();
                                  videoFile = null;
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                  task != null && docFile != null
                      ? buildUploadStatus(task!)
                      : Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PostTypeButton(
                          context,
                          press: () {
                            selectPhoto(context);
                          },
                          btnColor: Colors.pink.withOpacity(0.15),
                          image: SvgPicture.asset(
                            'lib/assets/image/picture.svg',
                            color: Colors.pink,
                            height: 15,
                          ),
                          label: 'Photo',
                          labelColor: Colors.pink,
                        ),
                        PostTypeButton(
                          context,
                          press: () {
                            pickVideo();
                          },
                          btnColor: primaryAccentColor,
                          image: Icon(
                            Icons.videocam,
                            color: primaryColor,
                          ),
                          label: 'Video',
                          labelColor: primaryColor,
                        ),
                        PostTypeButton(
                          context,
                          press: () {
                            selectFile();
                          },
                          btnColor: Colors.amber.withOpacity(0.2),
                          image: Icon(
                            Icons.description,
                            color: Colors.amber.shade700,
                          ),
                          label: 'File',
                          labelColor: Colors.amber.shade800,
                        ),
                      ],
                    ),
                  ),
                  PostList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget PostTypeButton(BuildContext context,
      {final btnColor, labelColor, image, label, press}) {
    return MaterialButton(
      onPressed: press,
      elevation: 0,
      highlightElevation: 0,
      highlightColor: btnColor,
      color: btnColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          image,
          SizedBox(
            width: 10,
          ),
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
