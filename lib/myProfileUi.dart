import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                DocumentSnapshot ds = snapshot.data.docs[index];
                return ds['postImage'] == '' ? Container() : PhotoTile(ds);
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

  Widget PhotoTile(DocumentSnapshot<Object?> ds) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: ds['postImage'],
        fit: BoxFit.cover,
      ),
    );
  }

  Widget FollowerCount() {
    return StreamBuilder<dynamic>(
      stream: followStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          followersList = snapshot.data['followers'];

          return Text(
            snapshot.data['followers'].length.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
              fontSize: 20,
            ),
          );
        } else {
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

          return Text(
            snapshot.data['following'].length.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
              fontSize: 20,
            ),
          );
        } else {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            SvgPicture.asset(
              'lib/assets/image/profile_filled.svg',
              height: 20,
              color: primaryColor,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'PROFILE',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: primaryColor,
                letterSpacing: 10,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: UserDetails.uid == ''
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
                        padding: EdgeInsets.all(20),
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(),
                        child: Text(
                          UserDetails.bio,
                          style: TextStyle(
                            fontSize: UserDetails.bio.length > 100 ? 20 : 40,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        // CachedNetworkImage(
                        //   imageUrl:
                        //       'https://media.istockphoto.com/photos/mountain-landscape-picture-id517188688?k=20&m=517188688&s=612x612&w=0&h=i38qBm2P-6V4vZVEaMy_TaTEaoCMkYhvLCysE7yJQ5Q=',
                        //   fit: BoxFit.cover,
                        //   imageBuilder: (context, imageProvider) => Container(
                        //     alignment: Alignment.topLeft,
                        //     height: 160,
                        //     padding: EdgeInsets.all(20),
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //       image: DecorationImage(
                        //         image: imageProvider,
                        //         fit: BoxFit.cover,
                        //         colorFilter: ColorFilter.mode(
                        //           Colors.black.withOpacity(0.3),
                        //           BlendMode.darken,
                        //         ),
                        //       ),
                        //     ),
                        //     child: Text(
                        //       UserDetails.bio,
                        //       style: TextStyle(
                        //         fontSize: 20,
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //   ),
                        // ),
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
                        Expanded(
                          child: Container(
                            // width: MediaQuery.of(context).size.width * 0.55,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  UserDetails.userName,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '@' + UserDetails.userEmail,
                                  style: TextStyle(
                                    color: Colors.blue.shade500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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
                            borderRadius: BorderRadius.circular(7),
                          ),
                          color: primaryColor,
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: primaryAccentColor,
                                  ),
                                  child: StreamBuilder<dynamic>(
                                    stream: FirebaseFirestore.instance
                                        .collection('posts')
                                        .where('uid',
                                            isEqualTo: UserDetails.uid)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Column(
                                          children: [
                                            Text(
                                              '0',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: primaryColor,
                                                fontSize: 20,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'Posts',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: primaryColor,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return Column(
                                        children: [
                                          Text(
                                            snapshot.data.docs.length
                                                .toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                              fontSize: 20,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Posts',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: primaryColor,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    PageRouteTransition.push(
                                        context, FollowingUi());
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: primaryAccentColor,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          ds['following'].length.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Following',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: primaryColor,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    PageRouteTransition.push(
                                        context, FollowersUi());
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: primaryAccentColor,
                                    ),
                                    child: Column(
                                      children: [
                                        // FollowerCount(),
                                        Text(
                                          ds['followers'].length.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Followers',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: primaryColor,
                                            letterSpacing: 1,
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
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
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
                        PageRouteTransition.effect =
                            TransitionEffect.leftToRight;
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
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
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
            ),
    );
  }
}
