import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/local_storage.dart';

class ProductoModel {
  String id;
  String nombre;
  String area;
  String tipo;
  String codigoBarras;
  double cantidadPorUnidad;
  double unidades;
  int limiteProd;
  int entrada;
  int salida;
  List<double> perdidaCantidad;
  List<String> perdidaRazones;
  String ultimoUsuario;
  String ultimaModificacion;
  String mensaje;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.area,
    required this.tipo,
    required this.codigoBarras,
    required this.cantidadPorUnidad,
    required this.unidades,
    required this.limiteProd,
    required this.entrada,
    required this.salida,
    required this.perdidaCantidad,
    required this.perdidaRazones,
    required this.ultimoUsuario,
    required this.ultimaModificacion,
    required this.mensaje,
  });

  static Future<List<ProductoModel>> getProductos(
    String filtro,
    String busqueda,
  ) async {
    String conexion = LocalStorage.local('conexion');
    String locacion = LocalStorage.local('locación');
    late List<ProductoModel> productosFuture = [];
    if (locacion.isEmpty || locacion == "null") {
      productosFuture.add(
        ProductoModel(
          id: "",
          nombre: "Error",
          tipo: "",
          unidades: 0,
          ultimaModificacion: "",
          cantidadPorUnidad: 0,
          area: "",
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: "",
          codigoBarras: "",
          limiteProd: 0,
          mensaje: "No hay locación establecida",
        ),
      );
    } else {
      try {
        var res = await http.get(
          Uri.parse("$conexion/almacen/$locacion/$filtro/$busqueda"),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
          },
        );
        if (res.statusCode == 200) {
          final datos = json.decode(res.body);
          for (var item in datos) {
            List<double> doublelist = [];
            for (int i = 0; i < item["PerdidaCantidad"].length; i++) {
              String dob = "${item["PerdidaCantidad"][i]}.0";
              if (dob.split(".").length > 2) {
                dob = "${dob.split(".")[0]}.${dob.split(".")[1]}";
              }
              doublelist.add(double.parse(dob));
            }
            productosFuture.add(
              ProductoModel(
                id: item["id"],
                nombre: item["Nombre"].toString(),
                tipo: item["Tipo"].toString(),
                unidades: item["Unidades"].toDouble(),
                ultimaModificacion: item["UltimaModificación"],
                cantidadPorUnidad: item["CantidadPorUnidad"].toDouble(),
                area: item["Area"].toString(),
                entrada: item["Entradas"],
                salida: item["Salidas"],
                perdidaCantidad: doublelist,
                perdidaRazones: List<String>.from(item["PerdidaRazon"]),
                ultimoUsuario: item["UltimoUsuario"],
                codigoBarras: item["CodigoBarras"],
                limiteProd: item["LimiteProd"],
                mensaje: "",
              ),
            );
          }
        } else {
          productosFuture.add(
            ProductoModel(
              id: "",
              nombre: "Error",
              tipo: "",
              unidades: 0,
              ultimaModificacion: "",
              cantidadPorUnidad: 0,
              area: "",
              entrada: 0,
              salida: 0,
              perdidaCantidad: [],
              perdidaRazones: [],
              ultimoUsuario: "",
              codigoBarras: "",
              limiteProd: 0,
              mensaje: res.body,
            ),
          );
        }
      } on TimeoutException catch (e) {
        productosFuture.add(
          ProductoModel(
            id: "",
            nombre: "Error",
            tipo: "",
            unidades: 0,
            ultimaModificacion: "",
            cantidadPorUnidad: 0,
            area: "",
            entrada: 0,
            salida: 0,
            perdidaCantidad: [],
            perdidaRazones: [],
            ultimoUsuario: "",
            codigoBarras: "",
            limiteProd: 0,
            mensaje: e.message.toString(),
          ),
        );
      } on SocketException catch (e) {
        productosFuture.add(
          ProductoModel(
            id: "",
            nombre: "Error",
            tipo: "",
            unidades: 0,
            ultimaModificacion: "",
            cantidadPorUnidad: 0,
            area: "",
            entrada: 0,
            salida: 0,
            perdidaCantidad: [],
            perdidaRazones: [],
            ultimoUsuario: " ",
            codigoBarras: "",
            limiteProd: 0,
            mensaje: e.message.toString(),
          ),
        );
      } on http.ClientException catch (e) {
        productosFuture.add(
          ProductoModel(
            id: "",
            nombre: "Error",
            tipo: "",
            unidades: 0,
            ultimaModificacion: "",
            cantidadPorUnidad: 0,
            area: "",
            entrada: 0,
            salida: 0,
            perdidaCantidad: [],
            perdidaRazones: [],
            ultimoUsuario: "",
            codigoBarras: "",
            limiteProd: 0,
            mensaje: e.message.toString(),
          ),
        );
      } on Error catch (e) {
        productosFuture.add(
          ProductoModel(
            id: "",
            nombre: "Error",
            tipo: "",
            unidades: 0,
            ultimaModificacion: "",
            cantidadPorUnidad: 0,
            area: "",
            entrada: 0,
            salida: 0,
            perdidaCantidad: [],
            perdidaRazones: [],
            ultimoUsuario: "",
            codigoBarras: "",
            limiteProd: 0,
            mensaje: e.toString(),
          ),
        );
      }
    }
    return productosFuture;
  }

  static Future<List<ProductoModel>> getDatosArticulo(int id) async {
    String conexion = LocalStorage.local('conexion');
    late List<ProductoModel> productoModel = [];

    try {
      var res = await http.get(
        Uri.parse("$conexion/articulos/almacen/$id"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          List<double> doublelist = [];
          for (int i = 0; i < item["PerdidaCantidad"].length; i++) {
            if (item["PerdidaCantidad"].toString().split(".")[1] != "0") {
              String dob = "${item["PerdidaCantidad"][i]}.0";
              if (dob.split(".").length > 2) {
                dob = "${dob.split(".")[0]}.${dob.split(".")[1]}";
              }
              doublelist.add(double.parse(dob));
            }
          }
          productoModel.add(
            ProductoModel(
              id: "",
              nombre: item["inventarioNom"],
              area: "",
              tipo: "",
              unidades: double.parse(item["Unidades"].toString()),
              cantidadPorUnidad: 0,
              entrada: item["Entradas"],
              salida: item["Salidas"],
              perdidaCantidad: doublelist,
              perdidaRazones: List<String>.from(item["PerdidaRazon"]),
              ultimoUsuario: item["UltimoUsuario"],
              ultimaModificacion: item["UltimaModificación"],
              codigoBarras: "",
              limiteProd: item["LimiteProd"],
              mensaje: "",
            ),
          );
        }
      } else {
        productoModel.add(
          ProductoModel(
            id: "",
            nombre: "Error",
            tipo: "",
            unidades: 0,
            ultimaModificacion: "",
            cantidadPorUnidad: 0,
            area: "",
            entrada: 0,
            salida: 0,
            perdidaCantidad: [],
            perdidaRazones: [],
            ultimoUsuario: "",
            codigoBarras: "",
            limiteProd: 0,
            mensaje: res.body,
          ),
        );
      }
    } on TimeoutException catch (e) {
      productoModel.add(
        ProductoModel(
          id: "",
          nombre: "Error",
          tipo: "",
          unidades: 0,
          ultimaModificacion: "",
          cantidadPorUnidad: 0,
          area: "",
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: "",
          codigoBarras: "",
          limiteProd: 0,
          mensaje: e.message.toString(),
        ),
      );
    } on SocketException catch (e) {
      productoModel.add(
        ProductoModel(
          id: "",
          nombre: "Error",
          tipo: "",
          unidades: 0,
          ultimaModificacion: "",
          cantidadPorUnidad: 0,
          area: "",
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: "",
          codigoBarras: "",
          limiteProd: 0,
          mensaje: e.message.toString(),
        ),
      );
    } on http.ClientException catch (e) {
      productoModel.add(
        ProductoModel(
          id: "",
          nombre: "Error",
          tipo: "",
          unidades: 0,
          ultimaModificacion: "",
          cantidadPorUnidad: 0,
          area: "",
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: "",
          codigoBarras: "",
          limiteProd: 0,
          mensaje: e.message.toString(),
        ),
      );
    } on Error catch (e) {
      productoModel.add(
        ProductoModel(
          id: "",
          nombre: "Error",
          tipo: "",
          unidades: 0,
          ultimaModificacion: "",
          cantidadPorUnidad: 0,
          area: "",
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: "",
          codigoBarras: "",
          limiteProd: 0,
          mensaje: e.toString(),
        ),
      );
    }
    return productoModel;
  }

  static Future<String> addProducto(int idProducto, int limite) async {
    String mensaje = "";
    String conexion = LocalStorage.local('conexion');
    String locacion = LocalStorage.local('locación');
    try {
      final res = await http.post(
        Uri.parse("$conexion/almacen/"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({
          'id': "$idProducto${locacion.substring(0, 3)}",
          'idProducto': idProducto,
          'locacion': locacion,
          'limite': limite,
          'usuario': LocalStorage.local('usuario'),
        }),
      );
      mensaje = res.body;
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          mensaje = item["id"];
        }
      }
    } on TimeoutException catch (e) {
      mensaje = "Error: ${e.message.toString()}";
    } on SocketException catch (e) {
      mensaje = "Error: ${e.message.toString()}";
    } on http.ClientException catch (e) {
      mensaje = "Error: ${e.message.toString()}";
    } on Error catch (e) {
      mensaje = "Error: ${e.toString()}";
    }
    return mensaje;
  }

  static Future<String> editarProducto(
    String id,
    String dato,
    String columna,
  ) async {
    String texto;
    String conexion = LocalStorage.local('conexion');
    try {
      final res = await http.put(
        Uri.parse("$conexion/almacen/$id/$columna"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({
          'dato': dato,
          'usuario': LocalStorage.local('usuario'),
        }),
      );
      texto = res.body;
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          texto = item['id'];
        }
      }
    } on TimeoutException catch (e) {
      texto = "Error: ${e.message.toString()}";
    } on SocketException catch (e) {
      texto = "Error: ${e.message.toString()}";
    } on http.ClientException catch (e) {
      texto = "Error: ${e.message.toString()}";
    } on Error catch (e) {
      texto = "Error: ${e.toString()}";
    }
    return texto;
  }

  static Future<String> guardarDatos(
    String columna,
    double unidades,
    int dato,
    String id,
  ) async {
    String mensaje;
    String conexion = LocalStorage.local('conexion');
    try {
      final res = await http.put(
        Uri.parse("$conexion/almacen/$id/$columna/ESP"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({
          'dato': dato,
          'unidades': unidades,
          'usuario': LocalStorage.local('usuario'),
        }),
      );
      mensaje = res.body;
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          mensaje = item['id'];
        }
      }
    } on TimeoutException catch (e) {
      mensaje = "Error: ${e.message.toString()}";
    } on SocketException catch (e) {
      mensaje = "Error: ${e.message.toString()}";
    } on http.ClientException catch (e) {
      mensaje = "Error: ${e.message.toString()}";
    } on Error catch (e) {
      mensaje = "Error: ${e.toString()}";
    }
    return mensaje;
  }

  static Future<String> reiniciarESP() async {
    String texto;
    String conexion = LocalStorage.local('conexion');
    try {
      final res = await http.put(
        Uri.parse(
          "$conexion/almacen/${LocalStorage.local('locación')}/reiniciarMovimientos",
        ),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
      );
      texto = "${res.reasonPhrase}";
      if (res.statusCode == 200) {
        texto = "Reinicio exitoso.";
      }
    } on TimeoutException catch (e) {
      texto = "Error: ${e.message.toString()}";
    } on SocketException catch (e) {
      texto = "Error: ${e.message.toString()}";
    } on http.ClientException catch (e) {
      texto = "Error: ${e.message.toString()}";
    } on Error catch (e) {
      texto = "Error: ${e.toString()}";
    }
    return texto;
  }

  static Future<String> guardarPerdidas(
    List<String> razones,
    List<double> cantidades,
    double unidades,
    String id,
  ) async {
    String texto = "Error: Las perdidas exceden la cantidad almacenada.";
    if (unidades >= 0) {
      try {
        final res = await http.put(
          Uri.parse(
            "${LocalStorage.local('conexion')}/almacen/$id/Perdidas/ESP",
          ),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
          },
          body: jsonEncode({
            'cantidades': cantidades
                .toString()
                .replaceAll("[", "{")
                .replaceAll("]", "}"),
            'razones': razones
                .toString()
                .replaceAll("[", "{")
                .replaceAll("]", "}"),
            'unidades': unidades,
            'usuario': LocalStorage.local('usuario'),
          }),
        );
        texto = "${res.reasonPhrase}";
        if (res.statusCode == 200) {
          texto = "Se guardaron las perdidas.";
        }
      } on TimeoutException catch (e) {
        texto = "Error: ${e.message.toString()}";
      } on SocketException catch (e) {
        texto = "Error: ${e.message.toString()}";
      } on http.ClientException catch (e) {
        texto = "Error: ${e.message.toString()}";
      } on Error catch (e) {
        texto = "Error: ${e.toString()}";
      }
    }
    return texto;
  }

  static Future<List> getTipos() async {
    late List tipos = [];
    String conexion = LocalStorage.local('conexion');
    try {
      var res = await http.get(
        Uri.parse('$conexion/tipos'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          tipos.add(item['Nombre']);
        }
      } else {
        tipos.add(res.body);
      }
    } on TimeoutException catch (e) {
      tipos.add("Error: ${e.message.toString()}");
    } on SocketException catch (e) {
      tipos.add("Error: ${e.message.toString()}");
    } on http.ClientException catch (e) {
      tipos.add("Error: ${e.message.toString()}");
    } on Error catch (e) {
      tipos.add("Error: ${e.toString()}");
    }
    return tipos;
  }

  static Future<List> getAreas() async {
    late List areas = [];
    String conexion = LocalStorage.local('conexion');
    try {
      var res = await http.get(
        Uri.parse('$conexion/areas'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          areas.add(item['Nombre']);
        }
      } else {
        areas.add(res.body);
      }
    } on TimeoutException catch (e) {
      areas.add("Error: ${e.message.toString()}");
    } on SocketException catch (e) {
      areas.add("Error: ${e.message.toString()}");
    } on http.ClientException catch (e) {
      areas.add("Error: ${e.message.toString()}");
    } on Error catch (e) {
      areas.add("Error: ${e.toString()}");
    }
    return areas;
  }
}
