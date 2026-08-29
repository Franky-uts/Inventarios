import 'package:flutter/material.dart';
import 'package:inventarios/pages/inicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Clase que se encarga de guardar la información en la aplicación para que se
//pueda utilizar entre páginas, o cuando se vuelva abrir al momento de volver
//abrir la aplicación o cuando se vuelva a consultar la página.
class LocalStorage {
  static late SharedPreferences preferencias;

  //Este método se encarga de devolver las preferencias guardadas.
  static Future<void> getPreferencias() async {
    preferencias = await SharedPreferences.getInstance();
  }

  //Este método se encarga de devolver un texto guardado que se este bajo la
  //clave igual al texto indicado en el parámetro, en caso de que ningún texto
  //este guardado bajo la preferencia buscada entonces devolverá "null".
  static String local(String clave) {
    String res = LocalStorage.preferencias.getString(clave).toString();
    return res;
  }

  //Este método se encarga de devolver una lista guardada que se esté bajo la
  //clave igual al texto indicado en el parámetro, en caso de que ningún texto
  //este guardado bajo la preferencia buscada entonces devolverá "null".
  static List<String>? localLista(String clave) {
    List<String>? res = LocalStorage.preferencias.getStringList(clave);
    return res;
  }

  //Este método se encarga de guardar un texto en la aplicación bajo una clave
  //como referencia, en caso de que algún texto este guardado bajo la misma
  //clave este cambiara al nuevo valor.
  static Future<void> set(String clave, String valor) async {
    await LocalStorage.preferencias.setString(clave, valor);
  }

  //Este método se encarga de guardar una lista en la aplicación bajo una clave
  //como referencia, en caso de que alguna lista esté guardada bajo la misma
  //clave este cambiara a la nueva lista.
  static Future<void> setLista(String clave, List<String> valor) async {
    await LocalStorage.preferencias.setStringList(clave, valor);
  }

  //Este método se encarga de borrar una clave junto con el valor que tiene
  //guardado.
  static Future<void> eliminar(String clave) async {
    await LocalStorage.preferencias.remove(clave);
  }

  //Este método se encarga de borrar todas las claves que se crean al momento de
  //iniciar sesión junto con el valor que tienen guardadas y, por último, te
  //manda a la página dedicada a iniciar sesión.
  static Future<void> logout(BuildContext ctx) async {
    await LocalStorage.eliminar('usuario');
    await LocalStorage.eliminar('busqueda');
    await LocalStorage.eliminar('puesto');
    await LocalStorage.eliminar('locación');
    if (ctx.mounted) {
      Navigator.pushReplacement(
        ctx,
        MaterialPageRoute(builder: (context) => Inicio()),
      );
    }
  }
}
