import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:socialize/resources/database.dart';
import 'package:socialize/resources/user_details.dart';
import 'package:url_launcher/url_launcher.dart';

import 'resources/colors.dart';

class CoversationRoomUi extends StatefulWidget {
  final String chatRoomId;
  final String chatWith;
  final String image;
  final String chatWithUid;
  final userDetails;

  CoversationRoomUi({
    required this.chatRoomId,
    required this.chatWith,
    required this.image,
    required this.chatWithUid,
    required this.userDetails,
  });

  @override
  _CoversationRoomUiState createState() => _CoversationRoomUiState();
}

class _CoversationRoomUiState extends State<CoversationRoomUi> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageController = new TextEditingController();

  Stream? chatMessageStream;

  @override
  void initState() {
    databaseMethods.getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    super.initState();
  }

  Widget ChatMessageList() {
    return StreamBuilder<dynamic>(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.docs.length == 0) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Send Hi!',
                    style: TextStyle(
                      color: Colors.blueGrey.shade200,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'and start a conversation',
                    style: TextStyle(
                      color: Colors.blueGrey.shade200,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            physics: BouncingScrollPhysics(),
            reverse: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              return MessageTile(
                snapshot.data.docs[index].data()["message"],
                snapshot.data.docs[index].data()["sendBy"],
                widget.userDetails,
                snapshot.data.docs[index].data()["time"],
              );
            },
          );
        }
        return Center(
          child: CircularProgressIndicator(color: primaryColor),
        );
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      List users = [
        UserDetails.uid,
        widget.chatRoomId.replaceAll(UserDetails.uid, '').replaceAll('#_#', '')
      ];
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": UserDetails.uid,
        "time": DateTime.now(),
        'users': users,
      };

      databaseMethods.addConversationMessages(widget.chatRoomId, messageMap);
      databaseMethods.setLastMessage(widget.chatRoomId, messageController.text);
      messageController.text = "";
    }
  }

  void handleClick(String item) {
    switch (item) {
      case '0':
        DatabaseMethods().clearAllChats(widget.chatRoomId);
        Navigator.pop(context);
        break;
      case '1':
        // Navigator.push(
        //     context,
        //     CupertinoPageRoute(
        //         builder: (context) => DetailsUi(
        //               image: widget.image,
        //               name: widget.chatWith,
        //               chatRoomId: widget.chatRoomId,
        //               type: widget.type,
        //             )));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: primaryScaffoldColor,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => DetailsUi(
                //               image: widget.image,
                //               name: widget.chatWith,
                //               chatRoomId: widget.chatRoomId,
                //               type: widget.type,
                //             )));
              },
              child: Hero(
                tag: widget.image,
                child: CachedNetworkImage(
                  imageUrl: widget.image,
                  imageBuilder: (context, image) => CircleAvatar(
                    backgroundColor: Colors.grey.shade700,
                    backgroundImage: image,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: StreamBuilder<dynamic>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('uid', isEqualTo: widget.chatWithUid)
                    .snapshots(),
                builder: (context, userSnap) {
                  if (userSnap.hasData) {
                    if (userSnap.data.docs.length == 0) {
                      return Container();
                    }
                    DocumentSnapshot ds = userSnap.data.docs[0];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ds['username'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: ds['active'] == '1'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              ds['active'] == '1' ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontSize: 13,
                                color: primaryScaffoldColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: Icon(
              Icons.more_vert_rounded,
              color: primaryScaffoldColor,
            ),
            onSelected: (item) => handleClick(item.toString()),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Text('Clear all Chats'),
              ),
              PopupMenuItem(
                value: 1,
                child: Text('Details'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessageList(),
          ),
          Container(
            // color: Colors.black,
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryScaffoldColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: messageController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        autofocus: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                          hintText: "Message...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: primaryColor,
                    child: IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: SvgPicture.asset(
                        'lib/assets/image/send.svg',
                        color: primaryScaffoldColor,
                        height: 15,
                      ),
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
}

class MessageTile extends StatelessWidget {
  final String message;
  final String sendBy;
  final userDetails;
  var time;
  MessageTile(
    this.message,
    this.sendBy,
    this.userDetails,
    this.time,
  );

  @override
  Widget build(BuildContext context) {
    bool sendByMe = sendBy == UserDetails.uid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: (sendByMe) ? Alignment.topRight : Alignment.topLeft,
          width: double.infinity,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: (sendByMe)
                  ? primaryScaffoldColor
                  : primaryColor.withOpacity(0.2),
              borderRadius: (sendByMe)
                  ? BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
            ),
            child: Column(
              crossAxisAlignment:
                  sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                SelectableLinkify(
                  onOpen: (link) async {
                    if (await canLaunch(link.url)) {
                      await launch(link.url);
                    } else {
                      throw 'Could not launch $link';
                    }
                  },
                  text: message,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  DateFormat.Hm().format(time.toDate()),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blueGrey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
