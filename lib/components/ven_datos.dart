import 'package:flutter/material.dart';
import 'package:inventarios/models/orden_model.dart';

class VenDatos with ChangeNotifier {
  static OrdenModel _orden = OrdenModel.dummy('');
  static List<OrdenListas> _listas = [];
  static bool _edit = false;

  void setDatos(OrdenModel orden) {
    _orden = orden;
    _listas.clear();
    for (int i = 0; i < _orden.cantArticulos; i++) {
      _listas.add(
        OrdenListas(
          art: _orden.articulos[i],
          cant: _orden.cantidades[i],
          tipo: _orden.tipos[i],
          area: _orden.areas[i],
          cantCub: _orden.cantidadesCubiertas[i],
          comTienda: _orden.comentariosTienda[i],
          comProv: _orden.comentariosProveedor[i],
          comFin: _orden.comentariosFinales[i],
          conf: _orden.confirmacion[i],
          id: _orden.idProductos[i],
          mensaje: ''
        ),
      );
    }
    notifyListeners();
  }

  void ordenarPor(bool nom) {
    nom
        ? {
            _listas.sort((a, b) {
              return a.art.toLowerCase().compareTo(b.art.toLowerCase());
            }),
            _listas.sort((a, b) {
              return a.area.toLowerCase().compareTo(b.area.toLowerCase());
            }),
          }
        : _listas.sort((a, b) {
            return a.id.compareTo(b.id);
          });
    for (int i = 0; i < _orden.cantArticulos; i++) {
      _orden.idProductos[i] = _listas[i].id;
      _orden.articulos[i] = _listas[i].art;
      _orden.cantidades[i] = _listas[i].cant;
      _orden.cantidadesCubiertas[i] = _listas[i].cantCub;
      _orden.tipos[i] = _listas[i].tipo;
      _orden.areas[i] = _listas[i].area;
      _orden.comentariosTienda[i] = _listas[i].comTienda;
      _orden.comentariosProveedor[i] = _listas[i].comProv;
      _orden.comentariosFinales[i] = _listas[i].comFin;
      _orden.confirmacion[i] = _listas[i].conf;
    }
    if (nom) notifyListeners();
  }

  OrdenModel getDatos() {
    return _orden;
  }

  bool edit() {
    return _edit;
  }

  void setEdit(bool bool) {
    _edit = bool;
    notifyListeners();
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

  double can(int i) {
    return _orden.cantidades[i];
  }

  String are(int i) {
    return _orden.areas[i];
  }

  String tip(int i) {
    return _orden.tipos[i];
  }

  double canCub(int i) {
    return _orden.cantidadesCubiertas[i];
  }

  void canCubChange(int i, double cant) {
    _listas[i].cantCub = cant;
    _orden.cantidadesCubiertas[i] = cant;
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
    _listas[i].comProv = comentario;
    _orden.comentariosProveedor[i] = comentario;
    notifyListeners();
  }

  String comFin(int i) {
    return _orden.comentariosFinales[i];
  }

  void setComFin(int i, String comentario) {
    _listas[i].comFin = comentario;
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
    _listas[i].conf = !_listas[i].conf;
    _orden.confirmacion[i] = !_orden.confirmacion[i];
    notifyListeners();
  }

  void setMen(int i, String mensaje) {
    _listas[i].mensaje = mensaje;
  }

  String getMensaje(int i) {
    return _listas[i].mensaje;
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
