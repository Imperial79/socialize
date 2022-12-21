import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:socialize/utilities/sdp.dart';
import 'rootScrUI.dart';
import 'services/auth.dart';
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
      FocusScope.of(context).unfocus();

      setState(() {
        isLoading = true;
      });
      String res = await AuthMethods().logInUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res == 'Success') {
        PageRouteTransition.pushReplacement(context, RootScr());
      } else {
        showSnackBar(
          context,
          content: res,
          color: Colors.red.shade800,
          svgIcon: 'error.svg',
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      child: FittedBox(
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
                  ),
                  CustomTextField(
                    label: 'Email',
                    obsecureText: false,
                    maxLines: 1,
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
                    maxLines: 1,
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
                    child: Visibility(
                      visible: !isLoading,
                      child: Text(
                        "Log In",
                        style: TextStyle(
                            color: whiteColor, fontSize: sdp(context, 15)),
                      ),
                      replacement: CircularProgressIndicator(color: whiteColor),
                    ),
                    btnColor: primaryColor,
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
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          fontSize: sdp(context, 12),
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
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
