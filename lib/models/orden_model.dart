import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/local_storage.dart';

class OrdenModel {
  int id;
  List<String> articulos;
  List<int> cantidades;
  List<String> tipos;
  List<String> areas;
  List<int> cantidadesCubiertas;
  List<String> comentariosTienda;
  List<String> comentariosProveedor;
  List<bool> confirmacion;
  List<int> idProductos;
  int cantArticulos;
  String estado;
  String remitente;
  String ultimaModificacion;
  String locacion;
  String mensaje;

  OrdenModel({
    required this.id,
    required this.articulos,
    required this.cantidades,
    required this.tipos,
    required this.areas,
    required this.cantidadesCubiertas,
    required this.comentariosProveedor,
    required this.comentariosTienda,
    required this.confirmacion,
    required this.idProductos,
    required this.cantArticulos,
    required this.estado,
    required this.remitente,
    required this.ultimaModificacion,
    required this.locacion,
    required this.mensaje,
  });

  static Future<List<OrdenModel>> getOrdenes(
    String filtro,
    String locacion,
  ) async {
    String conexion = LocalStorage.local('conexion');
    List<OrdenModel> ordenesFuture = [];
    try {
      var res = await http.get(
        Uri.parse('$conexion/ordenes/$filtro/$locacion'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          ordenesFuture.add(
            OrdenModel(
              id: item['id'],
              articulos: [],
              cantidades: [],
              tipos: [],
              areas: [],
              cantidadesCubiertas: [],
              comentariosProveedor: [],
              comentariosTienda: [],
              confirmacion: [],
              idProductos: [],
              cantArticulos: item['CantArticulos'],
              estado: item['Estado'],
              remitente: item['Remitente'],
              ultimaModificacion: item['UltimaModificación'],
              locacion: '',
              mensaje: '',
            ),
          );
        }
      } else {
        ordenesFuture.add(
          OrdenModel(
            id: 0,
            articulos: [],
            cantidades: [],
            tipos: [],
            areas: [],
            cantidadesCubiertas: [],
            comentariosProveedor: [],
            comentariosTienda: [],
            confirmacion: [],
            idProductos: [],
            cantArticulos: 0,
            estado: '',
            remitente: '',
            ultimaModificacion: '',
            locacion: '',
            mensaje: res.body,
          ),
        );
      }
    } on TimeoutException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ['Error'],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          comentariosProveedor: [],
          comentariosTienda: [],
          confirmacion: [],
          idProductos: [],
          cantArticulos: 0,
          estado: '',
          remitente: '',
          ultimaModificacion: '',
          locacion: '',
          mensaje: '${e.message}',
        ),
      );
    } on SocketException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ['Error'],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          comentariosProveedor: [],
          comentariosTienda: [],
          confirmacion: [],
          idProductos: [],
          cantArticulos: 0,
          estado: '',
          remitente: '',
          ultimaModificacion: '',
          locacion: '',
          mensaje: e.message,
        ),
      );
    } on http.ClientException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ['Error'],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          comentariosProveedor: [],
          comentariosTienda: [],
          confirmacion: [],
          idProductos: [],
          cantArticulos: 0,
          estado: '',
          remitente: '',
          ultimaModificacion: '',
          locacion: '',
          mensaje: e.message,
        ),
      );
    } on Error catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ['Error'],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          comentariosProveedor: [],
          comentariosTienda: [],
          confirmacion: [],
          idProductos: [],
          cantArticulos: 0,
          estado: '',
          remitente: '',
          ultimaModificacion: '',
          locacion: '',
          mensaje: '$e',
        ),
      );
    }
    return ordenesFuture;
  }

  static Future<List<OrdenModel>> getAllOrdenes(String filtro) async {
    String conexion = LocalStorage.local('conexion');
    List<OrdenModel> ordenesFuture = [];
    try {
      var res = await http.get(
        Uri.parse('$conexion/ordenes/$filtro'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          ordenesFuture.add(
            OrdenModel(
              id: item['id'],
              articulos: [],
              cantidades: [],
              tipos: [],
              areas: [],
              cantidadesCubiertas: [],
              comentariosProveedor: [],
              comentariosTienda: [],
              confirmacion: [],
              idProductos: [],
              cantArticulos: item['CantArticulos'],
              estado: item['Estado'],
              remitente: item['Remitente'],
              ultimaModificacion: item['UltimaModificación'],
              locacion: item['Locacion'],
              mensaje: '',
            ),
          );
        }
      } else {
        ordenesFuture.add(
          OrdenModel(
            id: 0,
            articulos: [],
            cantidades: [],
            tipos: [],
            areas: [],
            cantidadesCubiertas: [],
            comentariosProveedor: [],
            comentariosTienda: [],
            confirmacion: [],
            idProductos: [],
            cantArticulos: 0,
            estado: '',
            remitente: '',
            ultimaModificacion: '',
            locacion: '',
            mensaje: res.body,
          ),
        );
      }
    } on TimeoutException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ['Error'],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          comentariosProveedor: [],
          comentariosTienda: [],
          confirmacion: [],
          idProductos: [],
          cantArticulos: 0,
          estado: '',
          remitente: '',
          ultimaModificacion: '',
          locacion: '',
          mensaje: '${e.message}',
        ),
      );
    } on SocketException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ['Error'],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          comentariosProveedor: [],
          comentariosTienda: [],
          confirmacion: [],
          idProductos: [],
          cantArticulos: 0,
          estado: '',
          remitente: '',
          ultimaModificacion: '',
          locacion: '',
          mensaje: e.message,
        ),
      );
    } on http.ClientException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ['Error'],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          comentariosProveedor: [],
          comentariosTienda: [],
          confirmacion: [],
          idProductos: [],
          cantArticulos: 0,
          estado: '',
          remitente: '',
          ultimaModificacion: '',
          locacion: '',
          mensaje: e.message,
        ),
      );
    } on Error catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ['Error'],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          comentariosProveedor: [],
          comentariosTienda: [],
          confirmacion: [],
          idProductos: [],
          cantArticulos: 0,
          estado: '',
          remitente: '',
          ultimaModificacion: '',
          locacion: '',
          mensaje: '$e',
        ),
      );
    }
    return ordenesFuture;
  }

  static Future<OrdenModel> getOrden(int id) async {
    String conexion = LocalStorage.local('conexion');
    OrdenModel orden;
    try {
      var res = await http.get(
        Uri.parse('$conexion/ordenes/Orden/$id'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      orden = OrdenModel(
        id: 0,
        articulos: [],
        cantidades: [],
        tipos: [],
        areas: [],
        cantidadesCubiertas: [],
        comentariosProveedor: [],
        comentariosTienda: [],
        confirmacion: [],
        idProductos: [],
        cantArticulos: 0,
        estado: '',
        remitente: '',
        ultimaModificacion: '',
        locacion: '',
        mensaje: res.body,
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          orden = OrdenModel(
            id: item['id'],
            articulos: List<String>.from(item['Articulos']),
            cantidades: List<int>.from(item['Cantidades']),
            tipos: List<String>.from(item['Tipos']),
            areas: List<String>.from(item['Areas']),
            cantidadesCubiertas: List<int>.from(item['CantidadesCubiertas']),
            comentariosProveedor: List<String>.from(
              item['ComentariosProveedor'],
            ),
            comentariosTienda: List<String>.from(item['ComentariosTienda']),
            confirmacion: List<bool>.from(item['Confirmacion']),
            idProductos: List<int>.from(item['idProductos']),
            cantArticulos: item['CantArticulos'],
            estado: item['Estado'],
            remitente: item['Remitente'],
            ultimaModificacion: item['UltimaModificación'],
            locacion: item['Locacion'],
            mensaje: '',
          );
        }
      }
    } on TimeoutException catch (e) {
      orden = OrdenModel(
        id: 0,
        articulos: [],
        cantidades: [],
        tipos: [],
        areas: [],
        cantidadesCubiertas: [],
        comentariosProveedor: [],
        comentariosTienda: [],
        confirmacion: [],
        idProductos: [],
        cantArticulos: 0,
        estado: '',
        remitente: '',
        ultimaModificacion: '',
        locacion: '',
        mensaje: '${e.message}',
      );
    } on SocketException catch (e) {
      orden = OrdenModel(
        id: 0,
        articulos: [],
        cantidades: [],
        tipos: [],
        areas: [],
        cantidadesCubiertas: [],
        comentariosProveedor: [],
        comentariosTienda: [],
        confirmacion: [],
        idProductos: [],
        cantArticulos: 0,
        estado: '',
        remitente: '',
        ultimaModificacion: '',
        locacion: '',
        mensaje: e.message,
      );
    } on http.ClientException catch (e) {
      orden = OrdenModel(
        id: 0,
        articulos: [],
        cantidades: [],
        tipos: [],
        areas: [],
        cantidadesCubiertas: [],
        comentariosProveedor: [],
        comentariosTienda: [],
        confirmacion: [],
        idProductos: [],
        cantArticulos: 0,
        estado: '',
        remitente: '',
        ultimaModificacion: '',
        locacion: '',
        mensaje: e.message,
      );
    } on Error catch (e) {
      orden = OrdenModel(
        id: 0,
        articulos: [],
        cantidades: [],
        tipos: [],
        areas: [],
        cantidadesCubiertas: [],
        comentariosProveedor: [],
        comentariosTienda: [],
        confirmacion: [],
        idProductos: [],
        cantArticulos: 0,
        estado: '',
        remitente: '',
        ultimaModificacion: '',
        locacion: '',
        mensaje: '$e',
      );
    }
    return orden;
  }

  static Future<String> postOrden(
    List<int> idProductos,
    List<int> cantidades,
    List<String> comentarios,
  ) async {
    String remitente = LocalStorage.local('usuario');
    String productoFuture;
    try {
      final res = await http.post(
        Uri.parse('${LocalStorage.local('conexion')}/ordenes/'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'cantidades': cantidades,
          'comentarios': comentarios,
          'idProductos': idProductos,
          'remitente': remitente,
        }),
      );
      productoFuture = res.body;
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          productoFuture = '${item['id']}';
        }
      }
    } on TimeoutException catch (e) {
      productoFuture = 'Error: ${e.message}';
    } on SocketException catch (e) {
      productoFuture = 'Error: ${e.message}';
    } on http.ClientException catch (e) {
      productoFuture = 'Error: ${e.message}';
    } on Error catch (e) {
      productoFuture = 'Error: $e';
    }
    return productoFuture;
  }

  static Future<String> editarOrden(
    String id,
    String columna,
    String dato,
  ) async {
    String respuesta;
    if (columna == 'Estado') {
      dato = '${dato[0].toUpperCase()}${dato.substring(1, dato.length)}';
    }
    try {
      final res = await http.put(
        Uri.parse('${LocalStorage.local('conexion')}/ordenes/$id/$columna'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dato': dato}),
      );
      respuesta = '${res.reasonPhrase}';
      if (res.statusCode == 200) {
        respuesta = 'Se modificó la orden.';
      }
    } on TimeoutException catch (e) {
      respuesta = 'Error: ${e.message}';
    } on SocketException catch (e) {
      respuesta = 'Error: ${e.message}';
    } on http.ClientException catch (e) {
      respuesta = 'Error: ${e.message}';
    } on Error catch (e) {
      respuesta = 'Error: $e';
    }
    return respuesta;
  }

  static Future<String> editarOrdenConfirmacion(
    String id,
    String estado,
    List confirmaciones,
  ) async {
    String respuesta;
    try {
      final res = await http.put(
        Uri.parse('${LocalStorage.local('conexion')}/ordenes/$id/confirmacion'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'estado': estado, 'confirmacion': confirmaciones}),
      );
      respuesta = '${res.reasonPhrase}';
      if (res.statusCode == 200) {
        respuesta = 'Se modificó la orden.';
      }
    } on TimeoutException catch (e) {
      respuesta = 'Error: ${e.message}';
    } on SocketException catch (e) {
      respuesta = 'Error: ${e.message}';
    } on http.ClientException catch (e) {
      respuesta = 'Error: ${e.message}';
    } on Error catch (e) {
      respuesta = 'Error: $e';
    }
    return respuesta;
  }
}
