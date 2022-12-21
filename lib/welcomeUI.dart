import 'package:flutter/material.dart';
import 'loginUi.dart';
import 'resources/colors.dart';
import 'resources/myWidgets.dart';
import 'registerUI.dart';

class WelcomeUI extends StatefulWidget {
  const WelcomeUI({Key? key}) : super(key: key);

  @override
  State<WelcomeUI> createState() => _WelcomeUIState();
}

class _WelcomeUIState extends State<WelcomeUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage(
            //     'lib/assets/image/back.jpg',
            //   ),
            //   fit: BoxFit.cover,
            //   // opacity: 0.5,
            //   colorFilter: ColorFilter.mode(
            //     whiteColor.withOpacity(0.6),
            //     BlendMode.colorDodge,
            //   ),
            // ),
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
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              CustomButton(
                child: Text(
                  'Log in existing account',
                  style: TextStyle(color: whiteColor),
                ),
                btnColor: primaryColor,
                press: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginUi()));
                },
              ),
              SizedBox(
                height: 10,
              ),
              CustomButton(
                child: Text(
                  'Register for new acocunt',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                btnColor: Colors.grey.shade100,
                press: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpUi()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
