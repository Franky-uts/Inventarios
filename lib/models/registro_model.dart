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
    required this.almacen,
    required this.usuario,
    required this.mensaje,
  });

  static RegistroModel dummy(String mensaje) {
    return RegistroModel(
      fecha: '',
      hora: '',
      idProducto: [],
      articulos: [],
      tipos: [],
      areas: [],
      unidades: [],
      almacen: '',
      usuario: '',
      mensaje: mensaje,
    );
  }

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

  static Future<RegistroModel> getRegistro(String fecha, String hora, String usuario) async {
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
          List<double> doublelist = [];
          for (double unidad in item['Unidades']) {
            String dob = '$unidad';
            if (dob.split('.').length < 2) {
              dob = '$dob.0';
            }
            doublelist.add(double.parse(dob));
          }
          registro = RegistroModel(
            fecha: item['Fecha'],
            hora: item['Hora'],
            idProducto: List<int>.from(item['idProductos']),
            articulos: List<String>.from(item['Articulos']),
            tipos: List<String>.from(item['Tipos']),
            areas: List<String>.from(item['Areas']),
            unidades: doublelist,
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
}
