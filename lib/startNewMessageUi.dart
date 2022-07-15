import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:socialize/conversationRoomUi.dart';
import 'package:socialize/resources/database.dart';
import 'package:socialize/resources/user_details.dart';

import 'resources/colors.dart';

class NewMessageUi extends StatefulWidget {
  const NewMessageUi({Key? key}) : super(key: key);

  @override
  _NewMessageUiState createState() => _NewMessageUiState();
}

class _NewMessageUiState extends State<NewMessageUi> {
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
      PageRouteTransition.push(
          context,
          CoversationRoomUi(
            chatRoomId: chatRoomId,
            chatWith: friendName,
            chatWithUid: friendsUid,
            image: friendDp,
            userDetails: userDetails,
          ));
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

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\#_#$a";
    } else {
      return "$a\#_#$b";
    }
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
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
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Start New Chat',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: StreamBuilder<dynamic>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('following', arrayContains: UserDetails.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.docs.length == 0) {
                        return Center(
                          child: Text(
                            'Follow someone to start a chat',
                            style: TextStyle(
                              color: Colors.blueGrey.shade200,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data.docs[index];
                          return GestureDetector(
                            onTap: () {
                              createPersonalChatRoom(
                                friendDp: ds['profilePhoto'],
                                friendName: ds['username'],
                                friendsUid: ds['uid'],
                              );
                            },
                            child: Container(
                              color: Colors.white,
                              margin: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    child: CachedNetworkImage(
                                      imageUrl: ds['profilePhoto'],
                                      fit: BoxFit.cover,
                                      imageBuilder: (context, image) =>
                                          CircleAvatar(
                                        radius: 22,
                                        backgroundImage: image,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ds['username'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey.shade600,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          ds['followers'].length.toString() +
                                              ' Followers | ' +
                                              ds['following']
                                                  .length
                                                  .toString() +
                                              ' Following',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.blueGrey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
            ],
          ),
        ),
      ),
    );
  }
}
