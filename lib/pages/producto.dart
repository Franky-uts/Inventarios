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
  final List<Color> color = [];

  @override
  void initState() {
    for (int i = 0; i < 3; i++) {
      color.add(Color(0xFF8A03A9));
    }
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    color.clear();
    super.dispose();
  }

  Future enviarDatos(int valor, BuildContext ctx) async {
    String texto = "No hay cambios";
    bool error = true;
    switch (valor) {
      case 0:
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
            widget.productoInfo.unidades = unidades;
            widget.productoInfo.entrada = cajasEntrantes;
            error = false;
            texto = "Entradas registradas";
          }
        }
        break;
      case 1:
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
            widget.productoInfo.unidades = unidades;
            widget.productoInfo.salida = cajasSalida;
            error = false;
            texto = "Salidas registradas";
          }
        }
        break;
      case 2:
        if (productosPerdido > widget.productoInfo.perdida) {
          texto = await ProductoModel.guardarDatos(
            "Perdida",
            widget.productoInfo.unidades,
            productosPerdido,
            widget.productoInfo.id,
          );
          if (texto.split(": ")[0] != "Error") {
            widget.productoInfo.perdida = productosPerdido;
            error = false;
            texto = "Perdidas registradas";
          }
        }
        break;
    }
    setState(() {
      if (error) {
        color[valor] = Color(0xFF8A03A9);
      }
    });
    Textos.toast(texto, false);
  }

  void cambioValor(int tipo, int valor) {
    int color = 0xFFFF0000;
    switch (tipo) {
      case 0:
        if ((cajasEntrantes + valor) >= widget.productoInfo.entrada) {
          color = 0xFF8A03A9;
          cajasEntrantes += valor;
        }
        if (cajasEntrantes != widget.productoInfo.entrada) {
          color = 0xFF00be00;
        }
        break;
      case 1:
        if ((cajasSalida + valor) >= widget.productoInfo.salida) {
          color = 0xFF8A03A9;
          if ((cajasSalida + valor - widget.productoInfo.salida) <=
              widget.productoInfo.unidades) {
            cajasSalida += valor;
          }
          if (cajasSalida != widget.productoInfo.salida) {
            color = 0xFF00be00;
          }
        }
        break;
      case 2:
        if ((productosPerdido + valor) >= widget.productoInfo.perdida) {
          productosPerdido += valor;
          color = 0xFF8A03A9;
        }
        if (productosPerdido != widget.productoInfo.perdida) {
          color = 0xFF00be00;
        }
        break;
    }
    setState(() {
      this.color[tipo] = Color(color);
    });
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
                  tipoTexto(widget.productoInfo.tipo),
                  contenedorInfo(" que entraron:", cajasEntrantes, 0),
                  contenedorInfo(" que salieron:", cajasSalida, 1),
                  contenedorInfo("Productos perdidos:", productosPerdido, 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      footer([
                        "Ultima modificación:",
                        widget.productoInfo.ultimaModificacion,
                      ]),
                      footer([
                        "Modificada por:",
                        widget.productoInfo.ultimoUsuario,
                      ]),
                    ],
                  ),
                ],
              ),
            ),
            Botones.layerButton(
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Inventario()),
              ),
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }

  SizedBox tipoTexto(String tipo) {
    String titulo = "${tipo}s:";
    String text = "";
    if (tipo == "Granel" || tipo == "Costal") {
      titulo = "Unidades:";
      text =
          "Kilos por unidad: ${widget.productoInfo.cantidadPorUnidad.toString()}";
    } else if (tipo == "Bote") {
      titulo = "Unidades:";
      text =
          "Kilos/Piezas por unidad: ${widget.productoInfo.cantidadPorUnidad.toString()}";
    } else if (tipo == "Caja" || tipo == "Bulto" || tipo == "Paquete") {
      text =
          "Productos por $tipo: ${widget.productoInfo.cantidadPorUnidad.toString()}";
    } else if (tipo == "Galón") {
      titulo = "Galones:";
    }
    List<Widget> wid = [Textos.textoGeneral(titulo, 20, true, true)];
    for (int i = 0; i < 2; i++) {
      if (text.isNotEmpty) {
        wid.add(Textos.textoGeneral(text, 15, false, true));
      }
      text = "Minimo requerido: ${widget.productoInfo.limiteProd.toString()}";
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * .325,
      height: 75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(children: wid),
          Textos.recuadroCantidad(
            widget.productoInfo.unidades.toString(),
            Textos.colorLimite(
              widget.productoInfo.limiteProd,
              widget.productoInfo.unidades,
            ),
            20,
          ),
        ],
      ),
    );
  }

  SizedBox contenedorInfo(String textoInfo, int textoValor, int valor) {
    String text = "${widget.productoInfo.tipo}s$textoInfo";
    if (widget.productoInfo.tipo == "Granel") {
      text = "Unidades$textoInfo";
    } else if (widget.productoInfo.tipo == "Galón") {
      text = "Galones$textoInfo";
    }
    if (textoInfo == "Productos perdidos:") {
      text = textoInfo;
      if (widget.productoInfo.tipo == "Granel" ||
          widget.productoInfo.tipo == "Costal") {
        text = "Gramos perdidos:";
      } else if (widget.productoInfo.tipo == "Bote") {
        text = "Gramos/Piezas perdidos:";
      }
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * .55,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Textos.textoGeneral(text, 20, true, false),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onLongPress: () => timer = Timer.periodic(
                  Duration(milliseconds: 150),
                  (timer) => cambioValor(valor, -1),
                ),
                onLongPressEnd: (_) => setState(() {
                  timer?.cancel();
                }),
                child: Botones.btnRctMor(
                  "",
                  0,
                  Icons.remove,
                  false,
                  () => cambioValor(valor, -1),
                ),
              ),
              Textos.recuadroCantidad(textoValor.toString(), color[valor], 20),
              GestureDetector(
                onLongPress: () => timer = Timer.periodic(
                  Duration(milliseconds: 150),
                  (timer) => cambioValor(valor, 1),
                ),
                onLongPressEnd: (_) => setState(() {
                  timer?.cancel();
                }),
                child: Botones.btnRctMor(
                  "",
                  0,
                  Icons.add,
                  false,
                  () => cambioValor(valor, 1),
                ),
              ),
              Botones.btnRctMor(
                "Guardar ${text.split(" ")[0]}",
                0,
                Icons.save_rounded,
                false,
                () => setState(() {
                  context.read<Carga>().cargaBool(true);
                  enviarDatos(valor, context);
                  context.read<Carga>().cargaBool(false);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox footer(List<String> textos) {
    List<Widget> lista = [];
    for (int i = 0; i < textos.length; i++) {
      lista.add(Textos.textoGeneral(textos[i], 15, false, false));
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * .35,
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: lista,
      ),
    );
  }
}
