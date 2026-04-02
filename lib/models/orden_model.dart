import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:inventarios/main.dart';
import 'dart:convert';
import '../services/local_storage.dart';

class OrdenModel {
  int id;
  List<String> articulos;
  List<double> cantidades;
  List<String> tipos;
  List<String> areas;
  List<double> cantidadesCubiertas;
  List<String> comentariosTienda;
  List<String> comentariosProveedor;
  List<String> comentariosFinales;
  List<bool> confirmacion;
  List<int> idProductos;
  int cantArticulos;
  String estado;
  String remitente;
  String fechaOrden;
  String ultimaModificacion;
  String locacion;
  String mensaje;

  static List<String> listaEstados() {
    return [
      'Cancelado',
      'Denegado',
      'En proceso',
      'Entregado',
      'Finalizado',
      'Incompleto',
    ];
  }

  OrdenModel({
    required this.id,
    required this.articulos,
    required this.cantidades,
    required this.tipos,
    required this.areas,
    required this.cantidadesCubiertas,
    required this.comentariosProveedor,
    required this.comentariosFinales,
    required this.comentariosTienda,
    required this.confirmacion,
    required this.idProductos,
    required this.cantArticulos,
    required this.estado,
    required this.remitente,
    required this.fechaOrden,
    required this.ultimaModificacion,
    required this.locacion,
    required this.mensaje,
  });

  static OrdenModel dummy(String mensaje) {
    return OrdenModel(
      id: 0,
      articulos: [],
      cantidades: [],
      tipos: [],
      areas: [],
      cantidadesCubiertas: [],
      comentariosProveedor: [],
      comentariosTienda: [],
      comentariosFinales: [],
      confirmacion: [],
      idProductos: [],
      cantArticulos: 0,
      estado: '',
      remitente: '',
      fechaOrden: '',
      ultimaModificacion: '',
      locacion: '',
      mensaje: mensaje,
    );
  }

