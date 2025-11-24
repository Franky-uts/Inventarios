import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/inventario.dart';

import '../services/local_storage.dart';

class Producto extends StatefulWidget {
  final ProductoModel productoInfo;

  const Producto({super.key, required this.productoInfo});

  @override
  State<Producto> createState() => _ProductoState();
}

class _ProductoState extends State<Producto> {
  late int cajasEntrantes = widget.productoInfo.entrada,
      cajasSalida = widget.productoInfo.salida,
      productosPerdido = widget.productoInfo.perdida;
  late bool carga;
  Timer? timer;
  final List<int> color = [0xFF8F01AF, 0xFF8F01AF, 0xFF8F01AF];

  @override
  void initState() {
    carga = false;
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    color.clear();
    super.dispose();
  }

  String local(String clave) {
    String res = LocalStorage.preferencias.getString(clave).toString();
    return res;
  }

  Future guardarDatos(String columna, int dato) async {
    final res = await http.put(
      Uri.parse(
        "${local('conexion')}/inventario/${local('locación')}/${widget.productoInfo.id}/$columna",
      ),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
      },
      body: jsonEncode({'dato': dato, 'usuario': local('usuario')}),
    );
    if (res.statusCode == 200) {
      return res;
    } else {
      throw Exception(res.reasonPhrase);
    }
  }

  Future enviarDatos(int valor) async {
    switch (valor) {
      case 1:
        if (cajasEntrantes > widget.productoInfo.entrada) {
          final int unidades =
              (cajasEntrantes - widget.productoInfo.entrada) +
              widget.productoInfo.unidades;
          await guardarDatos("Unidades", unidades);
          await guardarDatos("Entrada", cajasEntrantes);
          setState(() {
            color[0] = 0xFF8F01AF;
            widget.productoInfo.unidades = unidades;
            widget.productoInfo.entrada = cajasEntrantes;
          });
          toast("Entradas guardadas");
        } else {
          toast("No hay cambios");
        }
        break;
      case 2:
        if (cajasSalida > widget.productoInfo.salida) {
          final int unidades =
              widget.productoInfo.unidades -
              (cajasSalida - widget.productoInfo.salida);
          await guardarDatos("Unidades", unidades);
          await guardarDatos("Salida", cajasSalida);
          setState(() {
            color[1] = 0xFF8F01AF;
            widget.productoInfo.unidades = unidades;
            widget.productoInfo.salida = cajasSalida;
          });
          toast("Salidas guardadas");
        } else {
          toast("No hay cambios");
        }
        break;
      case 3:
        if (productosPerdido > widget.productoInfo.perdida) {
          await guardarDatos("Perdida", productosPerdido);
          setState(() {
            color[2] = 0xFF8F01AF;
            widget.productoInfo.perdida = productosPerdido;
          });
          toast("Perdidas guardadas");
        } else {
          toast("No hay cambios");
        }
        break;
    }
    setState(() {
      carga = false;
    });
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

  void cambioValor(int tipo, int valor) {
    switch (tipo) {
      case 1:
        if ((cajasEntrantes + valor) >= widget.productoInfo.entrada) {
          setState(() {
            cajasEntrantes += valor;
            if (cajasEntrantes != widget.productoInfo.entrada) {
              color[0] = 0xFF00be00;
            } else {
              color[0] = 0xFF8F01AF;
            }
          });
        } else {
          if (cajasEntrantes + valor >= 0) {
            setState(() {
              color[0] = 0xFFFF0000;
            });
          } else {
            setState(() {
              color[0] = 0xFFFF0000;
            });
          }
        }
        break;
      case 2:
        if ((cajasSalida + valor - widget.productoInfo.salida) <=
            widget.productoInfo.unidades) {
          if ((cajasSalida + valor) >= 0) {
            if ((cajasSalida + valor) >= widget.productoInfo.salida) {
              setState(() {
                cajasSalida += valor;
                if (cajasSalida != widget.productoInfo.salida) {
                  color[1] = 0xFF00be00;
                } else {
                  color[1] = 0xFF8F01AF;
                }
              });
            } else {
              setState(() {
                color[1] = 0xFFFF0000;
              });
            }
          } else {
            setState(() {
              color[1] = 0xFFFF0000;
            });
          }
        } else {
          toast("Ya son todos los productos.");
        }
        break;
      case 3:
        if ((productosPerdido + valor) >= widget.productoInfo.perdida) {
          setState(() {
            productosPerdido += valor;
            if (productosPerdido != widget.productoInfo.perdida) {
              color[2] = 0xFF00be00;
            } else {
              color[2] = 0xFF8F01AF;
            }
          });
        } else {
          if (productosPerdido + valor >= 0) {
            setState(() {
              color[2] = 0xFFFF0000;
            });
          } else {
            setState(() {
              color[2] = 0xFFFF0000;
            });
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (carga == false) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Inventario()),
            );
          }
        },
        elevation: 0,
        backgroundColor: Color(0xFF8F01AF),
        tooltip: "Volver.",
        child: Icon(Icons.arrow_back_rounded, color: Colors.white),
      ),
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    widget.productoInfo.nombre,
                    style: TextStyle(color: Color(0xFF8F01AF), fontSize: 30),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .5,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        tipoTexto(widget.productoInfo.tipo),
                        Container(
                          width: MediaQuery.of(context).size.width * .26,
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFFDC930)),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFF8F01AF),
                              width: 2.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2.5,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            widget.productoInfo.unidades.toString(),
                            style: TextStyle(
                              color: Color(0xFF8F01AF),
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  contenedorInfo(" que entraron:", cajasEntrantes, 1, color[0]),
                  contenedorInfo(" que salieron:", cajasSalida, 2, color[1]),
                  contenedorInfo(
                    "Productos perdidos:",
                    productosPerdido,
                    3,
                    color[2],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .35,
                        height: 35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Ultima modificación:",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFFF6AFCF),
                              ),
                            ),
                            Text(
                              widget.productoInfo.ultimaModificacion,
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFFF6AFCF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .35,
                        height: 35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Modificada por:",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFFF6AFCF),
                              ),
                            ),
                            Text(
                              widget.productoInfo.ultimoUsuario,
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFFF6AFCF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
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

  Widget tipoTexto(String tipo) {
    if (tipo == "Kilo" || tipo == "Costal") {
      return Column(
        children: [
          Text(
            "Unidades:",
            style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
          ),
          Text(
            "Kilos por unidad: ${widget.productoInfo.cantidadPorUnidad.toString()}",
            style: TextStyle(fontSize: 15, color: Color(0xFFF6AFCF)),
          ),
        ],
      );
    } else if (tipo == "Bote") {
      return Column(
        children: [
          Text(
            "Unidades:",
            style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
          ),
          Text(
            "Litros por unidad: ${widget.productoInfo.cantidadPorUnidad.toString()}",
            style: TextStyle(fontSize: 15, color: Color(0xFFF6AFCF)),
          ),
        ],
      );
    } else if (tipo == "Caja" || tipo == "Bulto" || tipo == "Paquete") {
      return Column(
        children: [
          Text(
            "${tipo}s:",
            style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
          ),
          Text(
            "Productos por $tipo: ${widget.productoInfo.cantidadPorUnidad.toString()}",
            style: TextStyle(fontSize: 15, color: Color(0xFFF6AFCF)),
          ),
        ],
      );
    } else if (tipo == "Galón") {
      return Text(
        "Galones:",
        style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
      );
    } else {
      return Text(
        "${tipo}s:",
        style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
      );
    }
  }

  Text textoTipoContenedorInfo(String textoInfo, String tipo) {
    if (textoInfo != "Productos perdidos:") {
      if (tipo == "Kilo") {
        return Text(
          "Unidades$textoInfo",
          style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
        );
      } else if (tipo == "Galón") {
        return Text(
          "Galones$textoInfo",
          style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
        );
      } else {
        return Text(
          "${tipo}s$textoInfo",
          style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
        );
      }
    } else {
      if (tipo == "Kilo" || tipo == "Costal") {
        return Text(
          "Kilos perdidos:",
          style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
        );
      } else if (tipo == "Bote") {
        return Text(
          "Litros perdidos:",
          style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
        );
      } else {
        return Text(
          textoInfo,
          style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
        );
      }
    }
  }

  SizedBox contenedorInfo(
    String textoInfo,
    int textoValor,
    int valor,
    int colorBorde,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .75,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          textoTipoContenedorInfo(textoInfo, widget.productoInfo.tipo),
          Container(
            width: MediaQuery.of(context).size.width * .25,
            height: 1,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFFDC930))),
            ),
          ),
          botones(textoValor, valor, colorBorde),
        ],
      ),
    );
  }

  Row botones(int textoValor, int tipo, int colorBorde) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onLongPress: () => setState(() {
            timer = Timer.periodic(Duration(milliseconds: 150), (timer) {
              cambioValor(tipo, -1);
            });
          }),
          onLongPressEnd: (_) => setState(() {
            timer?.cancel();
          }),
          child: IconButton(
            onPressed: () {
              cambioValor(tipo, -1);
            },
            icon: Icon(Icons.remove, color: Colors.white),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Color(0xFF8F01AF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Color(colorBorde), width: 2.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            textoValor.toString(),
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        GestureDetector(
          onLongPress: () => setState(() {
            timer = Timer.periodic(Duration(milliseconds: 150), (timer) {
              cambioValor(tipo, 1);
            });
          }),
          onLongPressEnd: (_) => setState(() {
            timer?.cancel();
          }),
          child: IconButton(
            onPressed: () {
              cambioValor(tipo, 1);
            },
            icon: Icon(Icons.add, color: Colors.white),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Color(0xFF8F01AF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              carga = true;
            });
            enviarDatos(tipo);
          },
          icon: Icon(Icons.save_rounded, color: Colors.white),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Color(0xFF8F01AF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
