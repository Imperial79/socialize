import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_route_transition/page_route_transition.dart';

import 'rootScrUI.dart';
import 'resources/auth.dart';
import 'resources/colors.dart';
import 'resources/myWidgets.dart';
import 'registerUI.dart';

class LoginUi extends StatefulWidget {
  const LoginUi({Key? key}) : super(key: key);

  @override
  _LoginUiState createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  logIn() async {
    if (formKey.currentState!.validate()) {
      //UNFOCUSSING THE TEXTFIELD
      FocusScope.of(context).unfocus();

      setState(() {
        isLoading = true;
      });
      String res = await AuthMethods().logInUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      setState(() {
        isLoading = false;
      });

      if (res == 'Success') {
        PageRouteTransition.pushReplacement(context, RootScr());
        showSnackBar(
          context,
          content: 'Success',
          color: Colors.green.shade800,
          svgIcon: 'success.svg',
        );
      } else {
        showSnackBar(
          context,
          content: res,
          color: Colors.red.shade800,
          svgIcon: 'error.svg',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage(
            //     'lib/assets/image/back.jpg',
            //   ),
            //   fit: BoxFit.cover,
            //   opacity: 1,
            //   colorFilter: ColorFilter.mode(
            //     Colors.white.withOpacity(0.6),
            //     BlendMode.lighten,
            //   ),
            // ),
            ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  CustomTextField(
                    label: 'Email',
                    obsecureText: false,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    textEditingController: emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'This is required';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Password',
                    obsecureText: true,
                    keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.none,
                    textEditingController: passwordController,
                    validator: (value) {
                      if (value!.length < 6) {
                        return 'Password strength must be more than 6';
                      } else if (value.isEmpty) {
                        return 'This is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    press: () {
                      if (!isLoading) {
                        logIn();
                      }
                    },
                    label: 'Log In',
                    btnColor: primaryColor,
                    textColor: Colors.white,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(6),
                            topLeft: Radius.circular(6),
                          ),
                        ),
                        child: Text(
                          'No account? ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.blue.shade100,
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpUi()));
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.6,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              // fontFamily: 'default',
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
