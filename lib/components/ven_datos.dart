import 'package:flutter/material.dart';

class VenDatos with ChangeNotifier {
  static List _artVen = [];
  static List _canVen = [];
  static List _canCubVen = [];
  static String _idVen = "";
  static String _remVen = "";
  static String _estVen = "";
  static String _modVen = "";
  static String _desVen = "";

  void setDatos(
    List artVen,
    List canVen,
    List canCubVen,
    String idVen,
    String remVen,
    String estVen,
    String modVen,
    String desVen,
  ) {
    _artVen = artVen;
    _canVen = canVen;
    _canCubVen = canCubVen;
    _idVen = idVen;
    _remVen = remVen;
    _estVen = estVen;
    _modVen = modVen;
    _desVen = desVen;
    notifyListeners();
  }

  int length() {
    return _artVen.length;
  }

  String artVen(int i) {
    return _artVen[i];
  }

  int canVen(int i) {
    return _canVen[i];
  }

  int canCubVen(int i) {
    return _canCubVen[i];
  }

  void canCubVenSub(int i) {
    _canCubVen[i]--;
    notifyListeners();
  }

  void canCubVenAdd(int i) {
    _canCubVen[i]++;
    notifyListeners();
  }

  List canCubVenLista() {
    return _canCubVen;
  }

  String idVen() {
    return _idVen;
  }

  String remVen() {
    return _remVen;
  }

  String estVen() {
    return _estVen;
  }

  String modVen() {
    return _modVen;
  }

  String desVen() {
    return _desVen;
  }
}
