import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:photo_view/photo_view.dart';

import 'resources/colors.dart';

class ZoomImageUi extends StatefulWidget {
  final img;
  ZoomImageUi({this.img});

  @override
  State<ZoomImageUi> createState() => _ZoomImageUiState();
}

class _ZoomImageUiState extends State<ZoomImageUi> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            PageRouteTransition.effect = TransitionEffect.fade;
            PageRouteTransition.pop(context);
          },
          icon: SvgPicture.asset(
            'lib/assets/image/back.svg',
            color: primaryColor,
          ),
        ),
      ),
      body: CachedNetworkImage(
        imageUrl: widget.img,
        imageBuilder: (context, image) => PhotoView(
          // minScale: 0.15,
          backgroundDecoration: BoxDecoration(
            color: Colors.white,
          ),
          imageProvider: image,
          loadingBuilder: (context, ImageChunkEvent) => Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
