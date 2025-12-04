import 'package:flutter/material.dart';

class Carga {
  static Center carga() {
    return Center(child: CircularProgressIndicator(color: Color(0xFFF6AFCF)));
  }
  static Visibility ventanaCarga(bool carga){
    return Visibility(
      visible: carga,
      child: Container(
        decoration: BoxDecoration(color: Colors.black45),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFF6AFCF)),
        ),
      ),
    );
  }
}
