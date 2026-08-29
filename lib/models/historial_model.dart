import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:inventarios/main.dart';
import 'package:inventarios/services/local_storage.dart';

class HistorialModel {
  int id;
  String fecha;
  String nombre;
  String area;
  int movimientos;
  List<double> entradas;
  List<double> salidas;
  List<int> perdidas;
  List<String> razones;
  List<double> cantidades;
  List<String> horasModificacion;
  List<String> usuarioModificacion;
  String mensaje;

  HistorialModel({
    required this.id,
    required this.fecha,
    required this.nombre,
    required this.area,
    required this.movimientos,
    required this.entradas,
    required this.salidas,
    required this.perdidas,
    required this.razones,
    required this.cantidades,
    required this.horasModificacion,
    required this.usuarioModificacion,
    required this.mensaje,
  });

  //Este es el Dummy de la clase "HistorialModel", usado para declarar un
  //"HistorialModel" con solo el valor mensaje con el mismo valor de la
  //variable mensaje del parámetro inicial.
  static HistorialModel dummy(String mensaje) {
    return HistorialModel(
      id: 0,
      fecha: '',
      nombre: '',
      area: '',
      movimientos: 0,
      entradas: [],
      salidas: [],
      perdidas: [],
      razones: [],
      cantidades: [],
      horasModificacion: [],
      usuarioModificacion: [],
      mensaje: mensaje,
    );
  }

