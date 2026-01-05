import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/inventario_prod.dart';
import 'package:provider/provider.dart';

class PerdidasProv extends StatefulWidget {
  final ProductoModel productoInfo;

  const PerdidasProv({super.key, required this.productoInfo});

  @override
  State<PerdidasProv> createState() => _PerdidasProvState();
}

class _PerdidasProvState extends State<PerdidasProv> {
  double productosPerdido = 0;
  FocusNode focus = FocusNode();
  List<Color> colores = [Color(0x00000000), Color(0x00000000)];
  List<TextEditingController> controller = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    for (int i = 0; i < widget.productoInfo.perdidaCantidad.length; i++) {
      productosPerdido += widget.productoInfo.perdidaCantidad[i];
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void guardarPerdidas(BuildContext ctx) {
    bool valido = true, granel = (widget.productoInfo.tipo == "Granel");
    for (int i = 0; i < controller.length; i++) {
      setState(() {
        colores[i] = Color(0x00000000);
      });
      if (controller[i].text.isEmpty) {
        valido = false;
        setState(() {
          colores[i] = Color(0xFFFF0000);
        });
      }
    }
    if (valido) {
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
      if (granel) double.parse((unidades).toStringAsFixed(3));
      String mensaje = "Error: Las perdidas exceden la cantidad almacenada";
      if (unidades >= 0) {
        mensaje = granel
            ? "Se registro la perdida de $unidades kilos"
            : "Se registro la perdida de $unidades unidades";
        widget.productoInfo.perdidaRazones = listaRazones;
        widget.productoInfo.perdidaCantidad = listaCantidades;
        widget.productoInfo.unidades = unidades;
        productosPerdido += perdidas;
      }
      Textos.toast(mensaje, true);
      ctx.read<Ventanas>().emergente(mensaje.split(":")[0] == "Error");
      ctx.read<Ventanas>().tabla(mensaje.split(":")[0] != "Error");
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .5,
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Textos.textoGeneral(
                                "Área: ${widget.productoInfo.area}",
                                20,
                                true,
                                true,
                                1,
                              ),
                              Textos.textoGeneral(
                                "${widget.productoInfo.tipo}:",
                                20,
                                true,
                                true,
                                1,
                              ),
                              Textos.recuadroCantidad(
                                "${widget.productoInfo.unidades}".split(
                                  ".0",
                                )[0],
                                Textos.colorLimite(
                                  widget.productoInfo.limiteProd,
                                  widget.productoInfo.unidades.floor(),
                                ),
                                20,
                                1,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height*.5,
                          child: Column(
                            children: [
                              (productosPerdido > 0)
                                  ? Tablas.contenedorInfo(
                                      MediaQuery.sizeOf(context).width,
                                      [.05, .15, .6],
                                      [
                                        "#",
                                        "Cantidad perdida",
                                        "Razón de perdida",
                                      ],
                                    )
                                  : Textos.textoTilulo(
                                      "Perdidas: $productosPerdido",
                                      20,
                                    ),
                              if (productosPerdido > 0)
                                ListView.separated(
                                  itemCount: widget
                                      .productoInfo
                                      .perdidaCantidad
                                      .length,
                                  scrollDirection: Axis.vertical,
                                  separatorBuilder: (context, index) =>
                                      Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFDC930),
                                        ),
                                      ),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFFFFF),
                                      ),
                                      child: Tablas.barraDatos(
                                        MediaQuery.sizeOf(context).width,
                                        [.05, .15, .6],
                                        [
                                          "${index + 1}",
                                          "${widget.productoInfo.perdidaCantidad[index]}",
                                          widget
                                              .productoInfo
                                              .perdidaRazones[index],
                                        ],
                                        [],
                                        1,
                                        false,
                                      ),
                                    );
                                  },
                                ),
                              Botones.btnCirRos(
                                "Agregar perdida",
                                () => context.read<Ventanas>().emergente(true),
                              ),
                            ],
                          ),
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
                MaterialPageRoute(builder: (context) => InventarioProd()),
              ),
            ),
            Consumer3<Ventanas, Carga, Tablas>(
              builder: (context, ventana, carga, tablas, child) {
                return Ventanas.ventanaEmergente(
                  "¿Cuánto se perdió y por qué?",
                  "Volver",
                  "Guardar",
                  () => ventana.emergente(false),
                  () async => guardarPerdidas(context),
                  widget: SingleChildScrollView(
                    child: Column(
                      spacing: 10,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75,
                          Icons.numbers_rounded,
                          "Cantidad",
                          controller[0],
                          colores[0],
                          true,
                          false,
                          () => focus.requestFocus(),
                          formato: FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,3})'),
                          ),
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75,
                          Icons.message_rounded,
                          "Razón de la perdida",
                          controller[1],
                          colores[1],
                          true,
                          false,
                          () => guardarPerdidas(context),
                          focus: focus,
                        ),
                      ],
                    ),
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
}
