import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsuarioModel {
  String nombre;
  String puesto;
  String locacion;

  UsuarioModel({
    required this.nombre,
    required this.puesto,
    required this.locacion,
  });

  static UsuarioModel usuarioProvisional() {
    UsuarioModel usuario = UsuarioModel(
      nombre: "Usuario",
      puesto: "Encargado",
      locacion: "Almacen",
    );
    return usuario;
  }

  static Future<UsuarioModel> getUsuario(String usuario, String contr) async {
    late UsuarioModel usuarioFuture;
    try {
      final res = await http.get(
        Uri.parse("http://189.187.144.139:3000/usuarios/$usuario/$contr"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
      );
      if (res.statusCode == 200 && res.reasonPhrase == 'OK') {
        final datos = json.decode(res.body);
        usuarioFuture = UsuarioModel(
          nombre: datos[0]["Nombre"],
          puesto: datos[0]["Puesto"],
          locacion: datos[0]["Locacion"],
        );
      } else {
        usuarioFuture = UsuarioModel(
          nombre: "error",
          puesto: res.body,
          locacion: res.body,
        );
      }
    } on TimeoutException catch (e) {
      usuarioFuture = UsuarioModel(
        nombre: "error",
        puesto: e.message.toString(),
        locacion: e.message.toString(),
      );
    } on SocketException catch (e) {
      usuarioFuture = UsuarioModel(
        nombre: "error",
        puesto: e.message.toString(),
        locacion: e.message.toString(),
      );
    } on Error catch (e) {
      usuarioFuture = UsuarioModel(
        nombre: "error",
        puesto: e.toString(),
        locacion: e.toString(),
      );
    }
    return usuarioFuture;
  }
}
