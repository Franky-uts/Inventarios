import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class UsuarioModel {
  String nombre;
  String puesto;

  UsuarioModel({required this.nombre, required this.puesto});

  static UsuarioModel usuarioProvisional() {
    UsuarioModel usuario = UsuarioModel(nombre: "Usuario", puesto: "Encargado");
    return usuario;
  }

  static Future<UsuarioModel> getUsuario(String usuario, String contr) async {
    late UsuarioModel usuarioFuture;
    try{
      final res = await http.get(
        Uri.parse("http://192.168.1.93:4000/usuarios/$usuario/$contr"),
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        usuarioFuture = UsuarioModel(
          nombre: datos[0]["Nombre"],
          puesto: datos[0]["Puesto"],
        );
      } else {
        usuarioFuture = UsuarioModel(nombre: "error", puesto: res.body);
      }
    }on TimeoutException catch(e){
      //print(e.message.toString());
      usuarioFuture = UsuarioModel(nombre: "error", puesto: e.message.toString());
    }on SocketException catch(e){
      //print(e.message.toString());
      usuarioFuture = UsuarioModel(nombre: "error", puesto: e.message.toString());
    } on Error catch(e){
      //print(e.toString());
      usuarioFuture = UsuarioModel(nombre: "error", puesto: e.toString());
    }
    return usuarioFuture;
  }
}
