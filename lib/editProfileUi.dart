import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'resources/colors.dart';
import 'resources/myWidgets.dart';
import 'resources/pickImage.dart';
import 'resources/storage_methods.dart';
import 'resources/user_details.dart';

class UpdateProfileUi extends StatefulWidget {
  const UpdateProfileUi({Key? key}) : super(key: key);

  @override
  _UpdateProfileUiState createState() => _UpdateProfileUiState();
}

class _UpdateProfileUiState extends State<UpdateProfileUi> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final bioController = TextEditingController();
  final emailController = TextEditingController();
  Uint8List? _image;
  bool isLoading = false;
  String? photoUrl;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    usernameController.text = UserDetails.userName;
    bioController.text = UserDetails.bio;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    passwordController.dispose();
    bioController.dispose();
    emailController.dispose();
  }

  updateProfile() async {
    if (formKey.currentState!.validate()) {
      //  UPLOADING IMAGE
      if (_image != null) {
        setState(() {
          isLoading = true;
        });

        photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', _image!, false);
        //  IF NEW PHOTO SELECTED

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(UserDetails.uid)
              .update({
            'username': usernameController.text,
            'bio': bioController.text,
            'profilePhoto': photoUrl,
          });
          setState(() {
            isLoading = false;
            _image = null;
          });
          showSnackBar(
            context,
            content: 'Profile Updated',
            color: Colors.green.shade800,
            svgIcon: 'success.svg',
          );
          UserDetails.userName = usernameController.text;
          UserDetails.bio = bioController.text;
          UserDetails.userProfilePic = photoUrl!;
        } catch (e) {
          showSnackBar(
            context,
            content: e.toString(),
            color: Colors.red.shade800,
            svgIcon: 'error.svg',
          );
        }
      } else {
        //  IF NO NEW PHOTO SELECTED

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(UserDetails.uid)
              .update({
            'username': usernameController.text,
            'bio': bioController.text,
          });
          setState(() {
            isLoading = false;
          });
          showSnackBar(
            context,
            content: 'Profile Updated',
            color: Colors.green.shade800,
            svgIcon: 'profile.svg',
          );
          UserDetails.userName = usernameController.text;
          UserDetails.bio = bioController.text;
        } catch (e) {
          showSnackBar(
            context,
            content: e.toString(),
            color: Colors.red.shade800,
            svgIcon: 'profile.svg',
          );
        }
      }
    }
  }

  selectImage() async {
    Uint8List pickedImage = await pickImage(ImageSource.gallery);
    setState(() {
      _image = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'EDIT PROFILE',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 30,
                        letterSpacing: 5,
                        wordSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blueGrey.shade100,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : CachedNetworkImage(
                              imageUrl: UserDetails.userProfilePic,
                              imageBuilder: (context, image) => CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.blueGrey.shade100,
                                backgroundImage: image,
                              ),
                            ),
                      Positioned(
                        top: 70,
                        left: 70,
                        child: GestureDetector(
                          onTap: () {
                            selectImage();
                          },
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: primaryScaffoldColor,
                            child: Icon(
                              Icons.edit,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  CustomTextField(
                    label: 'Username',
                    obsecureText: false,
                    textCapitalization: TextCapitalization.sentences,
                    textEditingController: usernameController,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'This Field is required';
                      }
                      return null;
                    },
                  ),
                  // BuildCustomTextField(
                  //   label: 'Email',
                  //   obsecureText: false,
                  //   textCapitalization: TextCapitalization.none,
                  //   textEditingController: emailController,
                  //   keyboardType: TextInputType.emailAddress,
                  //   validator: (value) {
                  //     return RegExp(
                  //                 r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$")
                  //             .hasMatch(value!)
                  //         ? null
                  //         : "Provide a valid password";
                  //   },
                  // ),
                  // BuildCustomTextField(
                  //   label: 'Password',
                  //   obsecureText: true,
                  //   textCapitalization: TextCapitalization.none,
                  //   textEditingController: passwordController,
                  //   keyboardType: TextInputType.text,
                  //   validator: (value) {
                  //     if (value!.length < 6) {
                  //       return 'Password Length must be more than 6 characters';
                  //     } else if (value.isEmpty) {
                  //       return 'This Field is required';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  CustomTextField(
                    label: 'Bio',
                    obsecureText: false,
                    textCapitalization: TextCapitalization.sentences,
                    textEditingController: bioController,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'This Field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                    onPressed: () {
                      if (!isLoading) updateProfile();
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
                        child: isLoading
                            ? CustomProgressIndicator()
                            : Text(
                                'Update Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.15,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       'Already have an account? ',
                  //       style: TextStyle(
                  //         color: Colors.cyan.shade900,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         PageRouteTransition.effect = TransitionEffect.fade;
                  //         PageRouteTransition.pushReplacement(
                  //             context, LoginUi());
                  //       },
                  //       child: Text(
                  //         'Login',
                  //         style: TextStyle(
                  //           color: primaryColor,
                  //           fontWeight: FontWeight.w700,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
