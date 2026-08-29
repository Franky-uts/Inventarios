import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:inventarios/main.dart';
import 'dart:convert';

import 'package:inventarios/services/local_storage.dart';

class UsuarioModel {
  String nombre;
  String puesto;
  String locacion;

  UsuarioModel({
    required this.nombre,
    required this.puesto,
    required this.locacion,
  });

  //Método get que regresa un objeto de la clase UsuarioModel a través de una
  //petición HTTP GET, en caso de que suceda algún error regresa el error en
  //forma de texto, requiere un nombre de usuario y una contraseña en forma de
  //texto.
  static Future<UsuarioModel> getUsuario(String usuario, String contr) async {
    UsuarioModel usuarioFuture;
    try {
      final res = await http.get(
        Uri.parse('${MyApp.url}:3000/usuarios/$usuario/$contr'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      usuarioFuture = UsuarioModel(
        nombre: 'error',
        puesto: res.body,
        locacion: res.body,
      );
      if (res.statusCode == 200 && res.reasonPhrase == 'OK') {
        final datos = json.decode(res.body);
        usuarioFuture = UsuarioModel(
          nombre: datos[0]['Nombre'],
          puesto: datos[0]['Puesto'],
          locacion: datos[0]['Locacion'],
        );
      }
    } on TimeoutException catch (e) {
      usuarioFuture = UsuarioModel(
        nombre: 'error',
        puesto: '${e.message}',
        locacion: '${e.message}',
      );
    } on SocketException catch (e) {
      usuarioFuture = UsuarioModel(
        nombre: 'error',
        puesto: e.message,
        locacion: e.message,
      );
    } on http.ClientException catch (e) {
      usuarioFuture = UsuarioModel(
        nombre: 'error',
        puesto: e.message,
        locacion: e.message,
      );
    } on Error catch (e) {
      usuarioFuture = UsuarioModel(
        nombre: 'error',
        puesto: '$e',
        locacion: '$e',
      );
    }
    return usuarioFuture;
  }

  //Método get que regresa un texto a través de una petición HTTP PUT, en caso
  //de que suceda algún error regresa el error en forma de texto, este método se
  //encarga de enviar información relacionada con un usuario en la base de datos
  //para editar información del mismo usuario, requiere el nombre del dato que
  //se va a editar y el nuevo valor del dato a editar.
  static Future<String> cambiarInfo(String columna, String dato) async {
    String mensaje = '';
    String usuario = LocalStorage.local('usuario');
    try {
      final res = await http.put(
        Uri.parse('${MyApp.url}:3000/usuarios/$usuario/$columna'),
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dato': dato}),
      );
      mensaje = 'Error: ${res.body}';
      if (res.statusCode == 200) {
        mensaje = 'Cambio realizado con éxito.';
      }
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
