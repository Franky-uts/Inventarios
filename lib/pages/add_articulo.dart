import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/articulos_model.dart';
import 'package:inventarios/pages/ordenes.dart';
import 'package:provider/provider.dart';
import 'articulos.dart';
import 'ordenes_inventario.dart';

class Addarticulo extends StatefulWidget {
  final List listaArea;
  final List listaTipo;

  const Addarticulo({
    super.key,
    required this.listaArea,
    required this.listaTipo,
  });

  @override
  State<Addarticulo> createState() => _AddproductoState();
}

class _AddproductoState extends State<Addarticulo> {
  late List<String> listaArea = [];
  late List<String> listaTipo = [];
  late String valorArea, valorTipo;
  late bool cantidad;
  IconData _iconoScan = Icons.document_scanner_rounded;
  final nombreControl = TextEditingController(),
      cantidadControl = TextEditingController(),
      barrasControl = TextEditingController();
  late List<Color> colorCampo = [];
  String? res;

  @override
  void initState() {
    cantidad = false;
    listaTipo.add("Tipo");
    listaArea.add("Área");
    listaTipo.addAll(widget.listaTipo.map((item) => item as String).toList());
    listaArea.addAll(widget.listaArea.map((item) => item as String).toList());
    valorArea = listaArea.first;
    valorTipo = listaTipo.first;
    for (int i = 0; i < 4; i++) {
      colorCampo.add(Color(0x00FFFFFF));
    }
    super.initState();
  }

  @override
  void dispose() {
    colorCampo.clear();
    nombreControl.dispose();
    cantidadControl.dispose();
    barrasControl.dispose();
    listaArea.clear();
    listaTipo.clear();
    super.dispose();
  }

  void cantidadValido(String value) {
    cantidad = false;
    cantidadControl.text = "1";
    if (value == "Bulto" ||
        value == "Caja" ||
        value == "Costal" ||
        value == "Paquete" ||
        value == "Bote" ||
        value == "Granel") {
      cantidad = true;
      cantidadControl.clear();
    } else if (value == "Tipo") {
      cantidad = false;
      cantidadControl.clear();
    }
  }

  void registrarProducto(BuildContext ctx) async {
    setState(() {
      context.read<Carga>().cargaBool(true);
    });
    for (int i = 0; i < colorCampo.length; i++) {
      colorCampo[i] = Color(0x00FFFFFF);
    }
    if (nombreControl.text.isEmpty) {
      colorCampo[0] = Color(0xFFFF0000);
    }
    if (cantidadControl.text.isEmpty) {
      colorCampo[3] = Color(0xFFFF0000);
    }
    if (valorArea == "Área") {
      colorCampo[2] = Color(0xFFFF0000);
    }
    if (valorTipo == "Tipo") {
      colorCampo[1] = Color(0xFFFF0000);
    }
    if (nombreControl.text.isNotEmpty &&
        cantidadControl.text.isNotEmpty &&
        valorTipo != "Tipo" &&
        valorArea != "Área") {
      String respuesta = await ArticulosModel.addArticulo(
        nombreControl.text,
        valorTipo,
        valorArea,
        double.parse(cantidadControl.text),
        barrasControl.text,
      );
      respuesta = respuesta.toString();
      if (respuesta.split(": ")[0] != "Error") {
        nombreControl.text = "";
        cantidadControl.text = "";
        cantidad = false;
        valorTipo = listaTipo.first;
        valorArea = listaArea.first;
        respuesta = "Se guardo $respuesta correctamente.";
      }
      Textos.toast(respuesta, true);
    }
    setState(() {
      context.read<Carga>().cargaBool(false);
    });
  }

  void iconoScan() {
    setState(() {
      _iconoScan = Icons.document_scanner_rounded;
      if (barrasControl.text.isEmpty) {
        _iconoScan = Icons.refresh_rounded;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
      drawer: RecDrawer.drawer(context, [
        Botones.icoCirMor(
          "Ver artículos",
          Icons.list,
          false,
          () => {
            context.read<Carga>().cargaBool(true),
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Articulos()),
            ),
            context.read<Carga>().cargaBool(false),
          },
        ),
        Botones.icoCirMor(
          "Ver almacen",
          Icons.inventory_rounded,
          false,
          () => {
            context.read<Carga>().cargaBool(true),
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrdenesInventario()),
            ),
            context.read<Carga>().cargaBool(false),
          },
        ),
        Botones.icoCirMor(
          "Ordenes",
          Icons.border_color_rounded,
          true,
          () => {
            context.read<Carga>().cargaBool(true),
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Ordenes()),
            ),
            context.read<Carga>().cargaBool(false),
          },
        ),
      ]),
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CampoTexto.inputTexto(
                      MediaQuery.of(context).size.width * .75,
                      Icons.file_copy_rounded,
                      "Nombre",
                      nombreControl,
                      colorCampo[0],
                      true,
                      false,
                      () => FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Textos.textoBlanco("Área", 15),
                            CampoTexto.inputDropdown(
                              MediaQuery.of(context).size.width,
                              Icons.door_front_door_rounded,
                              valorArea,
                              listaArea,
                              colorCampo[2],
                              (value) {
                                setState(() {
                                  valorArea = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Textos.textoBlanco("Tipo", 15),
                            CampoTexto.inputDropdown(
                              MediaQuery.of(context).size.width,
                              Icons.settings_suggest,
                              valorTipo,
                              listaTipo,
                              colorCampo[1],
                              (value) {
                                cantidadValido(value);
                                setState(() {
                                  valorTipo = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    CampoTexto.inputTexto(
                      MediaQuery.of(context).size.width * .75,
                      Icons.numbers_rounded,
                      "Cantidad por unidades",
                      cantidadControl,
                      colorCampo[3],
                      cantidad,
                      false,
                      () => FocusManager.instance.primaryFocus?.unfocus(),
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      formato: FilteringTextInputFormatter.allow(
                        RegExp(r'(^\d*\.?\d{0,3})'),
                      ),
                      inputType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75 * .925,
                          Icons.barcode_reader,
                          "Codigo de barras",
                          barrasControl,
                          Color(0x00FFFFFF),
                          false,
                          false,
                          () => {},
                        ),
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width * (.75 * .075),
                          child: Botones.btnSimple(
                            "Escanear código",
                            _iconoScan,
                            Color(0xFFFFFFFF),
                            () async => {
                              if (barrasControl.text.isEmpty)
                                {
                                  barrasControl.text = await Textos.scan(
                                    context,
                                  ),
                                  if (barrasControl.text == "-1")
                                    {barrasControl.text = ""},
                                }
                              else
                                {barrasControl.text = ""},
                              iconoScan(),
                            },
                          ),
                        ),
                      ],
                    ),
                    Botones.iconoTexto(
                      "Añadir",
                      Icons.add_circle_rounded,
                      () => registrarProducto(context),
                    ),
                  ],
                ),
              ),
            ),
            Botones.layerButton(
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Articulos()),
              ),
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }
}
