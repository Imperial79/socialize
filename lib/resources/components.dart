import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

void downloadFile(String url, BuildContext context) async {
  try {
    Directory directory;
    if (await _requestpermission(Permission.storage)) {
      directory = (await getExternalStorageDirectory())!;
      //till now we have got the basic default address storage that is at /storage/emulated/0/Android/data/..........
      String newpath = "";
      List<String> folders =
          directory.path.split("/"); //to reach the Android folder
      for (int x = 1; x < folders.length; x++) {
        //x=1 because at x=0 is empty
        String folder = folders[x];
        if (folder != "Android") {
          newpath += "/" + folder;
        } else {
          break;
        }
      }
      newpath = newpath + "/Socialize";
      directory = Directory(newpath);

      if (!await directory.exists()) {
        //if directory extracted does not exists, create one
        await directory.create(recursive: true);
      }

      final file = File("${directory.path}/${url.substring(43)}");

      var response = await Dio().get(
        url,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: 0),
      );
      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Success!! Saved to documents/Socialize",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed!! Storage Access Denied",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Failed!! Please check your internet connection",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<bool> _requestpermission(Permission permission) async {
  //to check if user accepted the permissions
  if (await permission.isGranted) {
    return true;
  } else {
    var result =
        await permission.request(); //request permission again to the user
    if (result == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}
