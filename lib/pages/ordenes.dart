import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../models/orden_model.dart';
import '../services/local_storage.dart';
import 'inicio.dart';

class Ordenes extends StatefulWidget {
  const Ordenes({super.key});

  @override
  State<Ordenes> createState() => _OrdenesState();
}

class _OrdenesState extends State<Ordenes> {
  static List<OrdenModel> ordenes = [];
  final List<int> colores = [0xFF8F01AF, 0xFFFFFFFF, 0xFFFFFFFF];
  late List artVen = [];
  late List canVen = [];
  late bool valido;
  late bool carga;
  late bool ventanaDatos;
  late bool ventanaConf;
  late String filtro;
  late String accion;
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
    accion = "";
    super.initState();
  }

  @override
  void dispose() {
    ordenes.clear();
    colores.clear();
    artVen.clear();
    canVen.clear();
    super.dispose();
  }

  String local(String clave) {
    String res = LocalStorage.preferencias.getString(clave).toString();
    return res;
  }

  Future editarEstado(String columna, String dato) async {
    String respuesta;
    if (dato == "finalizar") {
      dato = "Finalizado";
    } else if (dato == "denegar") {
      dato = "Denegado";
    }
    try {
      final res = await http.put(
        Uri.parse("${local('conexion')}/ordenes/$idVen/$columna"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({'dato': dato, 'usuario': local('usuario')}),
      );
      if (res.statusCode == 200) {
        respuesta = "Se modificó la orden.";
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

  void cambiarEstado(String accion) {
    if (estVen == "En proceso") {
      setState(() {
        ventanaConf = true;
        this.accion = accion;
      });
    } else if (estVen == "Cancelado" || estVen == "Denegado") {
      toast("La orden ya esta cencelada.");
    } else {
      toast("La orden esta finalizada.");
    }
  }

  void toast(String texto) {
    Fluttertoast.showToast(
      msg: texto,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color(0x80FDC930),
      textColor: Colors.white,
      fontSize: 15,
    );
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
          colores[0] = 0xFF8F01AF;
        });
        break;
      case (2):
        setState(() {
          filtro = "Estado";
          colores[1] = 0xFF8F01AF;
        });
        break;
      case (3):
        setState(() {
          filtro = "Remitente";
          colores[2] = 0xFF8F01AF;
        });
        break;
    }
  }

  Future<void> logout(BuildContext ctx) async {
    setState(() {
      carga = true;
    });
    Navigator.of(context).pop();
    await LocalStorage.preferencias.remove('usuario');
    await LocalStorage.preferencias.remove('puesto');
    await LocalStorage.preferencias.remove('locación');
    await LocalStorage.preferencias.remove('busqueda');
    await LocalStorage.preferencias.remove('conexion');
    if (ctx.mounted) {
      Navigator.pushReplacement(
        ctx,
        MaterialPageRoute(builder: (context) => Inicio()),
      );
    } else {
      setState(() {
        carga = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
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
                padding: EdgeInsets.symmetric(horizontal: 89, vertical: 30),
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
                      border: BoxBorder.all(
                        color: Color(0xFFFDC930),
                        width: 2.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 5,
                      children: [
                        Text(
                          "¿Segur@ que quieres $accion la orden?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8F01AF),
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
                                backgroundColor: Color(0xFF8F01AF),
                                side: BorderSide(
                                  color: Color(0xFFF6AFCF),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                "No, volver",
                                style: TextStyle(
                                  fontSize: 17.5,
                                  color: Colors.white,
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
                                  accion,
                                );
                                toast(res);
                                setState(() {
                                  ventanaDatos = false;
                                  carga = false;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color(0xFF8F01AF),
                                side: BorderSide(
                                  color: Color(0xFFF6AFCF),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                "Si, $accion",
                                style: TextStyle(
                                  fontSize: 17.5,
                                  color: Colors.white,
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
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFF6AFCF)),
                ),
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
              logout(context);
            },
            tooltip: "Cerrar sesión",
            icon: Icon(Icons.logout_rounded, size: 35),
            style: IconButton.styleFrom(
              backgroundColor: Color(0xFF8F01AF),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              filtroTexto(1);
            },
            label: Text("ID", style: TextStyle(color: Color(0xFF8F01AF))),
            icon: Icon(
              Icons.numbers_rounded,
              size: 25,
              color: Color(0xFF8F01AF),
            ),
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
            label: Text("Estado", style: TextStyle(color: Color(0xFF8F01AF))),
            icon: Icon(
              Icons.query_builder_rounded,
              size: 25,
              color: Color(0xFF8F01AF),
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
            label: Text(
              "Remitente",
              style: TextStyle(color: Color(0xFF8F01AF)),
            ),
            icon: Icon(
              Icons.perm_identity_outlined,
              size: 25,
              color: Color(0xFF8F01AF),
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
      future: OrdenModel.getOrdenes(filtro),
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
                child: Text("Todo está en orden, no hay órdenes entrantes."),
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
        return Center(
          child: CircularProgressIndicator(color: Color(0xFFF6AFCF)),
        );
      },
    );
  }

  ListView listaPrincipal(List lista) {
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: 40,
          decoration: BoxDecoration(color: Colors.white),
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
      decoration: BoxDecoration(color: Color(0xFF8F01AF)),
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
      style: TextStyle(color: Color(0xFF8F01AF), fontSize: tamanoFuente),
    ),
  );

  VerticalDivider _divider() {
    return VerticalDivider(
      thickness: 1,
      width: 0,
      color: Color(0xFFFDC930),
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
        border: BoxBorder.all(color: Color(0xFFFDC930), width: 2.5),
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
                style: TextStyle(
                  color: Color(0xFF8F01AF),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Estado: $estVen",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8F01AF),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            width: MediaQuery.sizeOf(context).width,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: Color(0xFF8F01AF)),
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
            height: MediaQuery.of(context).size.height - 198,
            margin: EdgeInsets.zero,
            child: ListView.separated(
              itemCount: artVen.length,
              scrollDirection: Axis.vertical,
              separatorBuilder: (context, index) => Container(
                height: 2,
                decoration: BoxDecoration(color: Color(0xFFFDC930)),
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
                    style: TextStyle(color: Color(0xFFF6AFCF), fontSize: 15),
                  ),
                  Text(
                    "Remitente: $remVen",
                    style: TextStyle(color: Color(0xFFF6AFCF), fontSize: 15),
                  ),
                  Text(
                    "Última modificación: $modVen",
                    style: TextStyle(color: Color(0xFFF6AFCF), fontSize: 15),
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
                      backgroundColor: Color(0xFF8F01AF),
                      side: BorderSide(color: Color(0xFFF6AFCF), width: 2),
                    ),
                    child: Text(
                      "Cerrar",
                      style: TextStyle(fontSize: 17.5, color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      cambiarEstado("denegar");
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xFF8F01AF),
                      side: BorderSide(color: Color(0xFFF6AFCF), width: 2),
                    ),
                    child: Text(
                      "Denegar",
                      style: TextStyle(fontSize: 17.5, color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      cambiarEstado("finalizar");
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xFF8F01AF),
                      side: BorderSide(color: Color(0xFFF6AFCF), width: 2),
                    ),
                    child: Text(
                      "Finalizar",
                      style: TextStyle(fontSize: 17.5, color: Colors.white),
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
