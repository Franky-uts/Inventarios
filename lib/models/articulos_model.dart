import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:inventarios/main.dart';
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
  bool materia;
  String mensaje;

  ArticulosModel({
    required this.id,
    required this.nombre,
    required this.area,
    required this.tipo,
    required this.codigoBarras,
    required this.cantidadPorUnidad,
    required this.precio,
    required this.materia,
    required this.mensaje,
  });

  //Este es el Dummy de la clase "ArticulosModel", usado para declarar un
  //"ArticulosModel" con solo el valor mensaje con el mismo valor de la
  //variable mensaje del parámetro inicial.
  static ArticulosModel dummy(String mensaje) {
    return ArticulosModel(
      id: 0,
      nombre: '',
      tipo: '',
      cantidadPorUnidad: 0,
      area: '',
      codigoBarras: '',
      precio: 0,
      materia: false,
      mensaje: mensaje,
    );
  }

  //Método get que regresa una lista con objetos de la clase ArticulosModel a
  //través de una petición HTTP GET, en caso de que suceda algún error regresa
  //el error en forma de texto, requiere un filtro y el texto de búsqueda, este
  //último puede estar vacío.
  static Future<List<ArticulosModel>> getArticulos(
    String filtro,
    String busqueda,
  ) async {
    String locacion = LocalStorage.local('locación');
    List<ArticulosModel> articulosFuture = [];
    if (locacion.isEmpty || locacion == 'null') {
      articulosFuture.add(dummy('No hay locación establecida'));
    } else {
      try {
        var res = await http.get(
          Uri.parse('${MyApp.url}:3000/articulos/$filtro/$busqueda'),
          headers: {
            'Accept': 'application/json',
            'content-type': 'application/json; charset=UTF-8',
          },
        );
        if (res.statusCode == 200) {
          final datos = json.decode(res.body);
          for (var item in datos) {
            articulosFuture.add(
              ArticulosModel(
                id: item['id'],
                nombre: item['Nombre'],
                tipo: item['Tipo'],
                cantidadPorUnidad: item['CantidadPorUnidad'].toDouble(),
                area: item['Area'],
                codigoBarras: item['CodigoBarras'],
                precio: item['Precio'].toDouble(),
                materia: item['MateriaPrima'],
                mensaje: '',
              ),
            );
          }
        } else {
          articulosFuture.add(dummy(res.body));
        }
      } on TimeoutException catch (e) {
        articulosFuture.add(dummy('${e.message}'));
      } on SocketException catch (e) {
        articulosFuture.add(dummy(e.message));
      } on http.ClientException catch (e) {
        articulosFuture.add(dummy(e.message));
      } on Error catch (e) {
        articulosFuture.add(dummy('$e'));
      }
    }
    return articulosFuture;
  }

  //Método get que regresa un objeto de la clase ArticulosModel a través de una
  //petición HTTP GET, en caso de que suceda algún error regresa el error en
  //forma de texto, requiere el id del articulo a consultar.
  static Future<ArticulosModel> getArticulo(int id) async {
    ArticulosModel articulo;
    try {
      var res = await http.get(
        Uri.parse('${MyApp.url}:3000/articulos/Articulo/$id'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      articulo = dummy(res.body);
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          articulo = ArticulosModel(
            id: item['id'],
            nombre: item['Nombre'],
            tipo: item['Tipo'],
            cantidadPorUnidad: item['CantidadPorUnidad'].toDouble(),
            area: item['Area'],
            codigoBarras: item['CodigoBarras'],
            precio: item['Precio'].toDouble(),
            materia: item['MateriaPrima'],
            mensaje: '',
          );
        }
      }
    } on TimeoutException catch (e) {
      articulo = dummy('${e.message}');
    } on SocketException catch (e) {
      articulo = dummy(e.message);
    } on http.ClientException catch (e) {
      articulo = dummy(e.message);
    } on Error catch (e) {
      articulo = dummy('$e');
    }
    return articulo;
  }

  //Método get que regresa un texto a través de una petición HTTP POST, en caso
  //de que suceda algún error regresa el error en forma de texto, este método se
  //encarga de enviar información relacionada con un artículo en la base de
  //datos para añadir dicho nuevo artículo, requiere un nombre, un tipo y un
  //área un código de barras como textos, una cantidad por unidad y un precio
  //como número real y un booleano que definirá si es materia prima o no.
  static Future<String> addArticulo(
    String nombre,
    String tipo,
    String area,
    double cantidad,
    String barras,
    double precio,
    bool materia,
  ) async {
    late String articulosFuture;
    try {
      final res = await http.post(
        Uri.parse('${MyApp.url}:3000/articulos'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'nombre': nombre,
          'tipo': tipo,
          'area': area,
          'cantidad': cantidad,
          'barras': barras,
          'precio': precio,
          'materia': materia,
        }),
      );
      articulosFuture = res.body;
    } on TimeoutException catch (e) {
      articulosFuture = 'Error: ${e.message}';
    } on SocketException catch (e) {
      articulosFuture = 'Error: ${e.message}';
    } on http.ClientException catch (e) {
      articulosFuture = 'Error: ${e.message}';
    } on Error catch (e) {
      articulosFuture = 'Error: $e';
    }
    return articulosFuture;
  }

  //Método get que regresa un texto a través de una petición HTTP PUT, en caso
  //de que suceda algún error regresa el error en forma de texto, este método se
  //encarga de enviar información relacionada con un artículo en la base de
  //datos para editar dicho artículo, requiere el id del articulo como entero,
  //el dato que se va a cambiar y el valor del dato que se va a cambiar en forma
  //de texto.
  static Future<String> editarArticulo(
    int id,
    String dato,
    String columna,
  ) async {
    late String articulosFuture;
    try {
      final res = await http.put(
        Uri.parse('${MyApp.url}:3000/articulos/$id'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dato': dato, 'columna': columna}),
      );
      articulosFuture = res.body;
    } on TimeoutException catch (e) {
      articulosFuture = 'Error: ${e.message}';
    } on SocketException catch (e) {
      articulosFuture = 'Error: ${e.message}';
    } on http.ClientException catch (e) {
      articulosFuture = 'Error: ${e.message}';
    } on Error catch (e) {
      articulosFuture = 'Error: $e';
    }
    return articulosFuture;
  }
}
