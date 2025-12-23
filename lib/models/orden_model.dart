import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/local_storage.dart';

class OrdenModel {
  int id;
  List articulos;
  List cantidades;
  List tipos;
  List areas;
  List cantidadesCubiertas;
  String estado;
  String remitente;
  String ultimaModificacion;
  String destino;
  String mensaje;

  OrdenModel({
    required this.id,
    required this.articulos,
    required this.cantidades,
    required this.tipos,
    required this.areas,
    required this.cantidadesCubiertas,
    required this.estado,
    required this.remitente,
    required this.ultimaModificacion,
    required this.destino,
    required this.mensaje,
  });

  static Future<List<OrdenModel>> getOrdenes(
    String filtro,
    String locacion,
  ) async {
    late String url;
    String conexion = LocalStorage.local('conexion');
    url = "$conexion/ordenes/$filtro/$locacion";
    late List<OrdenModel> ordenesFuture = [];
    var res = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
      },
    );
    try {
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          ordenesFuture.add(
            OrdenModel(
              id: item["id"],
              articulos: item['Artículos'],
              cantidades: item['Cantidades'],
              tipos: item['Tipos'],
              areas: item['Areas'],
              cantidadesCubiertas: item['CantidadesCubiertas'],
              estado: item["Estado"],
              remitente: item["Remitente"],
              ultimaModificacion: item["UltimaModificación"],
              destino: item["Destino"],
              mensaje: "",
            ),
          );
        }
      } else {
        ordenesFuture.add(
          OrdenModel(
            id: 0,
            articulos: ["Error"],
            cantidades: [],
            tipos: [],
            areas: [],
            cantidadesCubiertas: [0],
            estado: "",
            remitente: "",
            ultimaModificacion: "",
            destino: "",
            mensaje: res.body,
          ),
        );
      }
    } on TimeoutException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [0],
          estado: "",
          remitente: "",
          ultimaModificacion: "",
          destino: "",
          mensaje: e.message.toString(),
        ),
      );
    } on SocketException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [0],
          estado: "",
          remitente: "",
          ultimaModificacion: "",
          destino: "",
          mensaje: e.message.toString(),
        ),
      );
    } on http.ClientException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          estado: "",
          remitente: "",
          ultimaModificacion: "",
          destino: "",
          mensaje: e.message.toString(),
        ),
      );
    } on Error catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          estado: "",
          remitente: "",
          ultimaModificacion: "",
          destino: "",
          mensaje: e.toString(),
        ),
      );
    }
    return ordenesFuture;
  }

  static Future<List<OrdenModel>> getAllOrdenes(String filtro) async {
    late String url;
    String conexion = LocalStorage.local('conexion');
    url = "$conexion/ordenes/$filtro";
    late List<OrdenModel> ordenesFuture = [];
    var res = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
      },
    );
    try {
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          ordenesFuture.add(
            OrdenModel(
              id: item["id"],
              articulos: item['Artículos'],
              cantidades: item['Cantidades'],
              tipos: item['Tipos'],
              areas: item['Areas'],
              cantidadesCubiertas: item['CantidadesCubiertas'],
              estado: item["Estado"],
              remitente: item["Remitente"],
              ultimaModificacion: item["UltimaModificación"],
              destino: item["Destino"],
              mensaje: "",
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
            estado: "",
            remitente: "",
            ultimaModificacion: "",
            destino: "",
            mensaje: res.body
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
          estado: "",
          remitente: "",
          ultimaModificacion: "",
          destino: "",
          mensaje: e.message.toString()
        ),
      );
    } on SocketException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          estado: "",
          remitente: "",
          ultimaModificacion: "",
          destino: "",
          mensaje: e.message.toString()
        ),
      );
    } on http.ClientException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          estado: "",
          remitente: "",
          ultimaModificacion: "",
          destino: "",
          mensaje: e.message.toString()
        ),
      );
    } on Error catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [],
          tipos: [],
          areas: [],
          cantidadesCubiertas: [],
          estado: "",
          remitente: "",
          ultimaModificacion: "",
          destino: "",
          mensaje: e.toString()
        ),
      );
    }
    return ordenesFuture;
  }

  static Future<String> postOrden(
    List<String> articulos,
    List<int> cantidades,
    List<String> tipos,
    List<String> areas,
    String estado,
    String remitente,
    String destino,
  ) async {
    late String productoFuture;
    try {
      final res = await http.post(
        Uri.parse("${LocalStorage.local('conexion')}/ordenes/"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({
          'articulos': articulos
              .toString()
              .replaceAll("[", "{")
              .replaceAll("]", "}"),
          'cantidades': cantidades
              .toString()
              .replaceAll("[", "{")
              .replaceAll("]", "}"),
          'tipos': tipos.toString().replaceAll("[", "{").replaceAll("]", "}"),
          'areas': areas.toString().replaceAll("[", "{").replaceAll("]", "}"),
          'estado': estado,
          'remitente': remitente,
          'destino': destino,
        }),
      );
      productoFuture = res.body;
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          productoFuture = item["id"].toString();
        }
      }
    } on TimeoutException catch (e) {
      productoFuture = "Error: ${e.message.toString()}";
    } on SocketException catch (e) {
      productoFuture = "Error: ${e.message.toString()}";
    } on http.ClientException catch (e) {
      productoFuture = "Error: ${e.message.toString()}";
    } on Error catch (e) {
      productoFuture = "Error: ${e.toString()}";
    }
    return productoFuture;
  }

  static Future<String> editarOrden(
    String id,
    String columna,
    String dato,
  ) async {
    String respuesta;
    if (dato == "finalizar") {
      dato = "Finalizado";
    } else if (dato == "denegar") {
      dato = "Denegado";
    }
    try {
      final res = await http.put(
        Uri.parse("${LocalStorage.local('conexion')}/ordenes/$id/$columna"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({'dato': dato}),
      );
      respuesta = res.reasonPhrase.toString();
      if (res.statusCode == 200) {
        respuesta = "Se modificó la orden.";
      }
    } on TimeoutException catch (e) {
      respuesta = "Error: ${e.message.toString()}";
    } on SocketException catch (e) {
      respuesta = "Error: ${e.message.toString()}";
    } on http.ClientException catch (e) {
      respuesta = "Error: ${e.message.toString()}";
    } on Error catch (e) {
      respuesta = "Error: ${e.toString()}";
    }
    return respuesta;
  }
}
