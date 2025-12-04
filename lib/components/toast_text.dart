import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ToastText {
  static void toast(String texto, bool longLength) {
    Toast length;
    if(longLength){
      length = Toast.LENGTH_LONG;
    }else{
      length = Toast.LENGTH_SHORT;
    }
    Fluttertoast.showToast(
      msg: texto,
      toastLength: length,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color(0xBFFDC930),
      textColor: Colors.white,
      fontSize: 15,
    );
  }
}
