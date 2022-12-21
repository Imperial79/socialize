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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            'lib/assets/image/back.svg',
            color: primaryColor,
          ),
        ),
      ),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: widget.img,
          imageBuilder: (context, image) => PhotoView(
            // minScale: 0.15,
            backgroundDecoration: BoxDecoration(
              color: whiteColor,
            ),
            imageProvider: image,
            loadingBuilder: (context, ImageChunkEvent) => Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
