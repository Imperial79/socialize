import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socialize/imagePreview.dart';
import 'package:socialize/services/auth.dart';
import 'package:socialize/utilities/sdp.dart';
import 'package:socialize/utilities/utility.dart';

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
                whiteColor,
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
            fontWeight: FontWeight.w500,
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
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade700,
              fontSize: 20,
            ),
          );
        } else {
          return Text(
            '0',
            style: TextStyle(
              fontWeight: FontWeight.w500,
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
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade700,
              fontSize: 20,
            ),
          );
        } else {
          return Text(
            '0',
            style: TextStyle(
              fontWeight: FontWeight.w500,
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
    return Scaffold(
      body: SafeArea(
        child: UserDetails.uid == ''
            ? Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              )
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 205,
                              ),
                              Container(
                                padding: EdgeInsets.all(20),
                                height: 160,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  UserDetails.bio,
                                  style: TextStyle(
                                    fontSize:
                                        UserDetails.bio.length > 100 ? 20 : 40,
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 125,
                                left: 20,
                                child: GestureDetector(
                                  onTap: () {
                                    NavPush(
                                        context,
                                        ZoomImageUi(
                                          img: UserDetails.userProfilePic,
                                        ));
                                  },
                                  child: Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: whiteColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: whiteColor,
                                        width: 5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: UserDetails.userProfilePic == ''
                                          ? CircularProgressIndicator(
                                              color: primaryColor,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  UserDetails.userProfilePic,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            UserDetails.userName,
                            style: TextStyle(
                              color: Colors.blueGrey.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                child: Text('@'),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                UserDetails.userEmail,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Flexible(
                                child: MaterialButton(
                                  onPressed: () {
                                    PageRouteTransition.push(
                                            context, UpdateProfileUi())
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
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: whiteColor,
                                          ),
                                        ),
                                        Icon(
                                          Icons.edit,
                                          color: whiteColor,
                                          size: sdp(context, 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: MaterialButton(
                                  onPressed: () {
                                    AuthMethods().logoutuser();
                                    PageRouteTransition.effect =
                                        TransitionEffect.leftToRight;
                                    PageRouteTransition.pushReplacement(
                                        context, LoginUi());
                                  },
                                  elevation: 0,
                                  highlightElevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  color: Colors.red,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.exit_to_app,
                                          color: whiteColor,
                                        ),
                                        Text(
                                          'Logout',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: whiteColor,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                                fontWeight: FontWeight.w900,
                                                color: primaryColor,
                                                fontSize: sdp(context, 20),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'Posts',
                                              style: TextStyle(
                                                color: blackColor,
                                                fontWeight: FontWeight.w500,
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
                                              fontWeight: FontWeight.w900,
                                              color: primaryColor,
                                              fontSize: sdp(context, 20),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Posts',
                                            style: TextStyle(
                                              color: blackColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
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
                                    child: Column(
                                      children: [
                                        Text(
                                          ds['following'].length.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: primaryColor,
                                            fontSize: sdp(context, 20),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Following',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: blackColor,
                                          ),
                                        ),
                                      ],
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
                                    child: Column(
                                      children: [
                                        // FollowerCount(),
                                        Text(
                                          ds['followers'].length.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: primaryColor,
                                            fontSize: sdp(context, 20),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Followers',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: blackColor,
                                          ),
                                        ),
                                      ],
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
                                color: whiteColor,
                                fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
