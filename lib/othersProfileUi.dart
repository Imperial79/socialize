import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socialize/resources/database.dart';
import 'package:socialize/resources/user_details.dart';

import 'resources/colors.dart';

class OthersProfileUi extends StatefulWidget {
  final snap;
  OthersProfileUi({
    required this.snap,
  });

  @override
  _OthersProfileUiState createState() => _OthersProfileUiState();
}

class _OthersProfileUiState extends State<OthersProfileUi> {
  // QuerySnapshot<Map<String, dynamic>>? thisUser;
  Stream? followStream;
  List followersList = [];
  List? followingList;
  String postCount = '0';
  QuerySnapshot<Map<String, dynamic>>? postData;

  @override
  void initState() {
    onPageLoad();
    super.initState();
  }

  onPageLoad() async {
    //TODO
    await DatabaseMethods()
        .getFollowersAndFollowing(widget.snap['uid'])
        .then((value) {
      setState(() {
        followStream = value;
      });
    });
    await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.snap['uid'])
        .get()
        .then((value) {
      setState(() {
        postData = value;
        postCount = postData!.docs.length.toString();
      });
    });
  }

  onFollowBtnClick() async {
    // await DatabaseMethods()
    //     .getUserDataFromDatabase(widget.snap['email'])
    //     .then((value) {
    //   setState(() {
    //     thisUser = value;
    //   });
    // });
    createPersonalChatRoom(
      friendDp: widget.snap['profilePhoto'],
      friendName: widget.snap['username'],
      friendsUid: widget.snap['uid'],
    );
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\#_#$a";
    } else {
      return "$a\#_#$b";
    }
  }

  createPersonalChatRoom({
    required String friendsUid,
    required String friendName,
    required String friendDp,
  }) {
    if (friendsUid != UserDetails.userName) {
      String chatRoomId = getChatRoomId(friendsUid, UserDetails.uid);
      List<String> users = [friendsUid, UserDetails.uid];

      Map<String, dynamic> userDetails = {
        UserDetails.uid: {
          "uid": UserDetails.uid,
          "name": UserDetails.userName,
          "dp": UserDetails.userProfilePic,
        },
        friendsUid: {
          "uid": friendsUid,
          "name": friendName,
          "dp": friendDp,
        },
      };

      Map<String, dynamic> chatRoomMap = {
        "type": 'Personal',
        "users": users,
        "chatRoomId": chatRoomId,
        "userDetails": userDetails,
        'lastMessage': '',
      };

      DatabaseMethods().createChatRoom(chatRoomId, chatRoomMap);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1, milliseconds: 300),
          content: Text(
            "Cannot message yourself",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Widget FollowerCount() {
    return StreamBuilder<dynamic>(
      stream: followStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          followersList = snapshot.data['followers'];
          followingList = snapshot.data['following'];
          print(followersList);
          return Text(
            snapshot.data['followers'].length.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
              fontSize: 20,
            ),
          );
        } else {
          print(snapshot.data);
          return Text('0');
        }
      },
    );
  }

  Widget PostList() {
    return FutureBuilder<dynamic>(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.snap['uid'])
          .where('postImage', isNotEqualTo: '')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        }
        if (snapshot.data.docs.length != 0) {
          return GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 5,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 5,
            shrinkWrap: true,
            children: List.generate(
              snapshot.data.docs.length,
              (index) {
                print(index);
                DocumentSnapshot ds = snapshot.data.docs[index];
                return ds['postImage'] == ''
                    ? Container()
                    : CachedNetworkImage(
                        imageUrl: ds['postImage'],
                        fit: BoxFit.cover,
                      );
              },
            ),
          );
        }
        return Text(
          'No Posts',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade200,
            fontSize: 20,
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
        systemNavigationBarColor: Colors.white,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            'lib/assets/image/back.svg',
            color: primaryColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<dynamic>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: widget.snap['uid'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.docs.length == 0) {
                return Text('No Data');
              }
              DocumentSnapshot ds = snapshot.data.docs[0];
              return Column(
                children: [
                  Stack(
                    // alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        // color: Colors.black,
                        width: double.infinity,
                        height: 205,
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://media.istockphoto.com/photos/mountain-landscape-picture-id517188688?k=20&m=517188688&s=612x612&w=0&h=i38qBm2P-6V4vZVEaMy_TaTEaoCMkYhvLCysE7yJQ5Q=',
                          fit: BoxFit.cover,
                          imageBuilder: (context, imageProvider) => Container(
                            alignment: Alignment.topLeft,
                            height: 160,
                            padding: EdgeInsets.all(20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            child: Text(
                              ds['bio'],
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 125,
                        left: 20,
                        child: ds['profilePhoto'] == ''
                            ? CircularProgressIndicator()
                            : CachedNetworkImage(
                                imageUrl: ds['profilePhoto'],
                                imageBuilder: (context, image) => Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: primaryScaffoldColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: ds['active'] == '1'
                                          ? Colors.green
                                          : Colors.red,
                                      width: 4,
                                    ),
                                    image: DecorationImage(
                                      image: image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ds['username'],
                                style: TextStyle(
                                  color: Colors.blueGrey.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                ds['email'],
                                style: TextStyle(
                                  color: Colors.blueGrey.shade300,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            onFollowBtnClick();
                            if (followersList.contains(UserDetails.uid)) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(ds['uid'])
                                  .update({
                                'followers':
                                    FieldValue.arrayRemove([UserDetails.uid]),
                              });

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(UserDetails.uid)
                                  .update({
                                'following': FieldValue.arrayRemove([ds['uid']])
                              });
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(ds['uid'])
                                  .update({
                                'followers':
                                    FieldValue.arrayUnion([UserDetails.uid]),
                              });

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(UserDetails.uid)
                                  .update({
                                'following': FieldValue.arrayUnion([ds['uid']])
                              });
                            }
                          },
                          elevation: 0,
                          highlightElevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: ds['followers'].contains(UserDetails.uid)
                                ? BorderSide(
                                    color: fadedTextColor,
                                  )
                                : BorderSide.none,
                          ),
                          color: ds['followers'].contains(UserDetails.uid)
                              ? Colors.transparent
                              : primaryColor,
                          // padding: EdgeInsets.all(14),
                          child: Text(
                            ds['followers'].contains(UserDetails.uid)
                                ? 'Following'
                                : 'Follow',
                            style: TextStyle(
                              fontSize: 16,
                              color: ds['followers'].contains(UserDetails.uid)
                                  ? primaryColor
                                  : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.grey.shade400,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(
                                postCount,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey.shade700,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Posts',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: IconLabelColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 20,
                          width: 0.5,
                          color: Colors.blueGrey.shade300,
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(
                                ds['following'].length.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey.shade700,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Following',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: IconLabelColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 20,
                          width: 0.5,
                          color: Colors.blueGrey.shade300,
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              FollowerCount(),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Followers',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: IconLabelColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.blueGrey.shade300,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: PostList(),
                  ),
                ],
              );
            }
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }
}
