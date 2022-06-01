import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'resources/colors.dart';
import 'resources/database.dart';
import 'resources/user_details.dart';

class CommentsUi extends StatefulWidget {
  final postId;
  CommentsUi({required this.postId});

  @override
  _CommentsUiState createState() => _CommentsUiState();
}

class _CommentsUiState extends State<CommentsUi> {
  final commentController = TextEditingController();
  final dbMethod = DatabaseMethods();
  Stream? commentStream;

  @override
  void initState() {
    dbMethod.getComments(widget.postId).then((value) {
      setState(() {
        commentStream = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  uploadComments() async {
    if (commentController.text.isNotEmpty) {
      var time = DateTime.now();
      Map<String, dynamic> commentMap = {
        'comment': commentController.text,
        'userImage': UserDetails.userProfilePic,
        'username': UserDetails.userName,
        'uid': UserDetails.uid,
        'time': time,
      };
      await dbMethod.uploadComments(widget.postId, commentMap);
      // dbMethod.updateCommentsCount(widget.postId);
      commentController.clear();
    }
  }

  Widget CommentList() {
    return StreamBuilder<dynamic>(
      stream: commentStream,
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data.docs.length == 0)
                ? Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'No Comments',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      // print('yes');
                      return BuildCommentCard(snap: ds);
                    },
                  )
            : Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(
                    color: Colors.teal.shade400,
                  ),
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Color(0xfff2f7fa),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: false,
      //   leading: IconButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     icon: SvgPicture.asset(
      //       'lib/assets/image/back.svg',
      //       color: Colors.white,
      //     ),
      //   ),
      //   elevation: 0,
      //   backgroundColor: primaryColor,
      //   title: Text(
      //     'Comments',
      //     style: TextStyle(
      //       color: Colors.white,
      //       fontWeight: FontWeight.w500,
      //       fontSize: 18,
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: SvgPicture.asset(
                      'lib/assets/image/back.svg',
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    'Comments',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CommentList(),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey.shade400, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: commentController,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        hintText: 'Comment as ' + UserDetails.userName,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: CircleAvatar(
                      backgroundColor: primaryColor,
                      child: IconButton(
                        onPressed: () {
                          uploadComments();
                        },
                        icon: SvgPicture.asset(
                          'lib/assets/image/send.svg',
                          height: 17,
                          color: primaryScaffoldColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget BuildCommentCard({
    required DocumentSnapshot snap,
  }) {
    return Container(
      padding: EdgeInsets.only(left: 15, top: 20, right: 15),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Color(0xfff2f7fa),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: snap['userImage'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: snap['username'] + ' ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: snap['comment'],
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  DateFormat.yMMMd().format(snap['time'].toDate()),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
