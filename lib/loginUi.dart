import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_route_transition/page_route_transition.dart';

import 'homeUi.dart';
import 'resources/auth.dart';
import 'resources/colors.dart';
import 'resources/myWidgets.dart';
import 'signupUi.dart';

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
        PageRouteTransition.pushReplacement(context, HomeUi());
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
                        'Social Media',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 30,
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
                      Text(
                        'No account? ',
                        style: TextStyle(
                          color: Colors.cyan.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          PageRouteTransition.effect = TransitionEffect.fade;
                          PageRouteTransition.pushReplacement(
                              context, SignUpUi());
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w800,
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
