import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:provider/provider.dart';

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
  Timer? timer;
  final List<int> color = [0xFF8A03A9, 0xFF8A03A9, 0xFF8A03A9];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    color.clear();
    super.dispose();
  }

  Future enviarDatos(int valor, BuildContext ctx) async {
    String texto = "";
    switch (valor) {
      case 1:
        if (cajasEntrantes > widget.productoInfo.entrada) {
          final int unidades =
              (cajasEntrantes - widget.productoInfo.entrada) +
              widget.productoInfo.unidades;
          texto = await ProductoModel.guardarDatos(
            "Entrada",
            unidades,
            cajasEntrantes,
            widget.productoInfo.id,
          );
          if (texto.split(": ")[0] != "Error") {
            setState(() {
              color[0] = 0xFF8A03A9;
              widget.productoInfo.unidades = unidades;
              widget.productoInfo.entrada = cajasEntrantes;
            });
            texto = "Entradas registradas";
          }
        } else {
          texto = "No hay cambios";
        }
        break;
      case 2:
        if (cajasSalida > widget.productoInfo.salida) {
          final int unidades =
              widget.productoInfo.unidades -
              (cajasSalida - widget.productoInfo.salida);
          texto = await ProductoModel.guardarDatos(
            "Salida",
            unidades,
            cajasSalida,
            widget.productoInfo.id,
          );
          if (texto.split(": ")[0] != "Error") {
            setState(() {
              color[1] = 0xFF8A03A9;
              widget.productoInfo.unidades = unidades;
              widget.productoInfo.salida = cajasSalida;
            });
            texto = "Salidas registradas";
          }
        } else {
          texto = "No hay cambios";
        }
        break;
      case 3:
        if (productosPerdido > widget.productoInfo.perdida) {
          texto = await ProductoModel.guardarDatos(
            "Perdida",
            widget.productoInfo.unidades,
            productosPerdido,
            widget.productoInfo.id,
          );
          if (texto.split(": ")[0] != "Error") {
            setState(() {
              color[2] = 0xFF8A03A9;
              widget.productoInfo.perdida = productosPerdido;
            });
            texto = "Perdidas registradas";
          }
        } else {
          texto = "No hay cambios";
        }
        break;
    }
    Textos.toast(texto, false);
    if (ctx.mounted) {
      ctx.read<Carga>().cargaBool(false);
    }
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
              color[0] = 0xFF8A03A9;
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
                  color[1] = 0xFF8A03A9;
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
          Textos.toast("Ya son todos los productos.", false);
        }
        break;
      case 3:
        if ((productosPerdido + valor) >= widget.productoInfo.perdida) {
          setState(() {
            productosPerdido += valor;
            if (productosPerdido != widget.productoInfo.perdida) {
              color[2] = 0xFF00be00;
            } else {
              color[2] = 0xFF8A03A9;
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
                  Textos.textoTilulo(widget.productoInfo.nombre, 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .525,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        tipoTexto(widget.productoInfo.tipo),
                        Container(
                          width: MediaQuery.of(context).size.width * .23,
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFFDC930)),
                            ),
                          ),
                        ),
                        Textos.recuadroCantidad(
                          widget.productoInfo.unidades.toString(),
                          Color(0xFF8A03A9),
                          20,
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
                            Textos.textoGeneral(
                              "Ultima modificación:",
                              15,
                              false,
                              false,
                            ),
                            Textos.textoGeneral(
                              widget.productoInfo.ultimaModificacion,
                              15,
                              false,
                              false,
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
                            Textos.textoGeneral(
                              "Modificada por:",
                              15,
                              false,
                              false,
                            ),
                            Textos.textoGeneral(
                              widget.productoInfo.ultimoUsuario,
                              15,
                              false,
                              false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Botones.btnRctMor(
                "Volver",
                35,
                Icons.arrow_back_rounded,
                false,
                () => {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Inventario()),
                  ),
                },
              ),
            ),
            Consumer<Carga>(
              builder: (context, carga, child) {
                return Carga.ventanaCarga();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget tipoTexto(String tipo) {
    if (tipo == "Granel" || tipo == "Costal") {
      return Column(
        children: [
          Textos.textoGeneral("Unidades:", 20, true, false),
          Textos.textoGeneral(
            "Kilos por unidad: ${widget.productoInfo.cantidadPorUnidad.toString()}",
            15,
            false,
            true,
          ),
        ],
      );
    } else if (tipo == "Bote") {
      return Column(
        children: [
          Textos.textoGeneral("Unidades:", 20, true, false),
          Textos.textoGeneral(
            "Kilos/Piezas por unidad: ${widget.productoInfo.cantidadPorUnidad.toString()}",
            15,
            false,
            true,
          ),
        ],
      );
    } else if (tipo == "Caja" || tipo == "Bulto" || tipo == "Paquete") {
      return Column(
        children: [
          Textos.textoGeneral("${tipo}s:", 20, true, false),
          Textos.textoGeneral(
            "Productos por $tipo: ${widget.productoInfo.cantidadPorUnidad.toString()}",
            15,
            false,
            true,
          ),
        ],
      );
    } else if (tipo == "Galón") {
      return Textos.textoGeneral("Galones:", 20, true, false);
    } else {
      return Textos.textoGeneral("${tipo}s:", 20, true, false);
    }
  }

  Text textoTipoContenedorInfo(String textoInfo, String tipo) {
    if (textoInfo != "Productos perdidos:") {
      if (tipo == "Granel") {
        return Textos.textoGeneral("Unidades$textoInfo", 20, true, false);
      } else if (tipo == "Galón") {
        return Textos.textoGeneral("Galones$textoInfo", 20, true, false);
      } else {
        return Textos.textoGeneral("${tipo}s$textoInfo", 20, true, false);
      }
    } else {
      if (tipo == "Granel" || tipo == "Costal") {
        return Textos.textoGeneral("Kilos perdidos:", 20, true, false);
      } else if (tipo == "Bote") {
        return Textos.textoGeneral("Kilos/Piezas perdidos:", 20, true, false);
      } else {
        return Textos.textoGeneral(textoInfo, 20, true, false);
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
          child: Botones.btnRctMor(
            "",
            0,
            Icons.remove,
            false,
            () => cambioValor(tipo, -1),
          ),
        ),
        Textos.recuadroCantidad(textoValor.toString(), Color(colorBorde), 20),
        GestureDetector(
          onLongPress: () => setState(() {
            timer = Timer.periodic(Duration(milliseconds: 150), (timer) {
              cambioValor(tipo, 1);
            });
          }),
          onLongPressEnd: (_) => setState(() {
            timer?.cancel();
          }),
          child: Botones.btnRctMor(
            "",
            0,
            Icons.add,
            false,
            () => cambioValor(tipo, 1),
          ),
        ),
        Botones.btnRctMor(
          "Guardar datos",
          0,
          Icons.save_rounded,
          false,
          () => {
            context.read<Carga>().cargaBool(true),
            enviarDatos(tipo, context),
          },
        ),
      ],
    );
  }
}