  static Future<List<OrdenModel>> getOrdenes(
    String filtro,
    String locacion,
    List<bool> filtros,
  ) async {
    List<OrdenModel> ordenesFuture = [];
    List<String> estados = [];
    for (int i = 0; i < filtros.length; i++) {
      if (filtros[i]) estados.add("'${listaEstados()[i]}'");
    }
    try {
      var res = await http.get(
        Uri.parse('${MyApp.url}:3000/ordenes/$filtro/$locacion/$estados'),
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
              comentariosFinales: [],
              confirmacion: [],
              idProductos: [],
              cantArticulos: item['CantArticulos'],
              estado: item['Estado'],
              remitente: item['Remitente'],
              fechaOrden: item['FechaOrden'],
              ultimaModificacion: item['UltimaModificación'],
              locacion: '',
              mensaje: '',
            ),
          );
        }
      } else {
        ordenesFuture.add(dummy(res.body));
      }
    } on TimeoutException catch (e) {
      ordenesFuture.add(dummy('${e.message}'));
    } on SocketException catch (e) {
      ordenesFuture.add(dummy(e.message));
    } on http.ClientException catch (e) {
      ordenesFuture.add(dummy(e.message));
    } on Error catch (e) {
      ordenesFuture.add(dummy('$e'));
    }
    return ordenesFuture;
  }

  static Future<List<OrdenModel>> getAllOrdenes(
    String filtro,
    List<bool> filtros,
  ) async {
    List<OrdenModel> ordenesFuture = [];
    List<String> estados = [];
    for (int i = 0; i < filtros.length; i++) {
      if (filtros[i]) estados.add("'${listaEstados()[i]}'");
    }
    try {
      var res = await http.get(
        Uri.parse('${MyApp.url}:3000/ordenes/$filtro/$estados'),
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
              comentariosFinales: [],
              confirmacion: [],
              idProductos: [],
              cantArticulos: item['CantArticulos'],
              estado: item['Estado'],
              remitente: item['Remitente'],
              fechaOrden: item['FechaOrden'],
              ultimaModificacion: item['UltimaModificación'],
              locacion: item['Locacion'],
              mensaje: '',
            ),
          );
        }
      } else {
        ordenesFuture.add(dummy(res.body));
      }
    } on TimeoutException catch (e) {
      ordenesFuture.add(dummy('${e.message}'));
    } on SocketException catch (e) {
      ordenesFuture.add(dummy(e.message));
    } on http.ClientException catch (e) {
      ordenesFuture.add(dummy(e.message));
    } on Error catch (e) {
      ordenesFuture.add(dummy('$e'));
    }
    return ordenesFuture;
  }

  static Future<OrdenModel> getOrden(int id) async {
    OrdenModel orden;
    try {
      var res = await http.get(
        Uri.parse('${MyApp.url}:3000/ordenes/Orden/$id'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      final datos = json.decode(res.body);
      orden = dummy(res.body);
      if (res.statusCode == 200) {
        for (var item in datos) {
          List<OrdenListas> listas = [];
          List<double> cant = [];
          List<double> cantCub = [];
          for (int i = 0; i < item['CantArticulos']; i++) {
            String can = '${item['Cantidades'][i]}';
            String cancub = '${item['CantidadesCubiertas'][i]}';
            if (can.split('.').length < 2) can = '$can.0';
            if (can.split('.').length < 2) cancub = '$cancub.0';
            cant.add(double.parse(can));
            cantCub.add(double.parse(cancub));
            listas.add(
              OrdenListas(
                art: item['Articulos'][i],
                cant: double.parse(can),
                tipo: item['Tipos'][i],
                area: item['Areas'][i],
                cantCub: double.parse(cancub),
                comTienda: item['ComentariosTienda'][i],
                comProv: item['ComentariosProveedor'][i],
                comFin: item['ComentariosFinales'][i],
                conf: item['Confirmacion'][i],
                id: item['idProductos'][i],
              ),
            );
          }
          listas.sort((a, b) {
            return a.art.toLowerCase().compareTo(b.art.toLowerCase());
          });
          for (int i = 0; i < item['CantArticulos']; i++) {
            item['Articulos'][i] = listas[i].art;
            item['Cantidades'][i] = listas[i].cant;
            item['Tipos'][i] = listas[i].tipo;
            item['Areas'][i] = listas[i].area;
            item['CantidadesCubiertas'][i] = listas[i].cantCub;
            item['ComentariosTienda'][i] = listas[i].comTienda;
            item['ComentariosProveedor'][i] = listas[i].comProv;
            item['ComentariosFinales'][i] = listas[i].comFin;
            item['Confirmacion'][i] = listas[i].conf;
            item['idProductos'][i] = listas[i].id;
          }
          orden = OrdenModel(
            id: item['id'],
            articulos: List<String>.from(item['Articulos']),
            cantidades: cant,
            tipos: List<String>.from(item['Tipos']),
            areas: List<String>.from(item['Areas']),
            cantidadesCubiertas: cantCub,
            comentariosTienda: List<String>.from(item['ComentariosTienda']),
            comentariosProveedor: List<String>.from(
              item['ComentariosProveedor'],
            ),
            comentariosFinales: List<String>.from(item['ComentariosFinales']),
            confirmacion: List<bool>.from(item['Confirmacion']),
            idProductos: List<int>.from(item['idProductos']),
            cantArticulos: item['CantArticulos'],
            estado: item['Estado'],
            remitente: item['Remitente'],
            fechaOrden: item['FechaOrden'],
            ultimaModificacion: item['UltimaModificación'],
            locacion: item['Locacion'],
            mensaje: '',
          );
        }
      }
    } on TimeoutException catch (e) {
      orden = dummy('${e.message}');
    } on SocketException catch (e) {
      orden = dummy(e.message);
    } on http.ClientException catch (e) {
      orden = dummy(e.message);
    } on Error catch (e) {
      orden = dummy('$e');
    }
    return orden;
  }

  static Future<String> postOrden(
    List<int> idProductos,
    List<double> cantidades,
    List<String> comentarios,
  ) async {
    String remitente = LocalStorage.local('usuario');
    String productoFuture = '';
    try {
      final res = await http.post(
        Uri.parse('${MyApp.url}:3000/ordenes/'),
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

  static Future<String> editarOrden(String id, String columna, var dato) async {
    String respuesta = '';
    if (columna == 'Estado') {
      dato = '${dato[0].toUpperCase()}${dato.substring(1, dato.length)}';
    }
    try {
      final res = await http.put(
        Uri.parse('${MyApp.url}:3000/ordenes/$id/$columna'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dato': dato}),
      );
      respuesta = res.body;
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
    String respuesta = '';
    try {
      final res = await http.put(
        Uri.parse('${MyApp.url}:3000/ordenes/$id/confirmacion'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'estado': estado, 'confirmacion': confirmaciones}),
      );
      respuesta = res.body;
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

class OrdenListas {
  String art;
  double cant;
  String tipo;
  String area;
  double cantCub;
  String comTienda;
  String comProv;
  String comFin;
  bool conf;
  int id;

  OrdenListas({
    required this.art,
    required this.cant,
    required this.tipo,
    required this.area,
    required this.cantCub,
    required this.comTienda,
    required this.comProv,
    required this.comFin,
    required this.conf,
    required this.id,
  });
}
