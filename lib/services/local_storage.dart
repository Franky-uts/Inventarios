import 'package:flutter/material.dart';
import 'package:inventarios/pages/inicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences preferencias;

  static Future<void> getPreferencias() async {
    preferencias = await SharedPreferences.getInstance();
  }

  static String local(String clave) {
    String res = LocalStorage.preferencias.getString(clave).toString();
    return res;
  }

  static Future<void> set(String clave, String valor) async {
    await LocalStorage.preferencias.setString(clave, valor);
  }

  static Future<void> eliminar(String clave) async {
    await LocalStorage.preferencias.remove(clave);
  }

  static Future<void> logout(BuildContext ctx) async {
    await LocalStorage.eliminar('usuario');
    await LocalStorage.eliminar('usuario');
    await LocalStorage.eliminar('puesto');
    await LocalStorage.eliminar('locación');
    await LocalStorage.eliminar('conexion');
    if (ctx.mounted) {
      Navigator.pushReplacement(
        ctx,
        MaterialPageRoute(builder: (context) => Inicio()),
      );
    }
  }
}
