import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/local_storage.dart';

class ProductoModel {
  int id;
  String nombre;
  String tipo;
  int unidades;
  String ultimaModificacion;
  double cantidadPorUnidad;
  String area;
  int entrada;
  int salida;
  int perdida;
  String ultimoUsuario;
  String codigoBarras;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.unidades,
    required this.ultimaModificacion,
    required this.cantidadPorUnidad,
    required this.area,
    required this.entrada,
    required this.salida,
    required this.perdida,
    required this.ultimoUsuario,
    required this.codigoBarras,
  });

  static List<ProductoModel> listaProvicional() {
    List<ProductoModel> productos = [];

    productos.add(
      ProductoModel(
        id: 1,
        nombre: "Producto 1",
        tipo: "Tipo 1",
        unidades: 12,
        ultimaModificacion: "Lun 15/09 10:30pm",
        cantidadPorUnidad: 2,
        area: "Area 1",
        entrada: 0,
        salida: 0,
        perdida: 0,
        ultimoUsuario: "usuario",
        codigoBarras: "12345",
      ),
    );

    productos.add(
      ProductoModel(
        id: 2,
        nombre: "Producto 2",
        tipo: "Tipo 2",
        unidades: 21,
        ultimaModificacion: "Dom 26/09 3:10am",
        cantidadPorUnidad: 20,
        area: "Area 1",
        entrada: 0,
        salida: 0,
        perdida: 0,
        ultimoUsuario: "usuario",
        codigoBarras: "12345",
      ),
    );

    return productos;
  }

  static Future<List<ProductoModel>> getProductos(
    String filtro,
    String busqueda,
  ) async {
    late String url;
    String conexion = LocalStorage.local('conexion');
    String locacion = LocalStorage.local('locación');
    if (busqueda.isEmpty) {
      url = "$conexion/inventario/$locacion/$filtro";
    } else {
      url = "$conexion/inventario/$locacion/$filtro/$busqueda";
    }
    late List<ProductoModel> productosFuture = [];
    if (locacion.isEmpty || locacion == "null") {
      productosFuture.add(
        ProductoModel(
          id: 0,
          nombre: "Error",
          tipo: "No hay locación establecida",
          unidades: 0,
          ultimaModificacion: "No hay locación establecida",
          cantidadPorUnidad: 0,
          area: "No hay locación establecida",
          entrada: 0,
          salida: 0,
          perdida: 0,
          ultimoUsuario: "No hay locación establecida",
          codigoBarras: "No hay locación establecida",
        ),
      );
    } else {
      try {
        var res = await http.get(
          Uri.parse(url),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
          },
        );
        if (res.statusCode == 200) {
          final datos = json.decode(res.body);
          for (var item in datos) {
            productosFuture.add(
              ProductoModel(
                id: item["id"],
                nombre: item["Nombre"].toString(),
                tipo: item["Tipo"].toString(),
                unidades: item["Unidades"],
                ultimaModificacion: item["UltimaModificación"],
                cantidadPorUnidad: item["CantidadPorUnidad"].toDouble(),
                area: item["Area"].toString(),
                entrada: item["Entrada"],
                salida: item["Salida"],
                perdida: item["Perdida"],
                ultimoUsuario: item["UltimoUsuario"],
                codigoBarras: item["CodigoBarras"],
              ),
            );
          }
        } else {
          productosFuture.add(
            ProductoModel(
              id: 0,
              nombre: "Error",
              tipo: res.body,
              unidades: 0,
              ultimaModificacion: res.body,
              cantidadPorUnidad: 0,
              area: res.body,
              entrada: 0,
              salida: 0,
              perdida: 0,
              ultimoUsuario: res.body,
              codigoBarras: res.body,
            ),
          );
        }
      } on TimeoutException catch (e) {
        productosFuture.add(
          ProductoModel(
            id: 0,
            nombre: "Error",
            tipo: e.message.toString(),
            unidades: 0,
            ultimaModificacion: e.message.toString(),
            cantidadPorUnidad: 0,
            area: e.message.toString(),
            entrada: 0,
            salida: 0,
            perdida: 0,
            ultimoUsuario: e.message.toString(),
            codigoBarras: e.message.toString(),
          ),
        );
      } on SocketException catch (e) {
        productosFuture.add(
          ProductoModel(
            id: 0,
            nombre: "Error",
            tipo: e.message.toString(),
            unidades: 0,
            ultimaModificacion: e.message.toString(),
            cantidadPorUnidad: 0,
            area: e.message.toString(),
            entrada: 0,
            salida: 0,
            perdida: 0,
            ultimoUsuario: e.message.toString(),
            codigoBarras: e.message.toString(),
          ),
        );
      } on http.ClientException catch (e) {
        productosFuture.add(
          ProductoModel(
            id: 0,
            nombre: "Error",
            tipo: e.message.toString(),
            unidades: 0,
            ultimaModificacion: e.message.toString(),
            cantidadPorUnidad: 0,
            area: e.message.toString(),
            entrada: 0,
            salida: 0,
            perdida: 0,
            ultimoUsuario: e.message.toString(),
            codigoBarras: e.message.toString(),
          ),
        );
      } on Error catch (e) {
        productosFuture.add(
          ProductoModel(
            id: 0,
            nombre: "Error",
            tipo: e.toString(),
            unidades: 0,
            ultimaModificacion: e.toString(),
            cantidadPorUnidad: 0,
            area: e.toString(),
            entrada: 0,
            salida: 0,
            perdida: 0,
            ultimoUsuario: e.toString(),
            codigoBarras: e.toString(),
          ),
        );
      }
    }
    return productosFuture;
  }

  static Future<String> addProducto(
    String nombre,
    int cantidad,
    String tipo,
    String area,
    String usuario,
    String locacion,
    String barras,
  ) async {
    late String productoFuture;
    try {
      final res = await http.post(
        Uri.parse("${LocalStorage.local('conexion')}/inventario/$locacion"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({
          'nombre': nombre,
          'cantidad': cantidad,
          'tipo': tipo,
          'area': area,
          'usuario': usuario,
          'barras' : barras
        }),
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          productoFuture = item["Nombre"];
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

  static Future<String> guardarDatos(
    String columna,
    int unidades,
    int dato,
    int id,
  ) async {
    String mensaje = "";
    try {
      final res = await http.put(
        Uri.parse(
          "${LocalStorage.local('conexion')}/inventario/${LocalStorage.local('locación')}/$id/$columna/ESP",
        ),
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
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          mensaje = item['Nombre'];
        }
      } else {
        mensaje = "Error:${res.body}";
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
    try {
      final res = await http.put(
        Uri.parse(
          "${LocalStorage.local('conexion')}/inventario/${LocalStorage.local('locación')}/reiniciarMovimientos",
        ),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
      );
      if (res.statusCode == 200) {
        texto = "Reinicio exitoso.";
      } else {
        texto = "${res.reasonPhrase}";
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

  static Future<List> getTipos() async {
    late List tipos = [];
    try {
      var res = await http.get(
        Uri.parse('${LocalStorage.local('conexion')}/tipos'),
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
    try {
      var res = await http.get(
        Uri.parse('${LocalStorage.local('conexion')}/areas'),
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
