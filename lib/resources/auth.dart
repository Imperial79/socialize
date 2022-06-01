import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_methods.dart';
import 'user_details.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //  GET CURRENT USER
  getCurrentuser() async {
    return await _auth.currentUser;
  }

  ///  SIGN UP USER

  Future<String> signUpUser(
    String email,
    String password,
    String username,
    String bio,
    Uint8List file,
  ) async {
    String res = 'Some error occurred';
    String photoUrl;
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        ///  REGISTER THE USER
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        print(cred.user!.uid);
        print(file);

        //  UPLOADING IMAGE

        photoUrl = await StorageMethods().uploadImageToStorage(
          'profilePics',
          file,
          false,
        );

        var status = await OneSignal.shared.getDeviceState();
        String? tokenId = status!.userId;
        print('My Token ID ---> ' + tokenId!);

        Map<String, dynamic> userMap = {
          'uid': cred.user!.uid,
          'profilePhoto': photoUrl,
          'email': email,
          'username': username,
          'bio': bio,
          'tokenId': tokenId,
          'followers': [],
          'following': [],
          'postCount': 0,
          'active': '1',
        };

        final SharedPreferences prefs = await _prefs;

        prefs.setString('USERKEY', cred.user!.uid);
        prefs.setString('USERNAMEKEY', username);
        prefs.setString('USEREMAILKEY', email);
        prefs.setString('USERPROFILEKEY', photoUrl);
        prefs.setString('TOKENID', tokenId);

        // print('UID from preference -----> ' +
        //     prefs.getString('USERKEY').toString());

        UserDetails.userName = username;
        UserDetails.uid = cred.user!.uid;
        UserDetails.userEmail = email;
        UserDetails.userProfilePic = photoUrl;

        ///   ADD USER TO DATABASE
        await _firestore.collection('users').doc(cred.user!.uid).set(userMap);

        res = 'success';

        ///////////////////////////////////////////////////
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'invalid-email') {
        res = 'The email is badly formatted';
      }
      if (e.code == 'email-already-in-use') {
        res = 'This email is already in use';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //  LOGGING IN USER
  Future<String> logInUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        // final SharedPreferences prefs = await _prefs;

        // prefs.setString('USEREMAILKEY', email);
        FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'active': '1'});
        res = 'Success';

        ////////////////////////////////////////////////////////////
      } else {
        res = 'Please fill all the fields';
      }
    } on FirebaseAuthException catch (err) {
      print(err);
      if (err.code == 'invalid-email') {
        res = 'Invalid Email Format';
      } else if (err.code == 'user-not-found') {
        res = 'User not found';
      } else if (err.code == 'wrong-password') {
        res = 'Invalid Password';
      } else if (err.code == 'user-disabled') {
        res = 'User Disabled';
      }
    } catch (e) {
      res = e.toString();
    }
    print('res ----------------------- ' + res);
    return res;
  }

  logoutuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(UserDetails.uid)
        .update({'active': '0'});
    await _auth.signOut();
  }
}
