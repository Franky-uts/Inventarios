import 'package:flutter/material.dart';

class VenDatos with ChangeNotifier {
  static List _idArt = [];
  static List _artVen = [];
  static List _canVen = [];
  static List _areVen = [];
  static List _tipVen = [];
  static List _canCubVen = [];
  static List _comProv = [];
  static List _comTienda = [];
  static List _comfProd = [];
  static String _idVen = '';
  static String _remVen = '';
  static String _estVen = '';
  static String _modVen = '';
  static String _locVen = '';

  void setDatos(
    List idArt,
    List artVen,
    List canVen,
    List areVen,
    List tipVen,
    List canCubVen,
    List comprov,
    List comTienda,
    List comfProd,
    String idVen,
    String remVen,
    String estVen,
    String modVen,
    String locVen,
  ) {
    _idArt = idArt;
    _artVen = artVen;
    _canVen = canVen;
    _areVen = areVen;
    _tipVen = tipVen;
    _canCubVen = canCubVen;
    _comProv = comprov;
    _comTienda = comTienda;
    _comfProd = comfProd;
    _idVen = idVen;
    _remVen = remVen;
    _estVen = estVen;
    _modVen = modVen;
    _locVen = locVen;
    notifyListeners();
  }

  int length() {
    return _artVen.length;
  }

  int idArt(int i) {
    return _idArt[i];
  }

  String artVen(int i) {
    return _artVen[i];
  }

  int canVen(int i) {
    return _canVen[i];
  }

  String areVen(int i) {
    return _areVen[i];
  }

  String tipVen(int i) {
    return _tipVen[i];
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

  String comTienda(int i) {
    return _comTienda[i];
  }

  String comProv(int i) {
    return _comProv[i];
  }

  List comProvLista() {
    return _comProv;
  }

  void setComProv(int i, String comentario) {
    _comProv[i] = comentario;
    notifyListeners();
  }

  void setComProvLista(List lista) {
    _comProv = lista;
    notifyListeners();
  }

  bool comfProd(int i) {
    return _comfProd[i];
  }

  List comfProdLista() {
    return _comfProd;
  }

  void setComfProd(int i) {
    _comfProd[i] = !_comfProd[i];
    notifyListeners();
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
    return _locVen;
  }
}
