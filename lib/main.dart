import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:socialize/rootScrUI.dart';
import 'package:socialize/resources/auth.dart';
import 'package:socialize/resources/colors.dart';
import 'package:socialize/registerUI.dart';
import 'package:socialize/welcomeUI.dart';

import 'resources/user_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBZXfh9ULKQIkIj2pdEX-0-qoAt5ZRhyGQ",
      appId: "1:1056241384742:android:58fb12ff3124435c8855e7",
      messagingSenderId: "1056241384742",
      projectId: "socialize-a0f1d",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    configOneSignel();
  }

  void configOneSignel() {
    OneSignal.shared.setAppId(kAppId);
  }

  @override
  Widget build(BuildContext context) {
    PageRouteTransition.effect = TransitionEffect.rightToLeft;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Socialize',
      color: primaryColor,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        colorSchemeSeed: primaryColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: FutureBuilder(
        future: AuthMethods().getCurrentuser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RootScr();
          } else {
            return WelcomeUI();
          }
        },
      ),
    );
  }
}
