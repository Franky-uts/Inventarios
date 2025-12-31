import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Carga with ChangeNotifier {
  static bool _cargaBool = false;
  static bool _valido = false;

  static Center carga() {
    return Center(child: CircularProgressIndicator(color: Color(0xFFF6AFCF)));
  }

  static Consumer<Carga> ventanaCarga() {
    return Consumer<Carga>(
      builder: (context, carga, child) {
        return Visibility(
          visible: _cargaBool,
          child: Container(
            decoration: BoxDecoration(color: Colors.black45),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFF6AFCF)),
            ),
          ),
        );
      },
    );
  }

  void cargaBool(bool boolean) {
    _cargaBool = boolean;
    notifyListeners();
  }

  void valido(bool boolean) {
    _valido = boolean;
    notifyListeners();
  }

  static bool getValido() {
    return _valido;
  }
}
