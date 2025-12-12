import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/local_storage.dart';

class OrdenModel {
  int id;
  List articulos;
  List cantidades;
  List cantidadesCubiertas;
  String estado;
  String remitente;
  String ultimaModificacion;
  String destino;

  OrdenModel({
    required this.id,
    required this.articulos,
    required this.cantidades,
    required this.cantidadesCubiertas,
    required this.estado,
    required this.remitente,
    required this.ultimaModificacion,
    required this.destino,
  });

  static List<OrdenModel> listaProvicional() {
    List<OrdenModel> productos = [];

    productos.add(
      OrdenModel(
        id: 1,
        articulos: ["Articulo1", "Articulo2"],
        cantidades: [1, 2],
        cantidadesCubiertas: [0, 0],
        estado: "En proceso",
        remitente: "Usuario",
        ultimaModificacion: "28/10/2025 16:11:32",
        destino: 'Almacen',
      ),
    );

    productos.add(
      OrdenModel(
        id: 2,
        articulos: ["Articulo3"],
        cantidades: [3],
        cantidadesCubiertas: [3],
        estado: "Finalizado",
        remitente: "Frank",
        ultimaModificacion: "28/10/2025 16:11:32",
        destino: 'Almacen',
      ),
    );

    return productos;
  }

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
              cantidadesCubiertas: item['CantidadesCubiertas'],
              estado: item["Estado"],
              remitente: item["Remitente"],
              ultimaModificacion: item["UltimaModificación"],
              destino: item["Destino"],
            ),
          );
        }
      } else {
        ordenesFuture.add(
          OrdenModel(
            id: 0,
            articulos: ["Error"],
            cantidades: [0],
            cantidadesCubiertas: [0],
            estado: "Error",
            remitente: res.body,
            ultimaModificacion: res.body,
            destino: res.body,
          ),
        );
      }
    } on TimeoutException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [0],
          cantidadesCubiertas: [0],
          estado: "Error",
          remitente: e.message.toString(),
          ultimaModificacion: e.message.toString(),
          destino: e.message.toString(),
        ),
      );
    } on SocketException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [0],
          cantidadesCubiertas: [0],
          estado: "Error",
          remitente: e.message.toString(),
          ultimaModificacion: e.message.toString(),
          destino: e.message.toString(),
        ),
      );
    } on http.ClientException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [0],
          cantidadesCubiertas: [0],
          estado: "Error",
          remitente: e.message.toString(),
          ultimaModificacion: e.message.toString(),
          destino: e.message.toString(),
        ),
      );
    } on Error catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [0],
          cantidadesCubiertas: [0],
          estado: "Error",
          remitente: e.toString(),
          ultimaModificacion: e.toString(),
          destino: e.toString(),
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
              cantidadesCubiertas: item['CantidadesCubiertas'],
              estado: item["Estado"],
              remitente: item["Remitente"],
              ultimaModificacion: item["UltimaModificación"],
              destino: item["Destino"],
            ),
          );
        }
      } else {
        ordenesFuture.add(
          OrdenModel(
            id: 0,
            articulos: ["Error"],
            cantidades: [0],
            cantidadesCubiertas: [0],
            estado: "Error",
            remitente: res.body,
            ultimaModificacion: res.body,
            destino: res.body,
          ),
        );
      }
    } on TimeoutException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [0],
          cantidadesCubiertas: [0],
          estado: "Error",
          remitente: e.message.toString(),
          ultimaModificacion: e.message.toString(),
          destino: e.message.toString(),
        ),
      );
    } on SocketException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [0],
          cantidadesCubiertas: [0],
          estado: "Error",
          remitente: e.message.toString(),
          ultimaModificacion: e.message.toString(),
          destino: e.message.toString(),
        ),
      );
    } on http.ClientException catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [0],
          cantidadesCubiertas: [0],
          estado: "Error",
          remitente: e.message.toString(),
          ultimaModificacion: e.message.toString(),
          destino: e.message.toString(),
        ),
      );
    } on Error catch (e) {
      ordenesFuture.add(
        OrdenModel(
          id: 0,
          articulos: ["Error"],
          cantidades: [0],
          cantidadesCubiertas: [0],
          estado: "Error",
          remitente: e.toString(),
          ultimaModificacion: e.toString(),
          destino: e.toString(),
        ),
      );
    }
    return ordenesFuture;
  }

  static Future<String> postOrden(
    List<String> articulos,
    List<int> cantidades,
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
          'estado': estado,
          'remitente': remitente,
          'destino': destino,
        }),
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          productoFuture = item["id"].toString();
        }
      } else {
        productoFuture = res.body.toString();
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
      if (res.statusCode == 200) {
        respuesta = "Se modificó la orden.";
      } else {
        respuesta = res.reasonPhrase.toString();
      }
    } on TimeoutException catch (e) {
      respuesta = e.message.toString();
    } on SocketException catch (e) {
      respuesta = e.message.toString();
    } on http.ClientException catch (e) {
      respuesta = "Error: ${e.message.toString()}";
    } on Error catch (e) {
      respuesta = e.toString();
    }
    return respuesta;
  }
}
