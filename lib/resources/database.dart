import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'storage_methods.dart';
import 'user_details.dart';

class DatabaseMethods {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  getUserDataFromDatabase(String uid) async {
    return await firestore
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();
  }

  getUsersIAmFollowing() async {
    return await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
  }

  getChatRooms() async {
    await FirebaseFirestore.instance
        .collection('chatRoom')
        .where("users", arrayContains: UserDetails.uid)
        .snapshots();
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap);
  }

  getConversationMessages(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .where('users', arrayContains: UserDetails.uid)
        .orderBy('time', descending: true)
        .snapshots();
  }

  setLastMessage(String chatRoomId, lastMessage) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .update({'lastMessage': lastMessage});
  }

  addConversationMessages(String chatRoomId, messageMap) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(messageMap);
  }

  getPosts(List uid) async {
    return await firestore
        .collection('posts')
        .where('uid', whereIn: uid)
        .orderBy('time', descending: true)
        .snapshots();
  }

  getStory(List uid) async {
    return await firestore
        .collection('story')
        .where('uid', whereIn: uid)
        .orderBy('time', descending: true)
        .snapshots();
  }

  uploadComments(
    String postId,
    Map<String, dynamic> commentMap,
  ) async {
    return await firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(commentMap);
  }

  getComments(String postId) async {
    return await firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('time', descending: false)
        .snapshots();
  }

  getFollowersAndFollowing(String uid) async {
    return await firestore.collection('users').doc(uid).snapshots();
  }

  clearAllChats(String chatRoomId) async {
    await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection('chats')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  deletePostDetails(String postId, String postImgUrl) async {
    firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .limit(1)
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        print('no collection');
        deletePost(postId, postImgUrl);
      } else {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .get()
            .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
            deletePost(postId, postImgUrl);
          }
        });
      }
    });
  }

  Future<void> deletePost(String postId, String postImgUrl) async {
    try {
      await firestore
          .collection('posts')
          .doc(postId)
          .delete()
          .then((value) async {
        await FirebaseStorage.instance.refFromURL(postImgUrl).delete();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> likePost(String postId, List likes) async {
    try {
      if (likes.contains(UserDetails.uid)) {
        await firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([UserDetails.uid]),
        });
      } else {
        await firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([UserDetails.uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> uploadPost(
    Uint8List? file,
    String description,
  ) async {
    String res = 'error';
    String photoUrl;
    try {
      var time = DateTime.now();
      if (file == null) {
        photoUrl = '';
      } else {
        photoUrl =
            await StorageMethods().uploadImageToStorage('posts', file, true);
      }

      Map<String, dynamic> postMap = {
        'postImage': photoUrl,
        'time': time,
        'postId': time.toString(),
        'description': description,
        'uid': UserDetails.uid,
        'username': UserDetails.userName,
        'profileImage': UserDetails.userProfilePic,
        'postType': photoUrl == '' ? 'text' : 'image',
        'likes': [],
        'comments': [],
      };
      firestore.collection('posts').doc(time.toString()).set(postMap);
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> uploadStory(
    Uint8List? file,
    String description,
  ) async {
    String res = 'error';
    String photoUrl;
    try {
      var time = DateTime.now();
      if (file == null) {
        photoUrl = '';
      } else {
        photoUrl =
            await StorageMethods().uploadStoryToStorage('story', file, true);
      }

      Map<String, dynamic> postMap = {
        'postImage': photoUrl,
        'time': time,
        'postId': time.toString(),
        'description': description,
        'uid': UserDetails.uid,
        'username': UserDetails.userName,
        'profileImage': UserDetails.userProfilePic,
        'storyType': 'image',
        'likes': [],
        'comments': [],
      };
      firestore.collection('story').doc(UserDetails.uid).set(postMap);
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> uploadDocPost(
      String url, String description, String fileName, String postType) async {
    String res = 'error';
    try {
      var time = DateTime.now();
      Map<String, dynamic> postMap = {
        'postImage': url,
        'time': time,
        'postId': time.toString(),
        'description': description,
        'uid': UserDetails.uid,
        'username': UserDetails.userName,
        'profileImage': UserDetails.userProfilePic,
        'postType': postType,
        'fileName': fileName,
        'likes': [],
        'comments': [],
      };

      firestore.collection('posts').doc(time.toString()).set(postMap);
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
