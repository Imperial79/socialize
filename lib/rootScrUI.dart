import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socialize/chatsUi.dart';
import 'package:socialize/homeUI.dart';
import 'package:socialize/resources/user_details.dart';
import 'package:socialize/utilities/animated_indexed_stack.dart';
import 'myProfileUi.dart';
import 'resources/colors.dart';
import 'searchUi.dart';

class RootScr extends StatefulWidget {
  const RootScr({Key? key}) : super(key: key);

  @override
  _RootScrState createState() => _RootScrState();
}

class _RootScrState extends State<RootScr> with WidgetsBindingObserver {
  int selectedScreen = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(UserDetails.uid)
          .update({"active": "1"});
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(UserDetails.uid)
          .update({"active": "0"});
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: getFooter(),
      ),
    );
  }

  Widget getBody() {
    return AnimatedIndexedStack(
      index: selectedScreen,
      children: [
        HomeUI(),
        SearchUi(),
        ChatsUi(),
        ProfileUi(),
      ],
    );
  }

  Widget getFooter() {
    final List<Widget> items = [
      NavigationDestination(
        icon: SvgPicture.asset(
          'lib/assets/image/home.svg',
          height: 17,
        ),
        selectedIcon: SvgPicture.asset(
          'lib/assets/image/home_filled.svg',
          height: 17,
        ),
        label: 'Explore',
      ),
      NavigationDestination(
        icon: SvgPicture.asset(
          'lib/assets/image/search.svg',
          height: 17,
        ),
        selectedIcon: SvgPicture.asset(
          'lib/assets/image/search_filled.svg',
          height: 17,
        ),
        label: 'Search',
      ),
      NavigationDestination(
        icon: SvgPicture.asset(
          'lib/assets/image/chat.svg',
          height: 17,
        ),
        selectedIcon: SvgPicture.asset(
          'lib/assets/image/chat_filled.svg',
          height: 17,
        ),
        label: 'Chat',
      ),
      NavigationDestination(
        icon: SvgPicture.asset(
          'lib/assets/image/profile.svg',
          height: 17,
        ),
        selectedIcon: SvgPicture.asset(
          'lib/assets/image/profile_filled.svg',
          height: 17,
        ),
        label: 'Me',
        tooltip: 'Profile',
      ),
    ];

    return _buildBottomBar(items);
  }

  Widget _buildBottomBar(List<Widget> items) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          selectedScreen = index;
        });
        FocusScope.of(context).unfocus();
      },
      selectedIndex: selectedScreen,
      backgroundColor: whiteColor,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      animationDuration: Duration(milliseconds: 200),
      destinations: items,
    );
  }
}
