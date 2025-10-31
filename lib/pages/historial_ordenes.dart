import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:inventarios/models/orden_model.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/orden_salida.dart';
import '../services/local_storage.dart';

class HistorialOrdenes extends StatefulWidget {
  final List<ProductoModel> productosPorId;

  const HistorialOrdenes({super.key, required this.productosPorId});

  @override
  State<HistorialOrdenes> createState() => _HistorialOrdenesState();
}

class _HistorialOrdenesState extends State<HistorialOrdenes> {
  static List<OrdenModel> ordenes = [];
  final List<int> colores = [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF];
  late List artVen = [];
  late List canVen = [];
  late bool valido;
  late bool carga;
  late bool ventanaDatos;
  late bool ventanaConf;
  late String filtro;
  late String idVen = "";
  late String remVen = "";
  late String estVen = "";
  late String modVen = "";
  late String desVen = "";

  @override
  void initState() {
    valido = false;
    ventanaDatos = false;
    ventanaConf = false;
    carga = false;
    filtro = "id";
    colores[0] = 0xFF000000;
    colores[1] = 0xFFFFFFFF;
    colores[2] = 0xFFFFFFFF;
    super.initState();
  }

  @override
  void dispose() {
    ordenes.clear();
    colores.clear();
    artVen.clear();
    canVen.clear();
    valido;
    carga;
    ventanaDatos;
    ventanaConf;
    filtro;
    idVen;
    remVen;
    estVen;
    modVen;
    super.dispose();
  }

