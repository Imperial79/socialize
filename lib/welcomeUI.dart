import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_route_transition/page_route_transition.dart';

import 'loginUi.dart';
import 'resources/colors.dart';
import 'resources/myWidgets.dart';
import 'signupUi.dart';

class WelcomeUI extends StatefulWidget {
  const WelcomeUI({Key? key}) : super(key: key);

  @override
  State<WelcomeUI> createState() => _WelcomeUIState();
}

class _WelcomeUIState extends State<WelcomeUI> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'lib/assets/image/back.jpg',
            ),
            fit: BoxFit.cover,
            // opacity: 0.5,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.6),
              BlendMode.colorDodge,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Socialize',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              CustomButton(
                label: 'Log in existing acocunt',
                textColor: Colors.white,
                btnColor: primaryColor,
                press: () {
                  PageRouteTransition.effect = TransitionEffect.fade;
                  PageRouteTransition.push(context, LoginUi());
                },
              ),
              SizedBox(
                height: 10,
              ),
              CustomButton(
                label: 'Register for new acocunt',
                btnColor: Colors.white,
                textColor: primaryColor,
                press: () {
                  PageRouteTransition.push(context, SignUpUi());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
