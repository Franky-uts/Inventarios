import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inventarios/services/local_storage.dart';

class HistorialModel {
  String id;
  String fecha;
  String nombre;
  String area;
  List<double> unidades;
  List<int> entradas;
  List<int> salidas;
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

  static Future<List<HistorialModel>> getHistorial(String fecha, String filtro) async {
    String conexion = LocalStorage.local('conexion');
    String locacion = LocalStorage.local('locación').substring(0, 3);
    List<HistorialModel> historialFuture = [];
    if (locacion.isEmpty || locacion == "null") {
      historialFuture.add(
        HistorialModel(
          id: '',
          fecha: '',
          nombre: '',
          area: '',
          unidades: [],
          entradas: [],
          salidas: [],
          perdidas: [],
          razones: [],
          cantidades: [],
          horasModificacion: [],
          usuarioModificacion: [],
          mensaje: "No hay locación establecida",
        ),
      );
    } else {
      try {
        var res = await http.get(
          Uri.parse("$conexion/historial/$locacion/$filtro/$fecha"),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
          },
        );
        if (res.statusCode == 200) {
          final datos = json.decode(res.body);
          for (var item in datos) {
            List<double> doublelist = [];
            List<double> unidadeslist = [];
            for (int i = 0; i < item["PerdidaCantidad"].length; i++) {
              String dob = "${item["PerdidaCantidad"][i]}.0";
              if (dob.split(".").length > 2) {
                dob = "${dob.split(".")[0]}.${dob.split(".")[1]}";
              }
              doublelist.add(double.parse(dob));
            }
            for (int i = 0; i < item["Unidades"].length; i++) {
              String dob = "${item["Unidades"][i]}.0";
              if (dob.split(".").length > 2) {
                dob = "${dob.split(".")[0]}.${dob.split(".")[1]}";
              }
              unidadeslist.add(double.parse(dob));
            }
            historialFuture.add(
              HistorialModel(
                id: item["id"].split(" ")[0],
                fecha: item["Fecha"],
                nombre: item["Nombre"],
                area: item["Area"],
                unidades: unidadeslist,
                entradas: List<int>.from(item["Entradas"]),
                salidas: List<int>.from(item["Salidas"]),
                perdidas: List<int>.from(item["Perdidas"]),
                razones: List<String>.from(item["PerdidaRazon"]),
                cantidades: doublelist,
                horasModificacion: List<String>.from(item["ModificacionHoras"]),
                usuarioModificacion: List<String>.from(
                  item["ModificacionUsuario"],
                ),
                mensaje: "",
              ),
            );
          }
        } else {
          historialFuture.add(
            HistorialModel(
              id: '',
              fecha: '',
              nombre: '',
              area: '',
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
            id: '',
            fecha: '',
            nombre: '',
            area: '',
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
      } on SocketException catch (e) {
        historialFuture.add(
          HistorialModel(
            id: '',
            fecha: '',
            nombre: '',
            area: '',
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
            id: '',
            fecha: '',
            nombre: '',
            area: '',
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
      } on Error catch (e) {
        historialFuture.add(
          HistorialModel(
            id: '',
            fecha: '',
            nombre: '',
            area: '',
            unidades: [],
            entradas: [],
            salidas: [],
            perdidas: [],
            razones: [],
            cantidades: [],
            horasModificacion: [],
            usuarioModificacion: [],
            mensaje: e.toString(),
          ),
        );
      }
    }
    return historialFuture;
  }
}
