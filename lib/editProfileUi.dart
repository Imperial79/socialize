import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialize/utilities/sdp.dart';

import 'resources/colors.dart';
import 'resources/myWidgets.dart';
import 'services/pickImage.dart';
import 'services/storage_methods.dart';
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
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 10),
                  // Expanded(
                  //   child: Text(
                  //     'EDIT PROFILE',
                  //     style: TextStyle(
                  //       color: primaryColor,
                  //       fontSize: 30,
                  //       letterSpacing: 5,
                  //       wordSpacing: 3,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.05,
                  // ),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.blueGrey.shade100,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : CachedNetworkImage(
                              imageUrl: UserDetails.userProfilePic,
                              imageBuilder: (context, image) => CircleAvatar(
                                radius: 100,
                                backgroundColor: Colors.blueGrey.shade100,
                                backgroundImage: image,
                              ),
                            ),
                      GestureDetector(
                        onTap: () {
                          selectImage();
                        },
                        child: Container(
                          padding: EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: primaryAccentColor,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: primaryColor,
                            size: sdp(context, 16),
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
                  CustomTextField(
                    label: 'Bio',
                    obsecureText: false,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    textEditingController: bioController,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) return 'This Field is required';
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
                      borderRadius: BorderRadius.circular(10),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
