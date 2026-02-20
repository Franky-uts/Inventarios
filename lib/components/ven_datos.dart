import 'package:flutter/material.dart';

class VenDatos with ChangeNotifier {
  static List<int> _idArt = [];
  static List<String> _art = [];
  static List<int> _can = [];
  static List<String> _are = [];
  static List<String> _tip = [];
  static List<int> _canCub = [];
  static List<double> _canAlm = [];
  static List<String> _comProv = [];
  static List<String> _comTienda = [];
  static List<bool> _comfProd = [];
  static String _id = '';
  static String _rem = '';
  static String _est = '';
  static String _mod = '';
  static String _loc = '';

  void setDatos(
    List<int> idArt,
    List<String> art,
    List<int> can,
    List<String> are,
    List<String> tip,
    List<int> canCub,
    List<double> canAlm,
    List<String> comProv,
    List<String> comTienda,
    List<bool> comfProd,
    String id,
    String rem,
    String est,
    String mod,
    String loc,
  ) {
    _idArt = idArt;
    _art = art;
    _can = can;
    _are = are;
    _tip = tip;
    _canCub = canCub;
    _canAlm = canAlm;
    _comProv = comProv;
    _comTienda = comTienda;
    _comfProd = comfProd;
    _id = id;
    _rem = rem;
    _est = est;
    _mod = mod;
    _loc = loc;
    notifyListeners();
  }

  int length() {
    return _art.length;
  }

  int idArt(int i) {
    return _idArt[i];
  }

  String art(int i) {
    return _art[i];
  }

  int can(int i) {
    return _can[i];
  }

  String are(int i) {
    return _are[i];
  }

  String tip(int i) {
    return _tip[i];
  }

  int canCub(int i) {
    return _canCub[i];
  }

  double canAlm(int i) {
    return _canAlm[i];
  }

  void canCubSub(int i) {
    _canAlm[i]++;
    _canCub[i]--;
    notifyListeners();
  }

  void canCubAdd(int i) {
    _canAlm[i]--;
    _canCub[i]++;
    notifyListeners();
  }

  List<int> canCubLista() {
    return _canCub;
  }

  String comTienda(int i) {
    return _comTienda[i];
  }

  String comProv(int i) {
    return _comProv[i];
  }

  List<String> comProvLista() {
    return _comProv;
  }

  void setComProv(int i, String comentario) {
    _comProv[i] = comentario;
    notifyListeners();
  }

  bool comfProd(int i) {
    return _comfProd[i];
  }

  List<bool> comfProdLista() {
    return _comfProd;
  }

  void setComfProd(int i) {
    _comfProd[i] = !_comfProd[i];
    notifyListeners();
  }

  String id() {
    return _id;
  }

  String rem() {
    return _rem;
  }

  String est() {
    return _est;
  }

  String mod() {
    return _mod;
  }

  String loc() {
    return _loc;
  }
}
