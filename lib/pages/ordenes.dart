import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'inicio.dart';
import 'package:flutter/material.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/toast_text.dart';
import 'package:inventarios/components/botones.dart';
import 'package:http/http.dart' as http;
import '../models/orden_model.dart';
import '../services/local_storage.dart';

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

  Future editarEstado(String columna, String dato) async {
    String respuesta;
    if (dato == "finalizar") {
      dato = "Finalizado";
    } else if (dato == "denegar") {
      dato = "Denegado";
    }
    try {
      final res = await http.put(
        Uri.parse("${LocalStorage.local('conexion')}/ordenes/$idVen/$columna"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({'dato': dato}),
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
      ToastText.toast("La orden ya esta cencelada.", false);
    } else {
      ToastText.toast("La orden esta finalizada.", false);
    }
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

  Color colorEstado(String estado) {
    late Color color;
    switch (estado) {
      case ('En proceso'):
        color = Colors.blue.shade200;
        break;
      case ('Finalizado'):
        color = Colors.green.shade200;
        break;
      case ('Cancelado'):
        color = Colors.red.shade200;
        break;
      case ('Denegado'):
        color = Colors.red.shade300;
        break;
    }
    return color;
  }

  Future<void> logout(BuildContext ctx) async {
    setState(() {
      carga = true;
    });
    await LocalStorage.eliminar('usuario');
    await LocalStorage.eliminar('usuario');
    await LocalStorage.eliminar('puesto');
    await LocalStorage.eliminar('locación');
    await LocalStorage.eliminar('busqueda');
    await LocalStorage.eliminar('conexion');
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
                  Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.05, 0.2, 0.2, 0.3, 0.25],
                    [
                      "id",
                      "Art. ordenados",
                      "Estado",
                      "Remitente",
                      "Última modificación",
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 82,
                    child: Tablas.listaFutura(
                      listaPrincipal,
                      "Todo está en orden, no hay órdenes entrantes.",
                      "No se recuperaron órdenes.",
                      () => OrdenModel.getAllOrdenes(filtro),
                    ),
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
                                ToastText.toast(res, false);
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
            Carga.ventanaCarga(carga),
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
          Botones.btnRctMor(
            "Cerrar sesión",
            Icon(Icons.logout_rounded, size: 35),
            accion: () => {logout(context)},
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

  ListView listaPrincipal(List lista) {
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        return Tablas.barraDatos(
          MediaQuery.sizeOf(context).width,
          [.05, .2, .2, .3, .25],
          [
            lista[index].id.toString(),
            lista[index].articulos.length.toString(),
            lista[index].estado,
            lista[index].remitente,
            lista[index].ultimaModificacion,
          ],
          [
            Colors.transparent,
            Colors.transparent,
            colorEstado(lista[index].estado),
            Colors.transparent,
            Colors.transparent,
          ],
          true,
          () => {
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
        );
      },
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
          Tablas.contenedorInfo(
            MediaQuery.sizeOf(context).width,
            [.5, 0.28],
            ["Nombre del articulo", "Cantidad ordenada"],
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
                return Tablas.barraDatos(
                  MediaQuery.sizeOf(context).width,
                  [.5, .28],
                  [artVen[index], canVen[index].toString()],
                  [],
                  false,
                  null,
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
