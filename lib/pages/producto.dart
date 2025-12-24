import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:provider/provider.dart';

class Producto extends StatefulWidget {
  final ProductoModel productoInfo;
  final StatefulWidget ruta;

  const Producto({super.key, required this.productoInfo, required this.ruta});

  @override
  State<Producto> createState() => _ProductoState();
}

class _ProductoState extends State<Producto> {
  late int cajasEntrantes = widget.productoInfo.entrada,
      cajasSalida = widget.productoInfo.salida;
  double productosPerdido = 0;
  Timer? timer;
  String texto = "";
  late Widget wid;
  FocusNode focus = FocusNode();
  final List<Color> color = [];
  List<TextEditingController> controller = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    for (int i = 0; i < 5; i++) {
      Color color = Color(0xFF8A03A9);
      if (i > 2) {
        color = Color(0x00FFFFFF);
      }
      this.color.add(color);
    }
    for (int i = 0; i < widget.productoInfo.perdidaCantidad.length; i++) {
      productosPerdido += widget.productoInfo.perdidaCantidad[i];
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.clear();
    timer?.cancel();
    color.clear();
    super.dispose();
  }

  Future enviarDatos(int valor, BuildContext ctx) async {
    setState(() {
      ctx.read<Carga>().cargaBool(true);
    });
    String texto = "No hay cambios";
    bool error = true;
    switch (valor) {
      case 0:
        if (cajasEntrantes > widget.productoInfo.entrada) {
          final double unidades =
              ((cajasEntrantes - widget.productoInfo.entrada) +
                      widget.productoInfo.unidades)
                  .toDouble();
          texto = await ProductoModel.guardarDatos(
            "Entradas",
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
          final double unidades =
              (widget.productoInfo.unidades -
                      (cajasSalida - widget.productoInfo.salida))
                  .toDouble();
          texto = await ProductoModel.guardarDatos(
            "Salidas",
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
    }
    if (ctx.mounted) {
      setState(() {
        ctx.read<Carga>().cargaBool(false);
      });
    }
    setState(() {
      if (error) {
        color[valor] = Color(0xFF8A03A9);
      }
    });
    if (texto.isNotEmpty) {
      Textos.toast(texto, false);
    }
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
    }
    setState(() {
      this.color[tipo] = Color(color);
    });
  }

  void guardarPerdidas(BuildContext ctx) async {
    bool valido = true;
    for (int i = 0; i < controller.length; i++) {
      setState(() {
        color[i + 3] = Color(0x00FFFFFF);
      });
      if (controller[i].text.isEmpty) {
        valido = false;
        setState(() {
          color[i + 3] = Color(0xFFFF0000);
        });
      }
    }
    if (valido) {
      ctx.read<Carga>().cargaBool(true);
      List<double> listaCantidades = [];
      List<String> listaRazones = [];
      listaCantidades.addAll(widget.productoInfo.perdidaCantidad);
      listaRazones.addAll(widget.productoInfo.perdidaRazones);
      listaCantidades.add(double.parse(controller[0].text));
      listaRazones.add(controller[1].text);
      double perdidas = double.parse(controller[0].text);
      double unidades =
          (((widget.productoInfo.cantidadPorUnidad *
                  widget.productoInfo.unidades) -
              perdidas) /
          widget.productoInfo.cantidadPorUnidad);
      String mensaje = await ProductoModel.guardarPerdidas(
        listaRazones,
        listaCantidades,
        unidades,
        widget.productoInfo.id,
      );
      if (mensaje.split(": ")[0] != "Error") {
        setState(() {
          widget.productoInfo.perdidaRazones = listaRazones;
          widget.productoInfo.perdidaCantidad = listaCantidades;
          widget.productoInfo.unidades = unidades;
          productosPerdido += perdidas;
        });
      }
      Textos.toast(mensaje, true);
      if (ctx.mounted) {
        ctx.read<Ventanas>().emergente(mensaje.split(":")[0] == "Error");
        ctx.read<Ventanas>().tabla(mensaje.split(":")[0] != "Error");
        ctx.read<Carga>().cargaBool(false);
      }
    }
  }

  void editarLimite(BuildContext ctx) async {
    if (controller[0].text.isEmpty) {
      setState(() {
        color[3] = Color(0xFFFF0000);
      });
    } else {
      ctx.read<Carga>().cargaBool(true);
      String mensaje = await ProductoModel.editarProducto(
        widget.productoInfo.id,
        controller[0].text,
        "LimiteProd",
      );
      if (mensaje.split(": ")[0] != "Error") {
        setState(() {
          color[3] = Color(0x00000000);
          widget.productoInfo.limiteProd = double.parse(
            controller[0].text,
          ).floor();
          controller[0].text = "";
        });
        mensaje =
            "Se actualizó el límite de productos del producto con id $mensaje.";
        if (ctx.mounted) {
          ctx.read<Ventanas>().emergente(false);
          ctx.read<Carga>().cargaBool(false);
        }
      }
      Textos.toast(mensaje, true);
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
            Consumer<Carga>(
              builder: (context, carga, child) {
                return SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Textos.textoTilulo(widget.productoInfo.nombre, 30),
                        tipoTexto(widget.productoInfo.tipo),
                        contenedorInfo(
                          " que entraron:",
                          cajasEntrantes.toString(),
                          0,
                        ),
                        contenedorInfo(
                          " que salieron:",
                          cajasSalida.toString(),
                          1,
                        ),
                        contenedorInfo(
                          "Productos perdidos:",
                          productosPerdido.toString(),
                          2,
                        ),
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
                );
              },
            ),
            Botones.layerButton(
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => widget.ruta),
              ),
            ),
            Consumer2<Ventanas, VenDatos>(
              builder: (context, ventana, venDatos, child) {
                Widget wid = Textos.textoTilulo(
                  "No hay perdidas registradas.",
                  30,
                );
                Widget tabla = Botones.btnCirRos(
                  "Agregar perdida",
                  () => {ventana.emergente(true), ventana.tabla(false)},
                );
                List<Widget> botones = [
                  Botones.btnCirRos("Cerrar", () => ventana.tabla(false)),
                ];
                if (productosPerdido > 0) {
                  wid = Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.2, .6],
                    ["Razón de perdida", "Cantidad perdida"],
                  );
                  tabla = ListView.separated(
                    itemCount: widget.productoInfo.perdidaCantidad.length,
                    scrollDirection: Axis.vertical,
                    separatorBuilder: (context, index) => Container(
                      height: 2,
                      decoration: BoxDecoration(color: Color(0xFFFDC930)),
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 40,
                        decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                        child: Tablas.barraDatos(
                          MediaQuery.sizeOf(context).width,
                          [.2, .6],
                          [
                            widget.productoInfo.perdidaCantidad[index]
                                .toString(),
                            widget.productoInfo.perdidaRazones[index],
                          ],
                          [],
                          false,
                        ),
                      );
                    },
                  );
                  botones.add(
                    Botones.btnCirRos(
                      "Agregar perdida",
                      () => {
                        setState(() {
                          controller[0].text = "";
                          controller[1].text = "";
                          color[3] = Color(0x00000000);
                          color[4] = Color(0x00000000);
                        }),
                        ventana.emergente(true),
                        ventana.tabla(false),
                      },
                    ),
                  );
                }
                return Ventanas.ventanaTabla(
                  MediaQuery.of(context).size.height,
                  MediaQuery.of(context).size.width,
                  ["Perdidas: $productosPerdido"],
                  [],
                  wid,
                  tabla,
                  botones,
                );
              },
            ),
            Consumer3<Ventanas, Carga, Tablas>(
              builder: (context, ventana, carga, tablas, child) {
                List<Widget> wid = [
                  CampoTexto.inputTexto(
                    MediaQuery.of(context).size.width * .75,
                    Icons.numbers_rounded,
                    "Cantidad",
                    controller[0],
                    color[3],
                    true,
                    false,
                    () => {
                      if (texto == "¿Cuánto se perdió y por qué?")
                        {focus.requestFocus()}
                      else
                        {editarLimite(context)},
                    },
                    formato: FilteringTextInputFormatter.allow(
                      RegExp(r'(^\d*\.?\d{0,3})'),
                    ),
                    inputType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ];
                if (texto == "¿Cuánto se perdió y por qué?") {
                  wid.add(
                    CampoTexto.inputTexto(
                      MediaQuery.of(context).size.width * .75,
                      Icons.message_rounded,
                      "Razón de la perdida",
                      controller[1],
                      color[4],
                      true,
                      false,
                      () => guardarPerdidas(context),
                      focus: focus,
                    ),
                  );
                }
                return Ventanas.ventanaEmergente(
                  texto,
                  "Volver",
                  "Guardar",
                  () => {
                    ventana.emergente(false),
                    setState(() {
                      color[3] = Color(0x00000000);
                      color[4] = Color(0x00000000);
                    }),
                    ventana.tabla(texto == "¿Cuánto se perdió y por qué?"),
                  },
                  () async => {
                    if (texto == "¿Cuánto se perdió y por qué?")
                      {guardarPerdidas(context)}
                    else
                      {editarLimite(context)},
                  },
                  widget: SingleChildScrollView(
                    child: Column(spacing: 10, children: wid),
                  ),
                );
              },
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
    wid.last = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        wid.last,
        SizedBox(
          height: 40,
          child: Botones.btnSimple(
            "Editar limite",
            Icons.edit_rounded,
            Color(0xFF8A03A9),
            () => {
              context.read<Ventanas>().emergente(true),
              setState(() {
                controller[0].text = widget.productoInfo.limiteProd.toString();
                color[3] = Color(0x00000000);
                texto = "Confirma el nuevo límite de productos.";
              }),
            },
          ),
        ),
      ],
    );
    return SizedBox(
      width: MediaQuery.of(context).size.width * .5,
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: wid,
          ),
          Textos.recuadroCantidad(
            widget.productoInfo.unidades.toString(),
            Textos.colorLimite(
              widget.productoInfo.limiteProd,
              widget.productoInfo.unidades.floor(),
            ),
            20,
          ),
        ],
      ),
    );
  }

  SizedBox contenedorInfo(String textoInfo, String textoValor, int valor) {
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
    List<Widget> botones = [];
    if (textoInfo != "Productos perdidos:") {
      botones.add(
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
      );
    }
    botones.add(Textos.recuadroCantidad(textoValor, color[valor], 20));
    if (textoInfo != "Productos perdidos:") {
      botones.add(
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
      );
    }
    if (textoInfo != "Productos perdidos:") {
      botones.add(
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
      );
    }
    if (textoInfo == "Productos perdidos:") {
      botones.add(
        Botones.btnRctMor(
          textoInfo.split(":")[0],
          0,
          Icons.info_outline_rounded,
          false,
          () => {
            context.read<Ventanas>().tabla(true),
            setState(() {
              texto = "¿Cuánto se perdió y por qué?";
            }),
          },
        ),
      );
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
            children: botones,
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
