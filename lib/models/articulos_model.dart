import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/local_storage.dart';

class ArticulosModel {
  int id;
  String nombre;
  String area;
  String tipo;
  String codigoBarras;
  double cantidadPorUnidad;
  double precio;
  String mensaje;

  ArticulosModel({
    required this.id,
    required this.nombre,
    required this.area,
    required this.tipo,
    required this.codigoBarras,
    required this.cantidadPorUnidad,
    required this.precio,
    required this.mensaje,
  });

  static Future<List<ArticulosModel>> getArticulos(
    String filtro,
    String busqueda,
  ) async {
    String conexion = LocalStorage.local('conexion');
    String locacion = LocalStorage.local('locación');
    List<ArticulosModel> articulosFuture = [];
    if (locacion.isEmpty || locacion == "null") {
      articulosFuture.add(
        ArticulosModel(
          id: 0,
          nombre: "Error",
          tipo: "",
          cantidadPorUnidad: 0,
          area: "",
          codigoBarras: "",
          precio: 0,
          mensaje: "No hay locación establecida",
        ),
      );
    } else {
      try {
        var res = await http.get(
          Uri.parse("$conexion/articulos/$filtro/$busqueda"),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
          },
        );
        if (res.statusCode == 200) {
          final datos = json.decode(res.body);
          for (var item in datos) {
            articulosFuture.add(
              ArticulosModel(
                id: item["id"],
                nombre: item["Nombre"],
                tipo: item["Tipo"],
                cantidadPorUnidad: item["CantidadPorUnidad"].toDouble(),
                area: item["Area"],
                codigoBarras: item["CodigoBarras"],
                precio: item["Precio"].toDouble(),
                mensaje: "",
              ),
            );
          }
        } else {
          articulosFuture.add(
            ArticulosModel(
              id: 0,
              nombre: "Error",
              tipo: "",
              cantidadPorUnidad: 0,
              area: "",
              codigoBarras: "",
              precio: 0,
              mensaje: res.body,
            ),
          );
        }
      } on TimeoutException catch (e) {
        articulosFuture.add(
          ArticulosModel(
            id: 0,
            nombre: "Error",
            tipo: "",
            cantidadPorUnidad: 0,
            area: "",
            codigoBarras: "",
            precio: 0,
            mensaje: "${e.message}",
          ),
        );
      } on SocketException catch (e) {
        articulosFuture.add(
          ArticulosModel(
            id: 0,
            nombre: "Error",
            tipo: "",
            cantidadPorUnidad: 0,
            area: "",
            codigoBarras: "",
            precio: 0,
            mensaje: e.message,
          ),
        );
      } on http.ClientException catch (e) {
        articulosFuture.add(
          ArticulosModel(
            id: 0,
            nombre: "Error",
            tipo: "",
            cantidadPorUnidad: 0,
            area: "",
            codigoBarras: "",
            precio: 0,
            mensaje: e.message,
          ),
        );
      } on Error catch (e) {
        articulosFuture.add(
          ArticulosModel(
            id: 0,
            nombre: "Error",
            tipo: "",
            cantidadPorUnidad: 0,
            area: "",
            codigoBarras: "",
            precio: 0,
            mensaje: "$e",
          ),
        );
      }
    }
    return articulosFuture;
  }

  static Future<String> addArticulo(
    String nombre,
    String tipo,
    String area,
    double cantidad,
    String barras,
    double precio,
  ) async {
    late String articulosFuture;
    try {
      final res = await http.post(
        Uri.parse("${LocalStorage.local('conexion')}/articulos"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({
          'nombre': nombre,
          'tipo': tipo,
          'area': area,
          'cantidad': cantidad,
          'barras': barras,
          'precio': precio,
        }),
      );
      articulosFuture = res.body;
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          articulosFuture = item["Nombre"];
        }
      }
    } on TimeoutException catch (e) {
      articulosFuture = "Error: ${e.message}";
    } on SocketException catch (e) {
      articulosFuture = "Error: ${e.message}";
    } on http.ClientException catch (e) {
      articulosFuture = "Error: ${e.message}";
    } on Error catch (e) {
      articulosFuture = "Error: $e";
    }
    return articulosFuture;
  }

  static Future<String> editarArticulo(
    int id,
    String dato,
    String columna,
  ) async {
    late String articulosFuture;
    try {
      final res = await http.put(
        Uri.parse("${LocalStorage.local('conexion')}/articulos/$id/$columna"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({'dato': dato}),
      );
      articulosFuture = res.body;
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          articulosFuture = item["Nombre"];
        }
      }
    } on TimeoutException catch (e) {
      articulosFuture = "Error: ${e.message}";
    } on SocketException catch (e) {
      articulosFuture = "Error: ${e.message}";
    } on http.ClientException catch (e) {
      articulosFuture = "Error: ${e.message}";
    } on Error catch (e) {
      articulosFuture = "Error: $e";
    }
    return articulosFuture;
  }
}
