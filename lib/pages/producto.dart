import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/pages/inventario.dart';

class Producto extends StatefulWidget {
  final ProductoModel productoInfo;
  final UsuarioModel usuario;
  final String busqueda;

  //final String url;

  const Producto({
    super.key,
    required this.productoInfo,
    required this.usuario,
    required this.busqueda,
  });

  @override
  State<Producto> createState() => _ProductoState();
}

class _ProductoState extends State<Producto> {
  late int cajasEntrantes = widget.productoInfo.entrada,
      cajasSalida = widget.productoInfo.salida,
      productosPerdido = widget.productoInfo.perdida;

  late bool carga;
  Timer? timer;
  late int colorCampo1, colorCampo2, colorCampo3;

  @override
  void initState() {
    colorCampo1 = 0xFF000000;
    colorCampo2 = 0xFF000000;
    colorCampo3 = 0xFF000000;
    carga = false;
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    colorCampo1;
    colorCampo2;
    colorCampo3;
    carga;
    super.dispose();
  }

  Future guardarDatos(String columna, int dato) async {
    final res = await http.put(
      Uri.parse(
        "http://192.168.1.130:4000/inventario/${widget.usuario.locacion}/${widget.productoInfo.id}/$columna",
      ),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
      },
      body: jsonEncode({'dato': dato, 'usuario': widget.usuario.nombre}),
    );
    if (res.statusCode == 200) {
      //print("cambio");
      return res;
    } else {
      //print("fallo");
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
            colorCampo1 = 0xFF000000;
            widget.productoInfo.unidades = unidades;
            widget.productoInfo.entrada = cajasEntrantes;
          });
          toast("Entradas guardadas");
          //ProductoModel.getProductos(widget.url);
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
            colorCampo2 = 0xFF000000;
            widget.productoInfo.unidades = unidades;
            widget.productoInfo.salida = cajasSalida;
          });
          //ProductoModel.getProductos(widget.url);
          toast("Salidas guardadas");
        } else {
          toast("No hay cambios");
        }
        break;
      case 3:
        if (productosPerdido > widget.productoInfo.perdida) {
          await guardarDatos("Perdida", productosPerdido);
          setState(() {
            colorCampo3 = 0xFF000000;
            widget.productoInfo.perdida = productosPerdido;
          });
          toast("Perdidas guardadas");
          //ProductoModel.getProductos(widget.url);
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
      backgroundColor: Colors.grey,
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
              colorCampo1 = 0xFF00be00;
            } else {
              colorCampo1 = 0xFF000000;
            }
          });
        } else {
          if (cajasEntrantes + valor >= 0) {
            setState(() {
              colorCampo1 = 0xFFFF0000;
            });
          } else {
            setState(() {
              colorCampo1 = 0xFFFF0000;
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
                  colorCampo2 = 0xFF00be00;
                } else {
                  colorCampo2 = 0xFF000000;
                }
              });
            } else {
              setState(() {
                colorCampo2 = 0xFFFF0000;
              });
            }
          } else {
            setState(() {
              colorCampo2 = 0xFFFF0000;
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
              colorCampo3 = 0xFF00be00;
            } else {
              colorCampo3 = 0xFF000000;
            }
          });
        } else {
          if (productosPerdido + valor >= 0) {
            setState(() {
              colorCampo3 = 0xFFFF0000;
            });
          } else {
            setState(() {
              colorCampo3 = 0xFFFF0000;
            });
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (carga == false) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Inventario(
                  usuario: widget.usuario,
                  busqueda: widget.busqueda,
                ),
              ),
            );
          }
        },
        elevation: 0,
        backgroundColor: Colors.grey,
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
                    style: TextStyle(color: Colors.black, fontSize: 30),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .5,
                    height: 45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Unidades:", style: TextStyle(fontSize: 20)),
                        Container(
                          width: MediaQuery.of(context).size.width * .275,
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2.5,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            widget.productoInfo.unidades.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  contenedorInfo(
                    "Cajas que entraron:",
                    cajasEntrantes,
                    1,
                    colorCampo1,
                  ),
                  contenedorInfo(
                    "Cajas que salieron:",
                    cajasSalida,
                    2,
                    colorCampo2,
                  ),
                  contenedorInfo(
                    "Productos perdidos:",
                    productosPerdido,
                    3,
                    colorCampo3,
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
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              widget.productoInfo.ultimaModificacion,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
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
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              widget.productoInfo.ultimoUsuario,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
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
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
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
          Text(textoInfo, style: TextStyle(fontSize: 20)),
          Container(
            width: MediaQuery.of(context).size.width * .25,
            height: 1,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
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
              backgroundColor: Colors.black,
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
              backgroundColor: Colors.black,
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
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
