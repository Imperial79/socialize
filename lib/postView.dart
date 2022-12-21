import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:socialize/resources/database.dart';
import 'package:socialize/resources/like_animation.dart';
import 'package:socialize/resources/user_details.dart';

import 'comments_ui.dart';
import 'imagePreview.dart';
import 'resources/colors.dart';

class PostView extends StatefulWidget {
  final snap;
  PostView({
    this.snap,
  });

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  Stream? commentStream;
  bool isLikeAnimating = false;

  @override
  void initState() {
    getComments();
    super.initState();
  }

  getComments() async {
    await DatabaseMethods().getComments(widget.snap['postId']).then((value) {
      setState(() {
        commentStream = value;
      });
    });
  }

  likePost(String postId, List likes) async {
    await DatabaseMethods().likePost(
      postId,
      likes,
    );
  }

  //  GETTING REALTIME COMMENTS COUNT FROM FIREBASE
  Widget CommentStream() {
    return StreamBuilder<dynamic>(
      stream: commentStream,
      builder: (context, snapshot) {
        return (snapshot.data != null)
            ? (snapshot.data.docs.length == 0)
                ? Text(
                    '0 Comments',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  )
                : Text(
                    snapshot.data.docs.length.toString() + ' Comments',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  )
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<dynamic>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where('postId', isEqualTo: widget.snap['postId'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.docs.length == 0) {
                return Text('No Data');
              } else {
                DocumentSnapshot ds = snapshot.data.docs[0];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Expanded(
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: ds['profileImage'],
                              imageBuilder: (context, image) => Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ds['username'] == UserDetails.userName
                                      ? 'You'
                                      : ds['username'],
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.grey.shade100
                                        : Colors.blueGrey.shade700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  DateFormat.yMMMd()
                                      .format(ds['time'].toDate()),
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade300,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ds['description'] == ''
                                    ? Container()
                                    : Padding(
                                        padding: EdgeInsets.only(
                                          top: 10,
                                          left: 20,
                                          bottom: 15,
                                        ),
                                        child: Text(
                                          ds['description'],
                                          style: TextStyle(
                                            color: Colors.blueGrey.shade600,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: SingleChildScrollView(
                            child: GestureDetector(
                              onDoubleTap: () {
                                likePost(
                                  ds['postId'],
                                  ds['likes'],
                                );
                                setState(() {
                                  isLikeAnimating = true;
                                });
                              },
                              onTap: () {
                                PageRouteTransition.effect =
                                    TransitionEffect.fade;
                                PageRouteTransition.push(
                                  context,
                                  ZoomImageUi(
                                    img: ds['postImage'],
                                  ),
                                ).then((value) {
                                  setState(() {});
                                });
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Hero(
                                    tag: ds['postImage'],
                                    child: Container(
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: ds['postImage'],
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    duration: Duration(milliseconds: 200),
                                    opacity: isLikeAnimating ? 1 : 0,
                                    child: LikeAnimation(
                                      child: SvgPicture.asset(
                                        'lib/assets/image/like_filled.svg',
                                        color: whiteColor,
                                        height: 100,
                                      ),
                                      isAnimating: isLikeAnimating,
                                      duration: Duration(milliseconds: 400),
                                      onEnd: () {
                                        setState(() {
                                          isLikeAnimating = false;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryScaffoldColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  ds['likes'].length.toString() + ' Likes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      PageRouteTransition.push(context,
                                              CommentsUi(postId: ds['postId']))
                                          .then((value) {
                                        setState(() {});
                                      });
                                    },
                                    child: CommentStream(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LikeAnimation(
                                isAnimating: widget.snap['likes']
                                    .contains(UserDetails.uid),
                                smallLike: true,
                                child: MaterialButton(
                                  onPressed: () {
                                    likePost(
                                      ds['postId'],
                                      ds['likes'],
                                    );
                                  },
                                  elevation: 0,
                                  highlightElevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: ds['likes'].contains(UserDetails.uid)
                                      ? Colors.pink.withOpacity(0.2)
                                      : Colors.transparent,
                                  child: SvgPicture.asset(
                                    ds['likes'].contains(UserDetails.uid)
                                        ? 'lib/assets/image/like_filled.svg'
                                        : 'lib/assets/image/like.svg',
                                    color: Colors.pink,
                                    height: 17,
                                  ),
                                ),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  PageRouteTransition.effect =
                                      TransitionEffect.rightToLeft;
                                  PageRouteTransition.push(context,
                                          CommentsUi(postId: ds['postId']))
                                      .then((value) {
                                    setState(() {});
                                  });
                                },
                                elevation: 0,
                                highlightElevation: 0,
                                highlightColor: Colors.amber.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SvgPicture.asset(
                                  'lib/assets/image/comment.svg',
                                  color: Colors.amber.shade800,
                                  height: 17,
                                ),
                              ),
                              MaterialButton(
                                onPressed: () {},
                                elevation: 0,
                                highlightElevation: 0,
                                highlightColor: Colors.blue.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SvgPicture.asset(
                                  'lib/assets/image/share.svg',
                                  color: Colors.blue.shade800,
                                  height: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
