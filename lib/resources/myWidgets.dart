import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class CustomButton extends StatelessWidget {
  final label;
  final btnColor;
  final textColor;
  final press;
  const CustomButton({
    this.btnColor,
    this.label,
    this.textColor,
    this.press,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: press,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: btnColor,
      elevation: 0,
      highlightElevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        width: double.infinity,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

showSnackBar(
  BuildContext context, {
  required String content,
  required Color color,
  required String svgIcon,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      backgroundColor: color,
      elevation: 0,
      content: Text(
        content,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 25,
        width: 25,
        child: CircularProgressIndicator(
          backgroundColor: Colors.teal.shade100.withOpacity(0.5),
          color: primaryColor,
        ),
      ),
    );
  }
}

class DummyPostCard extends StatelessWidget {
  const DummyPostCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  Container(
                    width: 200,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: 200,
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 300,
            width: double.infinity,
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DummyStoryCard extends StatelessWidget {
  const DummyStoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 100,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class DummySmallPost extends StatelessWidget {
  const DummySmallPost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (int i = 0; i < 3; i++)
          Expanded(
            child: Container(
              margin: EdgeInsets.all(5),
              height: 100,
              width: 50,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final label,
      obsecureText,
      textCapitalization,
      textEditingController,
      keyboardType,
      validator;
  CustomTextField({
    this.keyboardType,
    this.label,
    this.obsecureText,
    this.textCapitalization,
    this.textEditingController,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade600.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            cursorColor: primaryColor,
            controller: textEditingController,
            obscureText: obsecureText,
            textCapitalization: textCapitalization,
            keyboardType: keyboardType,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              enabledBorder: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                borderSide: BorderSide(
                  color: primaryColor,
                  width: 5,
                ),
              ),
              labelText: label,
              labelStyle: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }
}
