import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
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

  static Future<UsuarioModel> getUsuario(
    String usuario,
    String contr,
    String ip,
  ) async {
    UsuarioModel usuarioFuture;
    try {
      final res = await http.get(
        Uri.parse('http://$ip:3000/usuarios/$usuario/$contr'),
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

  static Future<String> cambiarInfo(String columna, String dato) async {
    String mensaje = '';
    String conexion = LocalStorage.local('conexion');
    String usuario = LocalStorage.local('usuario');
    try {
      final res = await http.put(
        Uri.parse('$conexion/usuarios/$usuario/$columna'),
        headers: {
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
