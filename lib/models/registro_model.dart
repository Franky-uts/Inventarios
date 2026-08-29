import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inventarios/main.dart';
import 'package:inventarios/services/local_storage.dart';

class RegistroModel {
  String fecha;
  String hora;
  List<int> idProducto;
  List<String> articulos;
  List<String> tipos;
  List<String> areas;
  List<double> unidades;
  List<double> cajas;
  List<int> limite;
  String almacen;
  String usuario;
  String mensaje;

  RegistroModel({
    required this.fecha,
    required this.hora,
    required this.idProducto,
    required this.articulos,
    required this.tipos,
    required this.areas,
    required this.unidades,
    required this.cajas,
    required this.limite,
    required this.almacen,
    required this.usuario,
    required this.mensaje,
  });

  //Este es el Dummy de la clase "RegistroModel", usado para declarar un
  //"RegistroModel" con solo el valor mensaje con el mismo valor de la
  //variable mensaje del parámetro inicial.
  static RegistroModel dummy(String mensaje) {
    return RegistroModel(
      fecha: '',
      hora: '',
      idProducto: [],
      articulos: [],
      tipos: [],
      areas: [],
      unidades: [],
      cajas: [],
      limite: [],
      almacen: '',
      usuario: '',
      mensaje: mensaje,
    );
  }

  //Método get que regresa una lista con objetos de la clase RegistroModel a
  //través de una petición HTTP GET, en caso de que suceda algún error regresa
  //el error en forma de texto, requiere un filtro, un texto de búsqueda una
  //fecha inicial y otra final, las últimas 3 pueden estar vacías.
  static Future<List<RegistroModel>> getRegistros(
    String fechaInicial,
    String fechaFinal,
    String filtro,
    String busqueda,
  ) async {
    String locacion = LocalStorage.local('locación');
    List<RegistroModel> lista = [];
    String url = '${MyApp.url}:3000/registros/$locacion/$filtro';
    if (fechaInicial.isNotEmpty) url = '$url/$fechaInicial/$fechaFinal';
    url = '$url/$busqueda';
    try {
      var res = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          lista.add(
            RegistroModel(
              fecha: item['Fecha'],
              hora: item['Hora'],
              idProducto: [],
              articulos: [],
              tipos: [],
              areas: [],
              unidades: [],
              cajas: [],
              limite: [],
              almacen: '',
              usuario: item['Usuario'],
              mensaje: '',
            ),
          );
        }
      } else {
        lista.add(dummy(res.body));
      }
    } on TimeoutException catch (e) {
      lista.add(dummy('${e.message}'));
    } on SocketException catch (e) {
      lista.add(dummy(e.message.toString()));
    } on http.ClientException catch (e) {
      lista.add(dummy(e.message));
    } on Error catch (e) {
      lista.add(dummy('$e'));
    }
    return lista;
  }

  //Método get que regresa un objeto de la clase RegistroModel a través de una
  //petición HTTP GET, en caso de que suceda algún error regresa el error en
  //forma de texto, requiere la fecha, la hora y el ussuario que realizo el
  //registro a consultar.
  static Future<RegistroModel> getRegistro(
    String fecha,
    String hora,
    String usuario,
  ) async {
    RegistroModel registro;
    try {
      var res = await http.get(
        Uri.parse('${MyApp.url}:3000/registros/Registro/$fecha/$hora/$usuario'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      registro = dummy(res.body);
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          List<double> uniList = [];
          List<double> cajaList = [];
          for (double unidad in item['Unidades']) {
            String dob = '$unidad';
            if (dob.split('.').length < 2) {
              dob = '$dob.0';
            }
            uniList.add(double.parse(dob));
          }
          for (double caja in item['Cajas']) {
            String dob = '$caja';
            if (dob.split('.').length < 2) {
              dob = '$dob.0';
            }
            cajaList.add(double.parse(dob));
          }
          registro = RegistroModel(
            fecha: item['Fecha'],
            hora: item['Hora'],
            idProducto: List<int>.from(item['idProductos']),
            articulos: List<String>.from(item['Articulos']),
            tipos: List<String>.from(item['Tipos']),
            areas: List<String>.from(item['Areas']),
            unidades: uniList,
            cajas: cajaList,
            limite: List<int>.from(item['Limites']),
            almacen: item['Almacen'],
            usuario: item['Usuario'],
            mensaje: '',
          );
        }
      } else {
        registro = dummy(res.body);
      }
    } on TimeoutException catch (e) {
      registro = dummy('${e.message}');
    } on SocketException catch (e) {
      registro = dummy(e.message.toString());
    } on http.ClientException catch (e) {
      registro = dummy(e.message);
    } on Error catch (e) {
      registro = dummy('$e');
    }
    return registro;
  }

  //Método get que regresa un texto a través de una petición HTTP POST, en caso
  //de que suceda algún error regresa el error en forma de texto, este método se
  //encarga de enviar información relacionada con un registro en la base de
  //datos para añadir dicho nuevo registro, requiere una lista de enteros, los
  //cuáles representan la id de los productos; dos listas de reales, los cuales
  //representan las unidades individuales hay por producto y los contenedores,
  //como botes, cajas, costales, etc.
  static Future<String> registroCompleto(
    List<int> idProductos,
    List<double> unidades,
    List<double> cajas,
  ) async {
    String mensaje = '';
    try {
      final res = await http.post(
        Uri.parse('${MyApp.url}:3000/registros/'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'productos': idProductos,
          'unidades': unidades,
          'cajas': cajas,
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
}
