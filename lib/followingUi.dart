import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'resources/colors.dart';
import 'resources/user_details.dart';

class FollowingUi extends StatefulWidget {
  const FollowingUi({Key? key}) : super(key: key);

  @override
  _FollowingUiState createState() => _FollowingUiState();
}

class _FollowingUiState extends State<FollowingUi> {
  @override
  Widget build(BuildContext context) {
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
                    'Following',
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
                      .where('followers', arrayContains: UserDetails.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.docs.length == 0) {
                        return Center(
                          child: Text(
                            'You\'re not following anyone',
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
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data.docs[index];
                          return Container(
                            margin: EdgeInsets.only(top: 9),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  width: 10,
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
                                            ds['following'].length.toString() +
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
                                Spacer(),
                                MaterialButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(ds['uid'])
                                        .update({
                                      'followers': FieldValue.arrayRemove(
                                          [UserDetails.uid]),
                                    });

                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(UserDetails.uid)
                                        .update({
                                      'following':
                                          FieldValue.arrayRemove([ds['uid']])
                                    });
                                  },
                                  elevation: 0,
                                  // color: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide(
                                      color: Colors.blueGrey.shade200,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  child: Text(
                                    'Unfollow',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: primaryColor,
                                      // fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
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
