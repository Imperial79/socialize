import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:socialize/imagePreview.dart';
import 'package:socialize/resources/like_animation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'chewiePlayer.dart';
import 'comments_ui.dart';
import 'othersProfileUi.dart';
import 'resources/colors.dart';
import 'resources/database.dart';
import 'resources/user_details.dart';

class FeedCard extends StatefulWidget {
  final DocumentSnapshot snap;
  FeedCard({
    required this.snap,
  });

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  Stream? commentStream;

  @override
  void initState() {
    getComments();
    super.initState();
  }

  deletePost() async {
    await DatabaseMethods()
        .deletePostDetails(widget.snap['postId'], widget.snap['postImage']);
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

  bool isLikeAnimating = false;
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDarkMode
            ? Colors.grey.shade800
            : primaryScaffoldColor.withOpacity(0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.snap['uid'] == UserDetails.uid
                          ? UserDetails.userProfilePic
                          : widget.snap['profileImage'],
                      imageBuilder: (context, image) => Container(
                        height: 45,
                        width: 45,
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
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: GestureDetector(
                            onTap: () {
                              PageRouteTransition.push(
                                context,
                                OthersProfileUi(
                                  snap: widget.snap,
                                ),
                              );
                            },
                            child: RichText(
                              maxLines: 2,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.snap['uid'] == UserDetails.uid
                                        ? 'You'
                                        : widget.snap['username'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: widget.snap['postType'] == 'image'
                                        ? ' shared an image'
                                        : widget.snap['postType'] == 'video'
                                            ? ' shared a video'
                                            : widget.snap['postType'] == 'text'
                                                ? ' shared a post'
                                                : ' shared a file',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          DateFormat.yMMMd()
                              .format(widget.snap['time'].toDate()),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                widget.snap['uid'] == UserDetails.uid
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: ListView(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shrinkWrap: true,
                                children: [
                                  'Delete',
                                ]
                                    .map(
                                      (e) => InkWell(
                                        onTap: () {
                                          deletePost();
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(15),
                                          child: Text(
                                            e,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.more_horiz,
                          color: Colors.grey.shade500,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.snap['description'] != ''
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          widget.snap['description'],
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize:
                                widget.snap['postType'] == 'text' ? 17 : 14,
                          ),
                        ),
                      )
                    : Container(),
                widget.snap['postType'] != 'image' ||
                        widget.snap['postImage'] == ''
                    ? Container()
                    : GestureDetector(
                        onDoubleTap: () {
                          likePost(
                            widget.snap['postId'],
                            widget.snap['likes'],
                          );
                          setState(() {
                            isLikeAnimating = true;
                          });
                        },
                        onTap: () {
                          PageRouteTransition.effect = TransitionEffect.fade;
                          PageRouteTransition.push(
                            context,
                            ZoomImageUi(
                              img: widget.snap['postImage'],
                            ),
                          ).then((value) {
                            setState(() {});
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.5,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: widget.snap['postImage'],
                                imageBuilder: (context, image) => Container(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: image,
                                      fit: BoxFit.cover,
                                    ),
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
                                  color: Colors.white,
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
                /////////////////////////////////////
                widget.snap['postType'] != 'doc'
                    ? Container()
                    : Container(
                        // height: 200,
                        padding: EdgeInsets.all(13),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          // color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.description,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.snap['fileName'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      // Text(
                                      //   '12mb',
                                      //   style: TextStyle(
                                      //     color: Colors.grey,
                                      //     fontWeight: FontWeight.w600,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: MaterialButton(
                                    onPressed: () async {
                                      await launch(widget.snap['postImage']);
                                      // downloadFile(
                                      //     widget.snap['postImage'], context);
                                    }, //TODO
                                    color: primaryColor.withOpacity(0.1),
                                    elevation: 0,
                                    highlightElevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(15),
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          'Download',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // SizedBox(
                                //   width: 10,
                                // ),
                                // Expanded(
                                //   flex: 2,
                                //   child: MaterialButton(
                                //     onPressed: () async {
                                //       await launch(widget.snap['postImage']);

                                //       // PageRouteTransition.push(
                                //       //     context,
                                //       //     PdfViewerUi(
                                //       //       pdfUrl: widget.snap['postImage'],
                                //       //     ));
                                //     }, //TODO
                                //     color:
                                //         Colors.amber.shade100.withOpacity(0.7),
                                //     elevation: 0,
                                //     highlightElevation: 0,
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(7),
                                //     ),
                                //     child: Container(
                                //       padding: EdgeInsets.all(15),
                                //       width: double.infinity,
                                //       child: Center(
                                //         child: FittedBox(
                                //           child: Text(
                                //             'View',
                                //             style: TextStyle(
                                //               color: Colors.amber.shade700,
                                //               fontWeight: FontWeight.w600,
                                //               fontSize: 17,
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                /////////////////////////////////////
                widget.snap['postType'] != 'video'
                    ? Container()
                    : ChewiePlayer(
                        videoPlayerController: VideoPlayerController.network(
                            widget.snap['postImage']),
                        looping: true),

                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        widget.snap['likes'].length.toString() + ' Likes',
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
                                    CommentsUi(postId: widget.snap['postId']))
                                .then((value) {
                              setState(() {});
                            });
                          },
                          child: StreamBuilder<dynamic>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.snap['postId'])
                                .collection('comments')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data.docs.length == 0) {
                                  return Text(
                                    '0 Comments',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  );
                                }
                                return Text(
                                  snapshot.data.docs.length.toString() +
                                      ' Comments',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                );
                              }
                              return Container();
                            },
                          ), //TODO
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                LikeAnimation(
                  isAnimating: widget.snap['likes'].contains(UserDetails.uid),
                  smallLike: true,
                  child: IconButton(
                    onPressed: () {
                      likePost(
                        widget.snap['postId'],
                        widget.snap['likes'],
                      );
                    },
                    icon: SvgPicture.asset(
                      widget.snap['likes'].contains(UserDetails.uid)
                          ? 'lib/assets/image/like_filled.svg'
                          : 'lib/assets/image/like.svg',
                      color: Colors.pink,
                      height: 17,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    PageRouteTransition.effect = TransitionEffect.rightToLeft;
                    PageRouteTransition.push(
                            context, CommentsUi(postId: widget.snap['postId']))
                        .then((value) {
                      setState(() {});
                    });
                  },
                  icon: SvgPicture.asset(
                    'lib/assets/image/comment.svg',
                    color: Colors.amber.shade800,
                    height: 17,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'lib/assets/image/share.svg',
                    color: Colors.blue.shade800,
                    height: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