  Future editarEstado(String columna, String dato) async {
    String respuesta;
    try {
      final res = await http.put(
        Uri.parse("http://192.168.1.130:4000/ordenes/$idVen/$columna"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({
          'dato': dato,
          'usuario': LocalStorage.preferencias.getString('usuario').toString(),
        }),
      );
      if (res.statusCode == 200) {
        respuesta = "Se cancelo la orden.";
      } else {
        respuesta = res.reasonPhrase.toString();
      }
    } on TimeoutException catch (e) {
      respuesta = e.message.toString();
    } on SocketException catch (e) {
      respuesta = e.message.toString();
    } on Error catch (e) {
      respuesta = e.toString();
    }
    return respuesta;
  }

  void toast(String texto) {
    Fluttertoast.showToast(
      msg: texto,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 15,
    );
  }

  String url() {
    return "http://192.168.1.130:4000/ordenes/$filtro";
  }

  void filtroTexto(int valor) {
    setState(() {
      colores[1] = 0xFFFFFFFF;
      colores[0] = 0xFFFFFFFF;
      colores[2] = 0xFFFFFFFF;
    });
    switch (valor) {
      case (1):
        setState(() {
          filtro = "id";
          colores[0] = 0xFF000000;
        });
        break;
      case (2):
        setState(() {
          filtro = "Estado";
          colores[1] = 0xFF000000;
        });
        break;
      case (3):
        setState(() {
          filtro = "Remitente";
          colores[2] = 0xFF000000;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  opciones(context),
                  contenedorInfo(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 82,
                    child: listaFutura(),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: ventanaDatos,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 30),
                decoration: BoxDecoration(color: Colors.black38),
                child: Center(child: contenidoVentana()),
              ),
            ),
            Visibility(
              visible: ventanaConf,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 30),
                decoration: BoxDecoration(color: Colors.black38),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadiusGeometry.circular(25),
                      border: BoxBorder.all(color: Colors.black54),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 5,
                      children: [
                        Text(
                          "¿Segur@ que quieres cancelar la orden?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: 15,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  ventanaConf = false;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.black, width: 1),
                              ),
                              child: Text(
                                "No, volver",
                                style: TextStyle(
                                  fontSize: 17.5,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                setState(() {
                                  carga = true;
                                  ventanaConf = false;
                                });
                                String res = await editarEstado(
                                  "Estado",
                                  "Cancelado",
                                );
                                toast(res);
                                setState(() {
                                  ventanaDatos = false;
                                  carga = false;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.black, width: 1),
                              ),
                              child: Text(
                                "Si, cancelalo",
                                style: TextStyle(
                                  fontSize: 17.5,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: carga,
              child: Container(
                decoration: BoxDecoration(color: Colors.black45),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget opciones(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton.filled(
            onPressed: () {
              setState(() {
                carga = true;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrdenSalida(productosPorId: widget.productosPorId),
                ),
              );
            },
            tooltip: "Regresar",
            icon: Icon(Icons.arrow_back_rounded, size: 35),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              filtroTexto(1);
            },
            label: Text("ID", style: TextStyle(color: Colors.black)),
            icon: Icon(Icons.numbers_rounded, size: 25, color: Colors.black),
            style: IconButton.styleFrom(
              side: BorderSide(color: Color(colores[0]), width: 2),
              backgroundColor: Colors.white,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(27.5),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              filtroTexto(2);
            },
            label: Text("Estado", style: TextStyle(color: Colors.black)),
            icon: Icon(
              Icons.query_builder_rounded,
              size: 25,
              color: Colors.black,
            ),
            style: IconButton.styleFrom(
              side: BorderSide(color: Color(colores[1]), width: 2),
              backgroundColor: Colors.white,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(27.5),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              filtroTexto(3);
            },
            label: Text("Remitente", style: TextStyle(color: Colors.black)),
            icon: Icon(
              Icons.perm_identity_outlined,
              size: 25,
              color: Colors.black,
            ),
            style: IconButton.styleFrom(
              side: BorderSide(color: Color(colores[2]), width: 2),
              backgroundColor: Colors.white,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(27.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  FutureBuilder listaFutura() {
    return FutureBuilder(
      future: OrdenModel.getOrdenes(url()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            valido = true;
            ordenes = snapshot.data;
            if (ordenes.isNotEmpty) {
              if (ordenes[0].estado == "Error") {
                return Center(child: Text(ordenes[0].remitente));
              } else {
                return listaPrincipal(ordenes);
              }
            } else {
              return Center(
                child: Text("Todo está en orden, no hay órdenes en salida."),
              );
            }
          } else if (snapshot.hasError) {
            valido = false;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Error:"), Text(snapshot.error.toString())],
              ),
            );
          } else {
            return Center(child: Text("No se recuperaron órdenes."));
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  ListView listaPrincipal(List lista) {
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) =>
          Container(height: 2, decoration: BoxDecoration(color: Colors.grey)),
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: 40,
          decoration: BoxDecoration(color: Colors.white54),
          child: TextButton(
            onPressed: () => {
              setState(() {
                idVen = lista[index].id.toString();
                remVen = lista[index].remitente;
                estVen = lista[index].estado;
                modVen = lista[index].ultimaModificacion;
                desVen = lista[index].destino;
                artVen = lista[index].articulos;
                canVen = lista[index].cantidades;
                ventanaDatos = true;
              }),
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(0),
              shape: ContinuousRectangleBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _barraDato(
                  .05,
                  lista[index].id.toString(),
                  TextAlign.center,
                  20,
                ),
                _divider(),
                _barraDato(
                  .2,
                  lista[index].articulos.length.toString(),
                  TextAlign.center,
                  20,
                ),
                _divider(),
                _barraDato(.2, lista[index].estado, TextAlign.center, 20),
                _divider(),
                _barraDato(.3, lista[index].remitente, TextAlign.center, 20),
                _divider(),
                _barraDato(
                  .25,
                  lista[index].ultimaModificacion,
                  TextAlign.center,
                  20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Container contenedorInfo() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(color: Colors.grey),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _barraSuperior(.05, "id"),
          _divider(),
          _barraSuperior(.2, "Art. ordenados"),
          _divider(),
          _barraSuperior(.2, "Estado"),
          _divider(),
          _barraSuperior(.3, "Remitente"),
          _divider(),
          _barraSuperior(.25, "Última modificación"),
        ],
      ),
    );
  }

  SizedBox _barraSuperior(double grosor, String texto) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * grosor,
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  Widget _barraDato(
    double grosor,
    String texto,
    TextAlign alineamiento,
    double tamanoFuente,
  ) => Container(
    width: MediaQuery.sizeOf(context).width * grosor,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      texto,
      textAlign: alineamiento,
      maxLines: 1,
      style: TextStyle(color: Colors.black, fontSize: tamanoFuente),
    ),
  );

  VerticalDivider _divider() {
    return VerticalDivider(
      thickness: 1,
      width: 0,
      color: Colors.grey,
      indent: 5,
      endIndent: 5,
    );
  }

  Container contenidoVentana() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadiusGeometry.circular(25),
        border: BoxBorder.all(color: Colors.black54),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 0,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Id de la orden: $idVen",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                "Estado: $estVen",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Container(
            width: MediaQuery.sizeOf(context).width,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: Colors.grey),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _barraSuperior(.5, "Nombre del articulo"),
                _divider(),
                _barraSuperior(.28, "Cantidad ordenada"),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 195,
            margin: EdgeInsets.zero,
            child: ListView.separated(
              itemCount: artVen.length,
              scrollDirection: Axis.vertical,
              separatorBuilder: (context, index) => Container(
                height: 2,
                decoration: BoxDecoration(color: Colors.grey),
              ),
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white54),
                  child: Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _barraDato(.5, artVen[index], TextAlign.center, 20),
                        _divider(),
                        _barraDato(
                          .28,
                          canVen[index].toString(),
                          TextAlign.center,
                          20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Destino: $desVen",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  Text(
                    "Remitente: $remVen",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  Text(
                    "Última modificación: $modVen",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
              Row(
                spacing: 15,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        ventanaDatos = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      "Cerrar",
                      style: TextStyle(fontSize: 17.5, color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (estVen == "En proceso") {
                        setState(() {
                          ventanaConf = true;
                        });
                      } else if (estVen == "Cancelado" ||
                          estVen == "Denegado") {
                        toast("La orden ya esta cencelada.");
                      } else {
                        toast("La orden no se puede cancelar.");
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      "Cancelar",
                      style: TextStyle(fontSize: 17.5, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
