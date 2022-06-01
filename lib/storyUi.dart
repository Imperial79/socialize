import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:socialize/resources/user_details.dart';

import 'resources/colors.dart';

class StoryUi extends StatefulWidget {
  final snap;
  StoryUi({
    required this.snap,
  });

  @override
  _StoryUiState createState() => _StoryUiState();
}

class _StoryUiState extends State<StoryUi> {
  bool isFullScreen = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
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
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              child: CachedNetworkImage(
                imageUrl: widget.snap['profileImage'],
                imageBuilder: (context, image) => CircleAvatar(
                  radius: 20,
                  backgroundImage: image,
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
                  widget.snap['username'] == UserDetails.userName
                      ? 'You'
                      : widget.snap['username'],
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(widget.snap['time'].toDate()),
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isFullScreen = !isFullScreen;
              });
            },
            child: Hero(
              tag: widget.snap['postImage'],
              child: Container(
                height: double.infinity,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: widget.snap['postImage'],
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          widget.snap['description'] == '' || isFullScreen
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.5),
                        child: Text(
                          widget.snap['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
