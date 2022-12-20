import 'package:flutter/material.dart';

Widget ShowModal(String blogId) {
  return SafeArea(
    child: StatefulBuilder(builder: (context, StateSetter setModalState) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actions',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 50,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: () {},
                color: Colors.grey.shade200,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.grey.shade800,
                      ),
                      Text(
                        'Delete Blog',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: 0.7,
                          color: Colors.grey.shade800,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }),
  );
}

Future NavPush(context, screen) async {
  await Navigator.push(
      context, MaterialPageRoute(builder: (context) => screen));
}

Future NavPushReplacement(BuildContext context, screen) async {
  await Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => screen));
}

SnackBarThemeData SnackBarTheme() {
  return SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    contentTextStyle: TextStyle(
      fontFamily: 'Product',
    ),
  );
}
