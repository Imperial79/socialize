import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'resources/colors.dart';
import 'resources/database.dart';
import 'resources/myWidgets.dart';
import 'services/pickImage.dart';

class AddStoryUi extends StatefulWidget {
  const AddStoryUi({Key? key}) : super(key: key);

  @override
  _AddStoryUiState createState() => _AddStoryUiState();
}

class _AddStoryUiState extends State<AddStoryUi> {
  bool isLoading = false;
  Uint8List? _file = null;
  final captionController = TextEditingController();

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  selectPhoto(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
          height: 170,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Image',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          Uint8List file = await pickImage(ImageSource.gallery);
                          setState(() {
                            _file = file;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: Color(0xFFFCE0EA),
                          radius: 30,
                          child: SvgPicture.asset(
                            'lib/assets/image/picture.svg',
                            color: Colors.pink.shade600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        'Gallery',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          Uint8List file = await pickImage(ImageSource.camera);
                          setState(() {
                            _file = file;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 220, 239, 255),
                          radius: 30,
                          child: SvgPicture.asset(
                            'lib/assets/image/camera.svg',
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  uploadStory() async {
    FocusScope.of(context).unfocus();
    if (_file != null) {
      try {
        setState(() {
          isLoading = true;
        });

        String res =
            await DatabaseMethods().uploadStory(_file!, captionController.text);

        if (res == 'success') {
          setState(() {
            isLoading = false;
            _file = null;
            captionController.clear();
          });
          FocusScope.of(context).unfocus();
          showSnackBar(
            context,
            content: 'Posted!',
            color: Colors.green.shade800,
            svgIcon: 'success.svg',
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e.toString());
        showSnackBar(
          context,
          content: 'Error Occurred',
          color: Colors.red.shade800,
          svgIcon: 'error.svg',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add a Story',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: _file == null
                    ? GestureDetector(
                        onTap: () {
                          selectPhoto(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add,
                            color: primaryColor,
                            size: 70,
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: MemoryImage(_file!),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  _file = null;
                                  setState(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.shade100,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    'Remove',
                                    style: TextStyle(
                                      color: Colors.cyan.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              _file == null
                  ? Container()
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: captionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        autofocus: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                          hintText: "Caption...",
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          top: 10,
          left: 15,
          right: 15,
        ),
        child: MaterialButton(
          onPressed: () {
            uploadStory();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          color: primaryColor,
          elevation: 0,
          highlightElevation: 0,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'Add to Story',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
