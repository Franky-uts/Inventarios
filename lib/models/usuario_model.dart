import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class usuarioModel {
  String nombre;
  String puesto;

  usuarioModel({required this.nombre, required this.puesto});

  static usuarioModel usuarioProvisional() {
    usuarioModel usuario = usuarioModel(nombre: "Usuario", puesto: "Encargado");
    return usuario;
  }

  static Future<usuarioModel> getUsuario(String usuario, String contr) async {
    late usuarioModel usuarioFuture;
    try{
      final res = await http.get(
        Uri.parse("http://192.168.1.179:4000/usuarios/${usuario}/${contr}"),
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        usuarioFuture = usuarioModel(
          nombre: datos[0]["Nombre"],
          puesto: datos[0]["Puesto"],
        );
      } else {
        usuarioFuture = usuarioModel(nombre: "error", puesto: res.body);
      }
    }on TimeoutException catch(e){
      print(e.message.toString());
      usuarioFuture = usuarioModel(nombre: "error", puesto: e.message.toString());
    }on SocketException catch(e){
      print(e.message.toString());
      usuarioFuture = usuarioModel(nombre: "error", puesto: e.message.toString());
    } on Error catch(e){
      print(e.toString());
      usuarioFuture = usuarioModel(nombre: "error", puesto: e.toString());
    }
    return usuarioFuture;
  }
}
