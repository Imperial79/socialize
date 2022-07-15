import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:socialize/resources/database.dart';
import 'package:socialize/startNewMessageUi.dart';

import 'conversationRoomUi.dart';
import 'resources/colors.dart';
import 'resources/user_details.dart';

class ChatsUi extends StatefulWidget {
  const ChatsUi({Key? key}) : super(key: key);

  @override
  _ChatsUiState createState() => _ChatsUiState();
}

class _ChatsUiState extends State<ChatsUi> {
  Stream? chatRoomStream;

  onPageLoad() async {
    await DatabaseMethods().getChatRooms().then((value) {
      setState(() {
        chatRoomStream = value;
      });
    });
  }

  @override
  void initState() {
    onPageLoad();
    super.initState();
  }

  Widget PersonalchatRoomList() {
    return StreamBuilder<dynamic>(
      stream: FirebaseFirestore.instance
          .collection('chatRoom')
          .where("users", arrayContains: UserDetails.uid)
          .snapshots(),
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data.docs.length == 0)
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Text(
                        'No Chats',
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.grey.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      return ChatListTile(ds);
                    },
                  )
            : Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              );
      },
    );
  }

  Widget ChatListTile(var ds) {
    String chatRoomId = ds['chatRoomId'];
    String userUid = chatRoomId
        .toString()
        .replaceAll(UserDetails.uid, "")
        .replaceAll("#_#", '');

    String displayName = ds['userDetails'][userUid]['name'];

    String image = ds['userDetails'][userUid]['dp'];

    return MaterialButton(
      onPressed: () {
        PageRouteTransition.push(
          context,
          CoversationRoomUi(
            chatRoomId: ds['chatRoomId'],
            chatWith: displayName,
            chatWithUid: userUid,
            image: image,
            userDetails: ds,
          ),
        );
      },
      elevation: 0,
      highlightElevation: 0,
      highlightColor: primaryColor.withOpacity(0.2),
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        width: double.infinity,
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: image,
              imageBuilder: (context, image) => CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey,
                backgroundImage: image,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: ds['lastMessage'] == '' ? 0 : 5,
                    ),
                    ds['lastMessage'] == ''
                        ? Container()
                        : Text(
                            ds['lastMessage'],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
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
        title: Row(
          children: [
            SvgPicture.asset(
              'lib/assets/image/chat_filled.svg',
              height: 20,
              color: primaryColor,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'CHATS',
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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              color: primaryScaffoldColor,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                color: Colors.white,
                child: PersonalchatRoomList(),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              // height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    spreadRadius: 5,
                    blurRadius: 25,
                  ),
                ],
              ),
              child: MaterialButton(
                onPressed: () {
                  PageRouteTransition.push(context, NewMessageUi());
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
                      'Start new message',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
