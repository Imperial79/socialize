import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:socialize/resources/auth.dart';
import 'package:socialize/resources/pickImage.dart';

import 'homeUi.dart';
import 'loginUi.dart';
import 'resources/colors.dart';
import 'resources/myWidgets.dart';

class SignUpUi extends StatefulWidget {
  const SignUpUi({Key? key}) : super(key: key);

  @override
  _SignUpUiState createState() => _SignUpUiState();
}

class _SignUpUiState extends State<SignUpUi> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final bioController = TextEditingController();
  final emailController = TextEditingController();
  Uint8List? _image;
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    passwordController.dispose();
    bioController.dispose();
    emailController.dispose();
  }

  createAccount() async {
    if (formKey.currentState!.validate()) {
      if (_image == null) {
        // _image = (await NetworkAssetBundle(Uri.parse(
        //             'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmywnX8X85jiWUi9y_1ul_75WhF82V5yq41A&usqp=CAU'))
        //         .load(
        //             'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmywnX8X85jiWUi9y_1ul_75WhF82V5yq41A&usqp=CAU'))
        //     .buffer
        //     .asUint8List();

        _image = (await rootBundle.load('lib/assets/image/noImage.jpg'))
            .buffer
            .asUint8List();
      }

      //UNFOCUSSING THE TEXTFIELD
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });
      String res = await AuthMethods().signUpUser(
        emailController.text,
        passwordController.text,
        usernameController.text,
        bioController.text,
        _image!,
      );

      setState(() {
        isLoading = false;
      });

      if (res == 'success') {
        PageRouteTransition.pushReplacement(context, HomeUi());
      } else {
        print(res);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            // behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
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
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.grey.shade300,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'lib/assets/image/back.jpg',
            ),
            fit: BoxFit.cover,
            opacity: 1,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.6),
              BlendMode.lighten,
            ),
          ),
        ),
        child:

            // SafeArea(
            //   child: Stack(
            //     children: [
            //       Align(
            //         alignment: Alignment.topCenter,
            //         child: Text(
            //           'Socialize',
            //           style: TextStyle(
            //             color: primaryColor,
            //             fontSize: 30,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //       Align(
            //         alignment: Alignment.bottomCenter,
            //         child: Expanded(
            //           child: SingleChildScrollView(
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.end,
            //               children: [
            //                 Stack(
            //                   children: [
            //                     _image != null
            //                         ? CircleAvatar(
            //                             radius: 50,
            //                             backgroundColor: Colors.blueGrey.shade100,
            //                             backgroundImage: MemoryImage(_image!),
            //                           )
            //                         : CircleAvatar(
            //                             radius: 50,
            //                             backgroundColor: Colors.blueGrey.shade100,
            //                             backgroundImage: AssetImage(
            //                               'lib/assets/image/noImage.jpg',
            //                             ),
            //                           ),
            //                     Positioned(
            //                       top: 70,
            //                       left: 70,
            //                       child: GestureDetector(
            //                         onTap: () {
            //                           selectImage();
            //                         },
            //                         child: CircleAvatar(
            //                           radius: 15,
            //                           backgroundColor: Colors.black,
            //                           child: Icon(
            //                             Icons.add_a_photo,
            //                             size: 16,
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //                 SizedBox(
            //                   height: 30,
            //                 ),
            //                 CustomTextField(
            //                   label: 'Username',
            //                   obsecureText: false,
            //                   textCapitalization: TextCapitalization.sentences,
            //                   textEditingController: usernameController,
            //                   keyboardType: TextInputType.text,
            //                   validator: (value) {
            //                     if (value!.isEmpty) {
            //                       return 'This Field is required';
            //                     }
            //                     return null;
            //                   },
            //                 ),
            //                 CustomTextField(
            //                   label: 'Email',
            //                   obsecureText: false,
            //                   textCapitalization: TextCapitalization.none,
            //                   textEditingController: emailController,
            //                   keyboardType: TextInputType.emailAddress,
            //                   validator: (value) {
            //                     return RegExp(
            //                                 r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$")
            //                             .hasMatch(value!)
            //                         ? null
            //                         : "Provide a valid password";
            //                   },
            //                 ),
            //                 CustomTextField(
            //                   label: 'Password',
            //                   obsecureText: true,
            //                   textCapitalization: TextCapitalization.none,
            //                   textEditingController: passwordController,
            //                   keyboardType: TextInputType.number,
            //                   validator: (value) {
            //                     if (value!.length < 6) {
            //                       return 'Password Length must be more than 6 characters';
            //                     } else if (value.isEmpty) {
            //                       return 'This Field is required';
            //                     }
            //                     return null;
            //                   },
            //                 ),
            //                 CustomTextField(
            //                   label: 'Bio',
            //                   obsecureText: false,
            //                   textCapitalization: TextCapitalization.sentences,
            //                   textEditingController: bioController,
            //                   keyboardType: TextInputType.text,
            //                   validator: (value) {
            //                     if (value!.isEmpty) {
            //                       return 'This Field is required';
            //                     }
            //                     return null;
            //                   },
            //                 ),
            //                 SizedBox(
            //                   height: 20,
            //                 ),
            //                 MaterialButton(
            //                   onPressed: () {
            //                     if (!isLoading) {
            //                       createAccount();
            //                     }
            //                   },
            //                   shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(5),
            //                   ),
            //                   color: primaryColor,
            //                   elevation: 0,
            //                   highlightElevation: 0,
            //                   child: Container(
            //                     padding: EdgeInsets.symmetric(vertical: 15),
            //                     width: double.infinity,
            //                     child: Center(
            //                       child: isLoading
            //                           ? CircularProgressIndicator(
            //                               color: Colors.white,
            //                             )
            //                           : Text(
            //                               'Create Account',
            //                               style: TextStyle(
            //                                 color: Colors.white,
            //                               ),
            //                             ),
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(
            //                   height: 40,
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.center,
            //                   crossAxisAlignment: CrossAxisAlignment.center,
            //                   children: [
            //                     Text(
            //                       'Already have an account? ',
            //                       style: TextStyle(
            //                         color: Colors.grey.shade600,
            //                         fontWeight: FontWeight.w600,
            //                       ),
            //                     ),
            //                     GestureDetector(
            //                       onTap: () {
            //                         PageRouteTransition.effect =
            //                             TransitionEffect.fade;
            //                         PageRouteTransition.pushReplacement(
            //                             context, LoginUi());
            //                       },
            //                       child: Container(
            //                         color: Colors.transparent,
            //                         child: Text(
            //                           'Login',
            //                           style: TextStyle(
            //                             color: primaryColor,
            //                             fontWeight: FontWeight.w800,
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
//////////////////////////////////////////////////////////////////
            SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Socialize',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              _image != null
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.blueGrey.shade100,
                                      backgroundImage: MemoryImage(_image!),
                                    )
                                  : CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.blueGrey.shade100,
                                      backgroundImage: AssetImage(
                                        'lib/assets/image/noImage.jpg',
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
                                    backgroundColor: Colors.black,
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.blue.shade100,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
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
                            label: 'Email',
                            obsecureText: false,
                            textCapitalization: TextCapitalization.none,
                            textEditingController: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$")
                                      .hasMatch(value!)
                                  ? null
                                  : "Provide a valid password";
                            },
                          ),
                          CustomTextField(
                            label: 'Password',
                            obsecureText: true,
                            textCapitalization: TextCapitalization.none,
                            textEditingController: passwordController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.length < 6) {
                                return 'Password Length must be more than 6 characters';
                              } else if (value.isEmpty) {
                                return 'This Field is required';
                              }
                              return null;
                            },
                          ),
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
                              if (!isLoading) {
                                createAccount();
                              }
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
                                        'Create Account',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          PageRouteTransition.effect = TransitionEffect.fade;
                          PageRouteTransition.pushReplacement(
                              context, LoginUi());
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
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
