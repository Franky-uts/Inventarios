import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:inventarios/services/local_storage.dart';

class HistorialModel {
  int id;
  String fecha;
  String nombre;
  String area;
  int movimientos;
  List<double> unidades;
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
    required this.unidades,
    required this.entradas,
    required this.salidas,
    required this.perdidas,
    required this.razones,
    required this.cantidades,
    required this.horasModificacion,
    required this.usuarioModificacion,
    required this.mensaje,
  });

  static Future<List<HistorialModel>> getHistorial(
    String fechaInicial,
    String fechaFinal,
    String filtro,
    String busqueda,
  ) async {
    String conexion = LocalStorage.local('conexion');
    String locacion = LocalStorage.local('locación');
    List<HistorialModel> historialFuture = [];
    if (locacion.isEmpty || locacion == 'null') {
      historialFuture.add(
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: 'No hay locación establecida',
        ),
      );
    } else {
      try {
        String url = '$conexion/historial/$locacion/$filtro';
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
                unidades: [],
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
          historialFuture.add(
            HistorialModel(
              id: 0,
              fecha: '',
              nombre: '',
              area: '',
              movimientos: 0,
              unidades: [],
              entradas: [],
              salidas: [],
              perdidas: [],
              razones: [],
              cantidades: [],
              horasModificacion: [],
              usuarioModificacion: [],
              mensaje: res.body,
            ),
          );
        }
      } on TimeoutException catch (e) {
        historialFuture.add(
          HistorialModel(
            id: 0,
            fecha: '',
            nombre: '',
            area: '',
            movimientos: 0,
            unidades: [],
            entradas: [],
            salidas: [],
            perdidas: [],
            razones: [],
            cantidades: [],
            horasModificacion: [],
            usuarioModificacion: [],
            mensaje: '${e.message}',
          ),
        );
      } on SocketException catch (e) {
        historialFuture.add(
          HistorialModel(
            id: 0,
            fecha: '',
            nombre: '',
            area: '',
            movimientos: 0,
            unidades: [],
            entradas: [],
            salidas: [],
            perdidas: [],
            razones: [],
            cantidades: [],
            horasModificacion: [],
            usuarioModificacion: [],
            mensaje: e.message.toString(),
          ),
        );
      } on http.ClientException catch (e) {
        historialFuture.add(
          HistorialModel(
            id: 0,
            fecha: '',
            nombre: '',
            area: '',
            movimientos: 0,
            unidades: [],
            entradas: [],
            salidas: [],
            perdidas: [],
            razones: [],
            cantidades: [],
            horasModificacion: [],
            usuarioModificacion: [],
            mensaje: e.message,
          ),
        );
      } on Error catch (e) {
        historialFuture.add(
          HistorialModel(
            id: 0,
            fecha: '',
            nombre: '',
            area: '',
            movimientos: 0,
            unidades: [],
            entradas: [],
            salidas: [],
            perdidas: [],
            razones: [],
            cantidades: [],
            horasModificacion: [],
            usuarioModificacion: [],
            mensaje: '$e',
          ),
        );
      }
    }
    return historialFuture;
  }

  static Future<List<HistorialModel>> getHistorialRango(
    String fechaInicial,
    String fechaFinal,
  ) async {
    String conexion = LocalStorage.local('conexion');
    String locacion = LocalStorage.local('locación');
    List<HistorialModel> historialFuture = [];
    try {
      var res = await http.get(
        Uri.parse('$conexion/historial/$locacion/id/$fechaInicial/$fechaFinal'),
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
              unidades: [],
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
        historialFuture.add(
          HistorialModel(
            id: 0,
            fecha: '',
            nombre: '',
            area: '',
            movimientos: 0,
            unidades: [],
            entradas: [],
            salidas: [],
            perdidas: [],
            razones: [],
            cantidades: [],
            horasModificacion: [],
            usuarioModificacion: [],
            mensaje: res.body,
          ),
        );
      }
    } on TimeoutException catch (e) {
      historialFuture.add(
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: '${e.message}',
        ),
      );
    } on SocketException catch (e) {
      historialFuture.add(
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: e.message,
        ),
      );
    } on http.ClientException catch (e) {
      historialFuture.add(
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: e.message,
        ),
      );
    } on Error catch (e) {
      historialFuture.add(
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: '$e',
        ),
      );
    }
    return historialFuture;
  }

  static Future<List<HistorialModel>> getAllHistorial(
    String fechaInicial,
    String fechaFinal,
  ) async {
    String conexion = LocalStorage.local('conexion');
    String locacion = LocalStorage.local('locación');
    List<HistorialModel> historialFuture = [];
    try {
      var res = await http.get(
        Uri.parse(
          '$conexion/historial/$locacion/Fecha/$fechaInicial/$fechaFinal',
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
          List<double> unidadeslist = [];
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
            String uni = '${item['Unidades'][i]}';
            String ent = '${item['Salidas'][i]}';
            String sal = '${item['Entradas'][i]}';
            if (uni.split('.').length < 2) {
              uni = '$uni.0';
            }
            if (ent.split('.').length < 2) {
              ent = '$ent.0';
            }
            if (sal.split('.').length < 2) {
              sal = '$sal.0';
            }
            unidadeslist.add(double.parse(uni));
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
              unidades: unidadeslist,
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
        historialFuture.add(
          HistorialModel(
            id: 0,
            fecha: '',
            nombre: '',
            area: '',
            movimientos: 0,
            unidades: [],
            entradas: [],
            salidas: [],
            perdidas: [],
            razones: [],
            cantidades: [],
            horasModificacion: [],
            usuarioModificacion: [],
            mensaje: res.body,
          ),
        );
      }
    } on TimeoutException catch (e) {
      historialFuture.add(
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: '${e.message}',
        ),
      );
    } on SocketException catch (e) {
      historialFuture.add(
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: e.message,
        ),
      );
    } on http.ClientException catch (e) {
      historialFuture.add(
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: e.message,
        ),
      );
    } on Error catch (e) {
      historialFuture.add(
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: '$e',
        ),
      );
    }
    return historialFuture;
  }

  static Future<HistorialModel> getHistorialDatos(int id, String fecha) async {
    String conexion = LocalStorage.local('conexion');
    String locacion = LocalStorage.local('locación');
    HistorialModel historial;
    try {
      var res = await http.get(
        Uri.parse('$conexion/historial/Historial/$locacion/$id/$fecha'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      historial = HistorialModel(
        id: 0,
        fecha: '',
        nombre: '',
        area: '',
        movimientos: 0,
        unidades: [],
        entradas: [],
        salidas: [],
        perdidas: [],
        razones: [],
        cantidades: [],
        horasModificacion: [],
        usuarioModificacion: [],
        mensaje: res.body,
      );
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          historial = HistorialModel(
            id: item['id'],
            fecha: item['Fecha'],
            nombre: item['Nombre'],
            area: item['Area'],
            movimientos: item['Movimientos'],
            unidades: [],
            entradas: [],
            salidas: [],
            perdidas: [],
            razones: [],
            cantidades: [],
            horasModificacion: [],
            usuarioModificacion: [],
            mensaje: '',
          );
        }
      }
    } on TimeoutException catch (e) {
      historial = HistorialModel(
        id: 0,
        fecha: '',
        nombre: '',
        area: '',
        movimientos: 0,
        unidades: [],
        entradas: [],
        salidas: [],
        perdidas: [],
        razones: [],
        cantidades: [],
        horasModificacion: [],
        usuarioModificacion: [],
        mensaje: '${e.message}',
      );
    } on SocketException catch (e) {
      historial = HistorialModel(
        id: 0,
        fecha: '',
        nombre: '',
        area: '',
        movimientos: 0,
        unidades: [],
        entradas: [],
        salidas: [],
        perdidas: [],
        razones: [],
        cantidades: [],
        horasModificacion: [],
        usuarioModificacion: [],
        mensaje: e.message,
      );
    } on http.ClientException catch (e) {
      historial = HistorialModel(
        id: 0,
        fecha: '',
        nombre: '',
        area: '',
        movimientos: 0,
        unidades: [],
        entradas: [],
        salidas: [],
        perdidas: [],
        razones: [],
        cantidades: [],
        horasModificacion: [],
        usuarioModificacion: [],
        mensaje: e.message,
      );
    } on Error catch (e) {
      historial = HistorialModel(
        id: 0,
        fecha: '',
        nombre: '',
        area: '',
        movimientos: 0,
        unidades: [],
        entradas: [],
        salidas: [],
        perdidas: [],
        razones: [],
        cantidades: [],
        horasModificacion: [],
        usuarioModificacion: [],
        mensaje: '$e',
      );
    }
    return historial;
  }

  static Future<List<HistorialModel>> getHistorialInfo(
    int id,
    String fecha,
  ) async {
    String conexion = LocalStorage.local('conexion');
    String locacion = LocalStorage.local('locación');
    List<HistorialModel> historial;
    try {
      var res = await http.get(
        Uri.parse('$conexion/historial/Historial/$locacion/$id/$fecha'),
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
      );
      historial = [
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: res.body,
        ),
      ];
      if (res.statusCode == 200) {
        final datos = json.decode(res.body);
        for (var item in datos) {
          List<double> doublelist = [];
          List<double> unidadeslist = [];
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
            String uni = '${item['Unidades'][i]}';
            String ent = '${item['Salidas'][i]}';
            String sal = '${item['Entradas'][i]}';
            if (uni.split('.').length < 2) {
              uni = '$uni.0';
            }
            if (ent.split('.').length < 2) {
              ent = '$ent.0';
            }
            if (sal.split('.').length < 2) {
              sal = '$sal.0';
            }
            unidadeslist.add(double.parse(uni));
            entradaslist.add(double.parse(ent));
            salidaslist.add(double.parse(sal));
          }
          historial = [
            HistorialModel(
              id: 0,
              fecha: '',
              nombre: '',
              area: '',
              movimientos: item['Movimientos'],
              unidades: unidadeslist,
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
          ];
        }
      }
    } on TimeoutException catch (e) {
      historial = [
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: '${e.message}',
        ),
      ];
    } on SocketException catch (e) {
      historial = [
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: e.message,
        ),
      ];
    } on http.ClientException catch (e) {
      historial = [
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: e.message,
        ),
      ];
    } on Error catch (e) {
      historial = [
        HistorialModel(
          id: 0,
          fecha: '',
          nombre: '',
          area: '',
          movimientos: 0,
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: '$e',
        ),
      ];
    }
    return historial;
  }
}
