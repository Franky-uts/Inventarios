import 'package:flutter/material.dart';
import 'package:inventarios/models/orden_model.dart';

class VenDatos with ChangeNotifier {
  static OrdenModel _orden = OrdenModel.dummy('');
  static List<OrdenListas> _listas = [];
  static bool _edit = false;

  //Este es un método set que trabaja directamente con las ventanas que usan
  //tablas, únicamente con las que tienen que ver con las órdenes, se guarda la
  //orden, en la variable "_orden", también se limpia la variable "_listas",
  //esta variable guarda los arreglos relacionados con la información de la
  //orden (nombre, cantidad, tipo, área, cantidad que se cubrió, comentarios,
  //confirmación y id de cada uno de los artículos relacionados con una orden),
  //después se guardan los datos de los arreglos en la variable "_listas".
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
          mensaje: '',
        ),
      );
    }
    notifyListeners();
  }

  //Esta función ordenas los valores en la variable "_listas", listas guarda
  //todos los arreglos con información relacionados a la orden, ordenando estos
  //arreglos ya sea por ID o de manera alfabética, dependiendo del parámetro
  //booleano inicial llamado "nom", si se declara como true entonces se ordenara
  //primero de manera alfabética y luego por áreas, en caso contrario si se
  //declara false entonces se ordenara por ID.
  void ordenarPor(bool nom) {
    if (nom) {
      _listas.sort((a, b) {
        return a.art.toLowerCase().compareTo(b.art.toLowerCase());
      });
      _listas.sort((a, b) {
        return a.area.toLowerCase().compareTo(b.area.toLowerCase());
      });
    } else {
      _listas.sort((a, b) {
        return a.id.compareTo(b.id);
      });
    }
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

  //Método get para toda la información de la orden, en un principio se
  //utilizaba para obtener los datos individuales de toda la orden, pero
  //consumía más recursos que llamar a un método individual por cada dato en
  //la orden, ahora solo se usa al momento de imprimir una orden.
  OrdenModel getDatos() {
    return _orden;
  }

  //Método set que establece el valor de la variable "_edit", esta variable se
  //utiliza para saber si la lista va a editar las confirmaciones en un pedido
  //si este tiene el estado de Finalizado o incompleto, solo se puede usar del
  //lado de los empleados.
  void setEdit(bool bool) {
    _edit = bool;
    notifyListeners();
  }

  //Método get que regresa el valor de la variable "_edit"
  bool edit() {
    return _edit;
  }

  //Método get que regresa la cantidad de artículos ordenados.
  int length() {
    return _orden.cantArticulos;
  }

  //Método get que regresa la cantidad de artículos ordenados.
  int idArt(int i) {
    return _orden.idProductos[i];
  }

  //Método get que regresa el nombre del artículo relacionado con su posición
  //en la lista, requiere un integer relacionado con la posición que se desea
  //consultar.
  String art(int i) {
    return _orden.articulos[i];
  }

  //Método get que regresa la cantidad del artículo ordenado relacionado con su
  //posición en la lista, requiere un integer relacionado con la posición que se
  //quiere consultar.
  double can(int i) {
    return _orden.cantidades[i];
  }

  //Método get que regresa el área del artículo ordenado relacionado con su
  //posición en la lista, requiere un integer relacionado con la posición que se
  //necesita consultar.
  String are(int i) {
    return _orden.areas[i];
  }

  //Método get que regresa el tipo del artículo ordenado relacionado con su
  //posición en la lista, requiere un integer relacionado con la posición que se
  //requiere consultar.
  String tip(int i) {
    return _orden.tipos[i];
  }

  //Método get que regresa la cantidad cubierta por el almacén del artículo
  //ordenado con su posición en la lista, requiere un integer relacionado con la
  //posición que se pretende consultar.
  double canCub(int i) {
    return _orden.cantidadesCubiertas[i];
  }

  //Método set en el cual cambia el valor de la cantidad cubierta por el almacén
  //relacionado con su posición en la lista, requiere un integer con la posición
  //que se anhela cambiar y el nuevo valor que tendrá la posición.
  void canCubChange(int i, double cant) {
    _listas[i].cantCub = cant;
    _orden.cantidadesCubiertas[i] = cant;
    notifyListeners();
  }

  //Método get que regresa la lista de las cantidades cubiertas por el almacén
  //de los artículos ordenados.
  List canCubLista() {
    return _orden.cantidadesCubiertas;
  }

  //Método get que regresa el comentario de la tienda acorde con artículo
  //ordenado con su posición en la lista, requiere un integer relacionado con la
  //posición que se aspira consultar.
  String comTienda(int i) {
    return _orden.comentariosTienda[i];
  }

  //Método get que regresa el comentario del proveedor acorde con artículo
  //ordenado con su posición en la lista, requiere un integer relacionado con la
  //posición que se te antoja consultar.
  String comProv(int i) {
    return _orden.comentariosProveedor[i];
  }

  //Método get que regresa la lista de los comentarios del proveedor de los
  //artículos ordenados.
  List comProvLista() {
    return _orden.comentariosProveedor;
  }

  //Método set en el cual cambia el comentario del proveedor relacionado con su
  //posición en la lista, requiere un integer con la posición que se ansia
  //cambiar y el nuevo valor que tendrá la posición.
  void setComProv(int i, String comentario) {
    _listas[i].comProv = comentario;
    _orden.comentariosProveedor[i] = comentario;
    notifyListeners();
  }

  //Método get que regresa el comentario final de la tienda acorde con artículo
  //ordenado con su posición en la lista, requiere un integer relacionado con la
  //posición que se ambiciona consultar.
  String comFin(int i) {
    return _orden.comentariosFinales[i];
  }

  //Método set en el cual cambia el comentario final de la tienda relacionado
  //en su posición en la lista, requiere un integer con la posición que se pide
  //cambiar y el nuevo valor que tendrá la posición.
  void setComFin(int i, String comentario) {
    _listas[i].comFin = comentario;
    _orden.comentariosFinales[i] = comentario;
    notifyListeners();
  }

  //Método get que regresa la confirmación acorde con artículo ordenado con su
  //ubicación en la lista, requiere un integer relacionado con la posición que
  //se exige consultar.
  bool comfProd(int i) {
    return _orden.confirmacion[i];
  }

  //Método get que regresa la lista de las confiramciones de los artículos
  //ordenados.
  List comfProdLista() {
    return _orden.confirmacion;
  }

  //Método set en el cual cambia la confirmación de acuerdo con una posición en
  //la lista, requiere un integer con la posición que se precisa cambiar y el
  //nuevo valor que tendrá la posición.
  void setComfProd(int i) {
    _listas[i].conf = !_listas[i].conf;
    _orden.confirmacion[i] = !_orden.confirmacion[i];
    notifyListeners();
  }

  //No recuerdo para qué hice este método, quiero decir, sirve para cambiar el
  //valor de un mensaje en la lista de mensajes, pero no recuerdo para qué creé
  //este método, al parecer se utiliza para manejar errores, pero el código
  //esta sin comentar y hace tiempo que no leo el código (me accidente hace 5
  //meses y apenas estoy comentando para qué sirve cada cosa), quizá en un
  //futuro lo corrija, pero ahora tengo otras cosas por hacer.
  void setMen(int i, String mensaje) {
    _listas[i].mensaje = mensaje;
  }

  //Este es el get del set anterior, por lo que veo regresara el área si este es
  //un error o algo por el estilo, sin alguna idea de porque implemente esto.
  String getMensaje(int i) {
    return _listas[i].mensaje;
  }

  //Método get que regresa el ID en forma de String relacionada con la orden.
  String id() {
    return '${_orden.id}';
  }

  //Método get que regresa el nombre del remitente relacionado con la orden.
  String rem() {
    return _orden.remitente;
  }

  //Método get que regresa el estado actual relacionado con la orden.
  String est() {
    return _orden.estado;
  }

  //Método get que regresa la fecha en que se creó la orden.
  String fecha() {
    return _orden.fechaOrden;
  }

  //Método get que regresa la fecha en que se modificó por última vez la orden.
  String mod() {
    return _orden.ultimaModificacion;
  }

  //Método get que regresa el nombre de la tienda donde creó la orden.
  String loc() {
    return _orden.locacion;
  }
}
