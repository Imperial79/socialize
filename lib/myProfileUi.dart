import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socialize/resources/auth.dart';

import 'addStoryUi.dart';
import 'editProfileUi.dart';
import 'followersUi.dart';
import 'followingUi.dart';
import 'loginUi.dart';
import 'resources/colors.dart';
import 'resources/database.dart';
import 'resources/myWidgets.dart';
import 'resources/user_details.dart';

class ProfileUi extends StatefulWidget {
  const ProfileUi({Key? key}) : super(key: key);

  @override
  _ProfileUiState createState() => _ProfileUiState();
}

class _ProfileUiState extends State<ProfileUi> {
  final dbMethod = DatabaseMethods();
  Stream? followStream;
  Stream? postStream;
  List followersList = [];
  List followingList = [];
  QuerySnapshot<Map<String, dynamic>>? userData;
  QuerySnapshot<Map<String, dynamic>>? postData;
  String postCount = '0';

  @override
  void initState() {
    onPageLoad();
    super.initState();
  }

  onPageLoad() async {
    await DatabaseMethods()
        .getFollowersAndFollowing(UserDetails.uid)
        .then((value) {
      setState(() {
        followStream = value;
      });
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: UserDetails.uid)
        .get()
        .then((value) {
      setState(() {
        postData = value;
        postCount = postData!.docs.length.toString();
      });
    });
  }

  Widget PostList() {
    return FutureBuilder<dynamic>(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: UserDetails.uid)
          .where('postType', isEqualTo: 'image')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Shimmer(
            child: DummySmallPost(),
            gradient: LinearGradient(
              colors: [
                Colors.grey,
                Colors.white,
              ],
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

  Widget FollowerCount() {
    //TODO
    return StreamBuilder<dynamic>(
      stream: followStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          followersList = snapshot.data['followers'];
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
          return Text(
            '0',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
              fontSize: 20,
            ),
          );
        }
      },
    );
  }

  Widget FollowingCount() {
    return StreamBuilder<dynamic>(
      stream: followStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          followingList = snapshot.data['following'];
          print(followersList);
          return Text(
            snapshot.data['following'].length.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
              fontSize: 20,
            ),
          );
        } else {
          print(snapshot.data);
          return Text(
            '0',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
              fontSize: 20,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = isDarkMode ? Colors.grey.shade900 : Colors.white;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarColor: isDarkMode ? Colors.grey.shade900 : Colors.transparent,
        systemNavigationBarColor:
            isDarkMode ? Colors.grey.shade900 : Colors.white,
      ),
    );
    return UserDetails.uid == ''
        ? Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          )
        : SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
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
                            UserDetails.bio,
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
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Color(0xfff2f7fa),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xfff2f7fa),
                            width: 3.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: UserDetails.userProfilePic == ''
                              ? CircularProgressIndicator(
                                  color: primaryColor,
                                )
                              : CachedNetworkImage(
                                  imageUrl: UserDetails.userProfilePic,
                                  fit: BoxFit.cover,
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
                              UserDetails.userName,
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.blueGrey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              UserDetails.userEmail,
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.blue.shade200
                                    : Colors.blue.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          PageRouteTransition.push(context, UpdateProfileUi())
                              .then((value) {
                            setState(() {});
                          });
                        },
                        elevation: 0,
                        highlightElevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                            color: Colors.blueGrey.shade200,
                          ),
                        ),
                        color: Colors.transparent,
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 16,
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
                StreamBuilder<dynamic>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(UserDetails.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      DocumentSnapshot ds = snapshot.data;
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 2,
                              child: StreamBuilder<dynamic>(
                                stream: FirebaseFirestore.instance
                                    .collection('posts')
                                    .where('uid', isEqualTo: UserDetails.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    print('no data');
                                    return Column(
                                      children: [
                                        Text(
                                          '0',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.blueGrey.shade700,
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
                                    );
                                  }
                                  return Column(
                                    children: [
                                      Text(
                                        // postCount,
                                        snapshot.data.docs.length.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.blueGrey.shade700,
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
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 0.5,
                              color: Colors.blueGrey.shade300,
                            ),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  PageRouteTransition.push(
                                      context, FollowingUi());
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      Text(
                                        ds['following'].length.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.blueGrey.shade700,
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
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 0.5,
                              color: Colors.blueGrey.shade300,
                            ),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  PageRouteTransition.push(
                                      context, FollowersUi());
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      // FollowerCount(),
                                      Text(
                                        ds['followers'].length.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.blueGrey.shade700,
                                          fontSize: 20,
                                        ),
                                      ),
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
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    );
                  },
                ),
                Divider(
                  color: Colors.blueGrey.shade300,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 20,
                    top: 10,
                    left: 15,
                    right: 15,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      PageRouteTransition.push(context, AddStoryUi());
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: primaryColor,
                    elevation: 0,
                    highlightElevation: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Add to Story',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 20,
                    left: 15,
                    right: 15,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      AuthMethods().logoutuser();
                      PageRouteTransition.effect = TransitionEffect.leftToRight;
                      PageRouteTransition.pushReplacement(context, LoginUi());
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: Colors.red,
                    elevation: 0,
                    highlightElevation: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: PostList(),
                ),
              ],
            ),
          );
  }
}
