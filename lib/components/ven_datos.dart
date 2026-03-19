import 'package:flutter/material.dart';
import 'package:inventarios/models/orden_model.dart';

class VenDatos with ChangeNotifier {
  static OrdenModel _orden = OrdenModel.dummy('');

  void setDatos(OrdenModel orden) {
    _orden = orden;
    notifyListeners();
  }

  OrdenModel getDatos() {
    return _orden;
  }

  int length() {
    return _orden.cantArticulos;
  }

  int idArt(int i) {
    return _orden.idProductos[i];
  }

  String art(int i) {
    return _orden.articulos[i];
  }

  int can(int i) {
    return _orden.cantidades[i];
  }

  String are(int i) {
    return _orden.areas[i];
  }

  String tip(int i) {
    return _orden.tipos[i];
  }

  int canCub(int i) {
    return _orden.cantidadesCubiertas[i];
  }

  void canCubSub(int i) {
    _orden.cantidadesCubiertas[i]--;
    notifyListeners();
  }

  void canCubAdd(int i) {
    _orden.cantidadesCubiertas[i]++;
    notifyListeners();
  }

  List canCubLista() {
    return _orden.cantidadesCubiertas;
  }

  String comTienda(int i) {
    return _orden.comentariosTienda[i];
  }

  String comProv(int i) {
    return _orden.comentariosProveedor[i];
  }

  List comProvLista() {
    return _orden.comentariosProveedor;
  }

  void setComProv(int i, String comentario) {
    _orden.comentariosProveedor[i] = comentario;
    notifyListeners();
  }

  String comFin(int i) {
    return _orden.comentariosFinales[i];
  }

  void setComFin(int i, String comentario) {
    _orden.comentariosFinales[i] = comentario;
    notifyListeners();
  }

  bool comfProd(int i) {
    return _orden.confirmacion[i];
  }

  List comfProdLista() {
    return _orden.confirmacion;
  }

  void setComfProd(int i) {
    _orden.confirmacion[i] = !_orden.confirmacion[i];
    notifyListeners();
  }

  String id() {
    return '${_orden.id}';
  }

  String rem() {
    return _orden.remitente;
  }

  String est() {
    return _orden.estado;
  }

  String fecha() {
    return _orden.fechaOrden;
  }

  String mod() {
    return _orden.ultimaModificacion;
  }

  String loc() {
    return _orden.locacion;
  }
}
