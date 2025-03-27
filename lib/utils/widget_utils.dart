import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WidgetUtils {
  Widget showProgress() {
    return Dialog(
      backgroundColor: Colors.white,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0),
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Please wait",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> showToast(String msg) {
    return Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        gravity: ToastGravity.CENTER);
  }
}