  //Método get que regresa una lista con objetos de la clase HistorialModel a
  //través de una petición HTTP GET, en caso de que suceda algún error regresa
  //el error en forma de texto, requiere un filtro, un texto de búsqueda una
  //fecha inicial y otra final, las últimas 3 pueden estar vacías.
  static Future<List<HistorialModel>> getHistorial(
    String fechaInicial,
    String fechaFinal,
    String filtro,
    String busqueda,
  ) async {
    String locacion = LocalStorage.local('locación');
    List<HistorialModel> historialFuture = [];
    if (locacion.isEmpty || locacion == 'null') {
      historialFuture.add(dummy('No hay locación establecida'));
    } else {
      try {
        String url = '${MyApp.url}:3000/historial/$locacion/$filtro';
        if (fechaInicial.isNotEmpty) url = '$url/$fechaInicial/$fechaFinal';
        url = '$url/$busqueda';
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
            historialFuture.add(
              HistorialModel(
                id: item['id'],
                fecha: item['Fecha'],
                nombre: item['Nombre'],
                area: item['Area'],
                movimientos: item['Movimientos'],
                entradas: [],
                salidas: [],
                perdidas: [],
                razones: [],
                cantidades: [],
                horasModificacion: [],
                usuarioModificacion: [],
                mensaje: '',
              ),
            );
          }
        } else {
          historialFuture.add(dummy(res.body));
        }
      } on TimeoutException catch (e) {
        historialFuture.add(dummy('${e.message}'));
      } on SocketException catch (e) {
        historialFuture.add(dummy(e.message.toString()));
      } on http.ClientException catch (e) {
        historialFuture.add(dummy(e.message));
      } on Error catch (e) {
        historialFuture.add(dummy('$e'));
      }
    }
    return historialFuture;
  }

  //Método get que regresa una lista con objetos de la clase HistorialModel
  //llenados con cierta información a través de una petición HTTP GET, en caso
  //de que suceda algún error regresa el error en forma de texto, requiere una
  //fecha inicial y otra final.
  static Future<List<HistorialModel>> getHistorialRango(
    String fechaInicial,
    String fechaFinal,
  ) async {
    String locacion = LocalStorage.local('locación');
    List<HistorialModel> historialFuture = [];
    try {
      var res = await http.get(
        Uri.parse(
          '${MyApp.url}:3000/historial/$locacion/id/$fechaInicial/$fechaFinal',
        ),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          historialFuture.add(
            HistorialModel(
              id: item['id'],
              fecha: item['Fecha'],
              nombre: item['Nombre'],
              area: item['Area'],
              movimientos: item['Movimientos'],
              entradas: [],
              salidas: [],
              perdidas: [],
              razones: [],
              cantidades: [],
              horasModificacion: [],
              usuarioModificacion: [],
              mensaje: '',
            ),
          );
        }
      } else {
        historialFuture.add(dummy(res.body));
      }
    } on TimeoutException catch (e) {
      historialFuture.add(dummy('${e.message}'));
    } on SocketException catch (e) {
      historialFuture.add(dummy(e.message));
    } on http.ClientException catch (e) {
      historialFuture.add(dummy(e.message));
    } on Error catch (e) {
      historialFuture.add(dummy('$e'));
    }
    return historialFuture;
  }

  //Método get que regresa una lista con objetos de la clase HistorialModel a
  //través de una petición HTTP GET, en caso de que suceda algún error regresa
  //el error en forma de texto, requiere una fecha inicial y otra final.
  static Future<List<HistorialModel>> getAllHistorial(
    String fechaInicial,
    String fechaFinal,
  ) async {
    String locacion = LocalStorage.local('locación');
    List<HistorialModel> historialFuture = [];
    try {
      var res = await http.get(
        Uri.parse(
          '${MyApp.url}:3000/historial/$locacion/Fecha/$fechaInicial/$fechaFinal',
        ),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          List<double> doublelist = [];
          List<double> entradaslist = [];
          List<double> salidaslist = [];
          for (double perdida in item['PerdidaCantidad']) {
            String dob = '$perdida';
            if (dob.split('.').length < 2) {
              dob = '$dob.0';
            }
            doublelist.add(double.parse(dob));
          }
          for (int i = 0; i < item['Movimientos']; i++) {
            String ent = '${item['Salidas'][i]}';
            String sal = '${item['Entradas'][i]}';
            if (ent.split('.').length < 2) {
              ent = '$ent.0';
            }
            if (sal.split('.').length < 2) {
              sal = '$sal.0';
            }
            entradaslist.add(double.parse(ent));
            salidaslist.add(double.parse(sal));
          }
          historialFuture.add(
            HistorialModel(
              id: item['id'],
              fecha: item['Fecha'],
              nombre: item['Nombre'],
              area: item['Area'],
              movimientos: item['Movimientos'],
              entradas: entradaslist,
              salidas: salidaslist,
              perdidas: List<int>.from(item['Perdidas']),
              razones: List<String>.from(item['PerdidaRazon']),
              cantidades: doublelist,
              horasModificacion: List<String>.from(item['ModificacionHoras']),
              usuarioModificacion: List<String>.from(
                item['ModificacionUsuario'],
              ),
              mensaje: '',
            ),
          );
        }
      } else {
        historialFuture.add(dummy(res.body));
      }
    } on TimeoutException catch (e) {
      historialFuture.add(dummy('${e.message}'));
    } on SocketException catch (e) {
      historialFuture.add(dummy(e.message));
    } on http.ClientException catch (e) {
      historialFuture.add(dummy(e.message));
    } on Error catch (e) {
      historialFuture.add(dummy('$e'));
    }
    return historialFuture;
  }

  //Método get que regresa un objeto de la clase HistorialModel a través de una
  //petición HTTP GET, en caso de que suceda algún error regresa el error en
  //forma de texto, requiere el id del producto y la fecha a consultar.
  static Future<HistorialModel> getHistorialInfo(int id, String fecha) async {
    String locacion = LocalStorage.local('locación');
    HistorialModel historial;
    try {
      var res = await http.get(
        Uri.parse('${MyApp.url}:3000/historial/Historial/$locacion/$id/$fecha'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      historial = dummy(res.body);
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          List<double> doublelist = [];
          List<double> entradaslist = [];
          List<double> salidaslist = [];
          for (double perdida in item['PerdidaCantidad']) {
            String dob = '$perdida';
            if (dob.split('.').length < 2) {
              dob = '$dob.0';
            }
            doublelist.add(double.parse(dob));
          }
          for (int i = 0; i < item['Movimientos']; i++) {
            String ent = '${item['Salidas'][i]}';
            String sal = '${item['Entradas'][i]}';
            if (ent.split('.').length < 2) {
              ent = '$ent.0';
            }
            if (sal.split('.').length < 2) {
              sal = '$sal.0';
            }
            entradaslist.add(double.parse(ent));
            salidaslist.add(double.parse(sal));
          }
          historial = HistorialModel(
            id: item['id'],
            fecha: item['Fecha'],
            nombre: item['Nombre'],
            area: item['Area'],
            movimientos: item['Movimientos'],
            entradas: entradaslist,
            salidas: salidaslist,
            perdidas: List<int>.from(item['Perdidas']),
            razones: List<String>.from(item['PerdidaRazon']),
            cantidades: doublelist,
            horasModificacion: List<String>.from(item['ModificacionHoras']),
            usuarioModificacion: List<String>.from(
              item['ModificacionUsuario'],
            ),
            mensaje: '',
          );
        }
      }
    } on TimeoutException catch (e) {
      historial = dummy('${e.message}');
    } on SocketException catch (e) {
      historial = dummy(e.message);
    } on http.ClientException catch (e) {
      historial = dummy(e.message);
    } on Error catch (e) {
      historial = dummy('$e');
    }
    return historial;
  }
}
