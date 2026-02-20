import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/local_storage.dart';

class ProductoModel {
  int id;
  String nombre;
  String area;
  String tipo;
  String codigoBarras;
  double cantidadPorUnidad;
  double unidades;
  int limiteProd;
  double entrada;
  double salida;
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
    if (locacion.isEmpty || locacion == 'null') {
      productosFuture.add(
        ProductoModel(
          id: 0,
          nombre: '',
          tipo: '',
          unidades: 0,
          ultimaModificacion: '',
          cantidadPorUnidad: 0,
          area: '',
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: '',
          codigoBarras: '',
          limiteProd: 0,
          mensaje: 'Error: No hay locación establecida',
        ),
      );
    } else {
      try {
        var res = await http.get(
          Uri.parse('$conexion/almacen/$locacion/$filtro/$busqueda'),
          headers: {
            'Accept': 'application/json',
            'content-type': 'application/json; charset=UTF-8',
          },
        );
        if (res.statusCode == 200) {
          final datos = json.decode(res.body);
          for (var item in datos) {
            List<double> doublelist = [];
            for (double perdida in item['PerdidaCantidad']) {
              String dob = '$perdida';
              if (dob.split('.').length < 2) {
                dob = '$dob.0';
              }
              doublelist.add(double.parse(dob));
            }
            productosFuture.add(
              ProductoModel(
                id: item['id'],
                nombre: item['Nombre'],
                tipo: item['Tipo'],
                unidades: item['Unidades'].toDouble(),
                ultimaModificacion: item['UltimaModificación'],
                cantidadPorUnidad: item['CantidadPorUnidad'].toDouble(),
                area: item['Area'],
                entrada: item['Entradas'].toDouble(),
                salida: item['Salidas'].toDouble(),
                perdidaCantidad: doublelist,
                perdidaRazones: List<String>.from(item['PerdidaRazon']),
                ultimoUsuario: item['UltimoUsuario'],
                codigoBarras: item['CodigoBarras'],
                limiteProd: item['LimiteProd'],
                mensaje: '',
              ),
            );
          }
        } else {
          productosFuture.add(
            ProductoModel(
              id: 0,
              nombre: '',
              tipo: '',
              unidades: 0,
              ultimaModificacion: '',
              cantidadPorUnidad: 0,
              area: '',
              entrada: 0,
              salida: 0,
              perdidaCantidad: [],
              perdidaRazones: [],
              ultimoUsuario: '',
              codigoBarras: '',
              limiteProd: 0,
              mensaje: 'Error: ${res.body}',
            ),
          );
        }
      } on TimeoutException catch (e) {
        productosFuture.add(
          ProductoModel(
            id: 0,
            nombre: '',
            tipo: '',
            unidades: 0,
            ultimaModificacion: '',
            cantidadPorUnidad: 0,
            area: '',
            entrada: 0,
            salida: 0,
            perdidaCantidad: [],
            perdidaRazones: [],
            ultimoUsuario: '',
            codigoBarras: '',
            limiteProd: 0,
            mensaje: 'Error: ${e.message}',
          ),
        );
      } on SocketException catch (e) {
        productosFuture.add(
          ProductoModel(
            id: 0,
            nombre: '',
            tipo: '',
            unidades: 0,
            ultimaModificacion: '',
            cantidadPorUnidad: 0,
            area: '',
            entrada: 0,
            salida: 0,
            perdidaCantidad: [],
            perdidaRazones: [],
            ultimoUsuario: ' ',
            codigoBarras: '',
            limiteProd: 0,
            mensaje: 'Error: ${e.message}',
          ),
        );
      } on http.ClientException catch (e) {
        productosFuture.add(
          ProductoModel(
            id: 0,
            nombre: '',
            tipo: '',
            unidades: 0,
            ultimaModificacion: '',
            cantidadPorUnidad: 0,
            area: '',
            entrada: 0,
            salida: 0,
            perdidaCantidad: [],
            perdidaRazones: [],
            ultimoUsuario: '',
            codigoBarras: '',
            limiteProd: 0,
            mensaje: 'Error: ${e.message}',
          ),
        );
      } on Error catch (e) {
        productosFuture.add(
          ProductoModel(
            id: 0,
            nombre: '',
            tipo: '',
            unidades: 0,
            ultimaModificacion: '',
            cantidadPorUnidad: 0,
            area: '',
            entrada: 0,
            salida: 0,
            perdidaCantidad: [],
            perdidaRazones: [],
            ultimoUsuario: '',
            codigoBarras: '',
            limiteProd: 0,
            mensaje: 'Error: $e',
          ),
        );
      }
    }
    return productosFuture;
  }

  static Future<List<ProductoModel>> getProductosProd(
    String filtro,
    String busqueda,
  ) async {
    String conexion = LocalStorage.local('conexion');
    late List<ProductoModel> productosFuture = [];
    try {
      var res = await http.get(
        Uri.parse('$conexion/almacen/Prod/$filtro/$busqueda'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          List<double> doublelist = [];
          for (double perdida in item['PerdidaCantidad']) {
            String dob = '$perdida';
            if (dob.split('.').length < 2) {
              dob = '$dob.0';
            }
            doublelist.add(double.parse(dob));
          }
          productosFuture.add(
            ProductoModel(
              id: item['id'],
              nombre: item['Nombre'],
              tipo: item['Tipo'],
              unidades: item['Unidades'].toDouble(),
              ultimaModificacion: item['UltimaModificación'],
              cantidadPorUnidad: item['CantidadPorUnidad'].toDouble(),
              area: item['Area'],
              entrada: item['Entradas'].toDouble(),
              salida: item['Salidas'].toDouble(),
              perdidaCantidad: doublelist,
              perdidaRazones: List<String>.from(item['PerdidaRazon']),
              ultimoUsuario: item['UltimoUsuario'],
              codigoBarras: item['CodigoBarras'],
              limiteProd: item['LimiteProd'],
              mensaje: '',
            ),
          );
        }
      } else {
        productosFuture.add(
          ProductoModel(
            id: 0,
            nombre: '',
            tipo: '',
            unidades: 0,
            ultimaModificacion: '',
            cantidadPorUnidad: 0,
            area: '',
            entrada: 0,
            salida: 0,
            perdidaCantidad: [],
            perdidaRazones: [],
            ultimoUsuario: '',
            codigoBarras: '',
            limiteProd: 0,
            mensaje: 'Error: ${res.body}',
          ),
        );
      }
    } on TimeoutException catch (e) {
      productosFuture.add(
        ProductoModel(
          id: 0,
          nombre: '',
          tipo: '',
          unidades: 0,
          ultimaModificacion: '',
          cantidadPorUnidad: 0,
          area: '',
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: '',
          codigoBarras: '',
          limiteProd: 0,
          mensaje: 'Error: ${e.message}',
        ),
      );
    } on SocketException catch (e) {
      productosFuture.add(
        ProductoModel(
          id: 0,
          nombre: '',
          tipo: '',
          unidades: 0,
          ultimaModificacion: '',
          cantidadPorUnidad: 0,
          area: '',
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: ' ',
          codigoBarras: '',
          limiteProd: 0,
          mensaje: 'Error: ${e.message}',
        ),
      );
    } on http.ClientException catch (e) {
      productosFuture.add(
        ProductoModel(
          id: 0,
          nombre: '',
          tipo: '',
          unidades: 0,
          ultimaModificacion: '',
          cantidadPorUnidad: 0,
          area: '',
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: '',
          codigoBarras: '',
          limiteProd: 0,
          mensaje: 'Error: ${e.message}',
        ),
      );
    } on Error catch (e) {
      productosFuture.add(
        ProductoModel(
          id: 0,
          nombre: '',
          tipo: '',
          unidades: 0,
          ultimaModificacion: '',
          cantidadPorUnidad: 0,
          area: '',
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: '',
          codigoBarras: '',
          limiteProd: 0,
          mensaje: 'Error: $e',
        ),
      );
    }
    return productosFuture;
  }

  static Future<ProductoModel> getProducto(int id) async {
    String conexion = LocalStorage.local('conexion');
    String locacion = LocalStorage.local('locación');
    ProductoModel producto;
    try {
      var res = await http.get(
        Uri.parse('$conexion/almacen/Producto/$locacion/$id'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      producto = ProductoModel(
        id: 0,
        nombre: '',
        tipo: '',
        unidades: 0,
        ultimaModificacion: '',
        cantidadPorUnidad: 0,
        area: '',
        entrada: 0,
        salida: 0,
        perdidaCantidad: [],
        perdidaRazones: [],
        ultimoUsuario: '',
        codigoBarras: '',
        limiteProd: 0,
        mensaje: 'Error: ${res.body}',
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          List<double> doublelist = [];
          for (double perdida in item['PerdidaCantidad']) {
            String dob = '$perdida';
            if (dob.split('.').length < 2) {
              dob = '$dob.0';
            }
            doublelist.add(double.parse(dob));
          }
          producto = ProductoModel(
            id: item['id'],
            nombre: item['Nombre'],
            tipo: item['Tipo'],
            unidades: item['Unidades'].toDouble(),
            ultimaModificacion: item['UltimaModificación'],
            cantidadPorUnidad: item['CantidadPorUnidad'].toDouble(),
            area: item['Area'],
            entrada: item['Entradas'].toDouble(),
            salida: item['Salidas'].toDouble(),
            perdidaCantidad: doublelist,
            perdidaRazones: List<String>.from(item['PerdidaRazon']),
            ultimoUsuario: item['UltimoUsuario'],
            codigoBarras: item['CodigoBarras'],
            limiteProd: item['LimiteProd'],
            mensaje: '',
          );
        }
      }
    } on TimeoutException catch (e) {
      producto = ProductoModel(
        id: 0,
        nombre: '',
        tipo: '',
        unidades: 0,
        ultimaModificacion: '',
        cantidadPorUnidad: 0,
        area: '',
        entrada: 0,
        salida: 0,
        perdidaCantidad: [],
        perdidaRazones: [],
        ultimoUsuario: '',
        codigoBarras: '',
        limiteProd: 0,
        mensaje: 'Error: ${e.message}',
      );
    } on SocketException catch (e) {
      producto = ProductoModel(
        id: 0,
        nombre: '',
        tipo: '',
        unidades: 0,
        ultimaModificacion: '',
        cantidadPorUnidad: 0,
        area: '',
        entrada: 0,
        salida: 0,
        perdidaCantidad: [],
        perdidaRazones: [],
        ultimoUsuario: '',
        codigoBarras: '',
        limiteProd: 0,
        mensaje: 'Error: ${e.message}',
      );
    } on http.ClientException catch (e) {
      producto = ProductoModel(
        id: 0,
        nombre: '',
        tipo: '',
        unidades: 0,
        ultimaModificacion: '',
        cantidadPorUnidad: 0,
        area: '',
        entrada: 0,
        salida: 0,
        perdidaCantidad: [],
        perdidaRazones: [],
        ultimoUsuario: '',
        codigoBarras: '',
        limiteProd: 0,
        mensaje: 'Error: ${e.message}',
      );
    } on Error catch (e) {
      producto = ProductoModel(
        id: 0,
        nombre: '',
        tipo: '',
        unidades: 0,
        ultimaModificacion: '',
        cantidadPorUnidad: 0,
        area: '',
        entrada: 0,
        salida: 0,
        perdidaCantidad: [],
        perdidaRazones: [],
        ultimoUsuario: '',
        codigoBarras: '',
        limiteProd: 0,
        mensaje: 'Error: $e',
      );
    }
    return producto;
  }

  static Future<List<ProductoModel>> getDatosArticulo(int id) async {
    String conexion = LocalStorage.local('conexion');
    late List<ProductoModel> productoModel = [];
    try {
      var res = await http.get(
        Uri.parse('$conexion/articulos/almacen/$id'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          List<double> doublelist = [];
          for (double perdida in item['PerdidaCantidad']) {
            String dob = '$perdida';
            if (dob.split('.').length < 2) {
              dob = '$dob.0';
            }
            doublelist.add(double.parse(dob));
          }
          productoModel.add(
            ProductoModel(
              id: 0,
              nombre: item['inventarioNom'],
              area: '',
              tipo: '',
              unidades: double.parse('${item['Unidades']}'),
              cantidadPorUnidad: 0,
              entrada: item['Entradas'].toDouble(),
              salida: item['Salidas'].toDouble(),
              perdidaCantidad: doublelist,
              perdidaRazones: List<String>.from(item['PerdidaRazon']),
              ultimoUsuario: item['UltimoUsuario'],
              ultimaModificacion: item['UltimaModificación'],
              codigoBarras: '',
              limiteProd: item['LimiteProd'],
              mensaje: '',
            ),
          );
        }
      } else {
        productoModel.add(
          ProductoModel(
            id: 0,
            nombre: '',
            tipo: '',
            unidades: 0,
            ultimaModificacion: '',
            cantidadPorUnidad: 0,
            area: '',
            entrada: 0,
            salida: 0,
            perdidaCantidad: [],
            perdidaRazones: [],
            ultimoUsuario: '',
            codigoBarras: '',
            limiteProd: 0,
            mensaje: 'Error: ${res.body}',
          ),
        );
      }
    } on TimeoutException catch (e) {
      productoModel.add(
        ProductoModel(
          id: 0,
          nombre: '',
          tipo: '',
          unidades: 0,
          ultimaModificacion: '',
          cantidadPorUnidad: 0,
          area: '',
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: '',
          codigoBarras: '',
          limiteProd: 0,
          mensaje: 'Error: ${e.message}',
        ),
      );
    } on SocketException catch (e) {
      productoModel.add(
        ProductoModel(
          id: 0,
          nombre: '',
          tipo: '',
          unidades: 0,
          ultimaModificacion: '',
          cantidadPorUnidad: 0,
          area: '',
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: '',
          codigoBarras: '',
          limiteProd: 0,
          mensaje: 'Error: ${e.message}',
        ),
      );
    } on http.ClientException catch (e) {
      productoModel.add(
        ProductoModel(
          id: 0,
          nombre: '',
          tipo: '',
          unidades: 0,
          ultimaModificacion: '',
          cantidadPorUnidad: 0,
          area: '',
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: '',
          codigoBarras: '',
          limiteProd: 0,
          mensaje: 'Error: ${e.message}',
        ),
      );
    } on Error catch (e) {
      productoModel.add(
        ProductoModel(
          id: 0,
          nombre: '',
          tipo: '',
          unidades: 0,
          ultimaModificacion: '',
          cantidadPorUnidad: 0,
          area: '',
          entrada: 0,
          salida: 0,
          perdidaCantidad: [],
          perdidaRazones: [],
          ultimoUsuario: '',
          codigoBarras: '',
          limiteProd: 0,
          mensaje: 'Error: $e',
        ),
      );
    }
    return productoModel;
  }

  static Future<String> addProducto(int id, int limite) async {
    String mensaje = '';
    String conexion = LocalStorage.local('conexion');
    try {
      final res = await http.post(
        Uri.parse('$conexion/almacen/'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': id,
          'locacion': LocalStorage.local('locación'),
          'limite': limite,
          'usuario': LocalStorage.local('usuario'),
        }),
      );
      mensaje = res.body;
    } on TimeoutException catch (e) {
      mensaje = 'Error: ${e.message}';
    } on SocketException catch (e) {
      mensaje = 'Error: ${e.message}';
    } on http.ClientException catch (e) {
      mensaje = 'Error: ${e.message}';
    } on Error catch (e) {
      mensaje = 'Error: $e';
    }
    return mensaje;
  }

  static Future<String> editarProducto(
    int id,
    String dato,
    String columna,
  ) async {
    String texto = '';
    String conexion = LocalStorage.local('conexion');
    try {
      final res = await http.put(
        Uri.parse('$conexion/almacen/Editar/$id/$columna'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'dato': dato,
          'usuario': LocalStorage.local('usuario'),
        }),
      );
      texto = res.body;
    } on TimeoutException catch (e) {
      texto = 'Error: ${e.message}';
    } on SocketException catch (e) {
      texto = 'Error: ${e.message}';
    } on http.ClientException catch (e) {
      texto = 'Error: ${e.message}';
    } on Error catch (e) {
      texto = 'Error: $e';
    }
    return texto;
  }

  static Future<String> guardarES(
    double entradas,
    double salidas,
    int id,
  ) async {
    String conexion = LocalStorage.local('conexion');
    String texto = 'Error: No se guardo la información.';
    try {
      final res = await http.put(
        Uri.parse('$conexion/almacen/ES/$id'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'entradas': entradas,
          'salidas': salidas,
          'usuario': LocalStorage.local('usuario'),
        }),
      );
      texto = res.body;
    } on TimeoutException catch (e) {
      texto = 'Error: ${e.message}';
    } on SocketException catch (e) {
      texto = 'Error: ${e.message}';
    } on http.ClientException catch (e) {
      texto = 'Error: ${e.message}';
    } on Error catch (e) {
      texto = 'Error: $e';
    }
    return texto;
  }

  static Future<String> guardarPerdidas(
    String razon,
    double cantidad,
    int id,
  ) async {
    String conexion = LocalStorage.local('conexion');
    String texto = 'Error: No se guardo la información.';
    try {
      final res = await http.put(
        Uri.parse('$conexion/almacen/Perdidas/$id'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'cantidad': cantidad,
          'razon': razon,
          'usuario': LocalStorage.local('usuario'),
        }),
      );
      texto = res.body;
    } on TimeoutException catch (e) {
      texto = 'Error: ${e.message}';
    } on SocketException catch (e) {
      texto = 'Error: ${e.message}';
    } on http.ClientException catch (e) {
      texto = 'Error: ${e.message}';
    } on Error catch (e) {
      texto = 'Error: $e';
    }
    return texto;
  }

  static Future<String> reiniciarESP() async {
    String texto = '';
    String conexion = LocalStorage.local('conexion');
    String almacen = LocalStorage.local('locación');
    try {
      final res = await http.put(
        Uri.parse('$conexion/almacen/reiniciarMovimientos/$almacen'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      texto = res.body;
    } on TimeoutException catch (e) {
      texto = 'Error: ${e.message}';
    } on SocketException catch (e) {
      texto = 'Error: ${e.message}';
    } on http.ClientException catch (e) {
      texto = 'Error: ${e.message}';
    } on Error catch (e) {
      texto = 'Error: $e';
    }
    return texto;
  }

  static Future<List<String>> getTipos() async {
    late List<String> tipos = [];
    String conexion = LocalStorage.local('conexion');
    try {
      var res = await http.get(
        Uri.parse('$conexion/tipos'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          tipos.add(item['Tipo']);
        }
      } else {
        tipos.add(res.body);
      }
    } on TimeoutException catch (e) {
      tipos.add('Error: ${e.message}');
    } on SocketException catch (e) {
      tipos.add('Error: ${e.message}');
    } on http.ClientException catch (e) {
      tipos.add('Error: ${e.message}');
    } on Error catch (e) {
      tipos.add('Error: $e');
    }
    return tipos;
  }

  static Future<List<String>> getAreas() async {
    late List<String> areas = [];
    String conexion = LocalStorage.local('conexion');
    try {
      var res = await http.get(
        Uri.parse('$conexion/areas'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          areas.add(item['Area']);
        }
      } else {
        areas.add(res.body);
      }
    } on TimeoutException catch (e) {
      areas.add('Error: ${e.message}');
    } on SocketException catch (e) {
      areas.add('Error: ${e.message}');
    } on http.ClientException catch (e) {
      areas.add('Error: ${e.message}');
    } on Error catch (e) {
      areas.add('Error: $e');
    }
    return areas;
  }
}
