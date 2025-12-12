import 'package:flutter/material.dart';

class Carga with ChangeNotifier{
  static bool _cargaBool = false;
  static Center carga() {
    return Center(child: CircularProgressIndicator(color: Color(0xFFF6AFCF)));
  }
  static Visibility ventanaCarga(){
    return Visibility(
      visible: _cargaBool,
      child: Container(
        decoration: BoxDecoration(color: Colors.black45),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFF6AFCF)),
        ),
      ),
    );
  }

  void cargaBool(bool boolean){
    _cargaBool = boolean;
    notifyListeners();
  }
}
