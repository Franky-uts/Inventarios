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
  late bool cantidad, materia;
  IconData _iconoScan = Icons.document_scanner_rounded;
  final List<TextEditingController> controller = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  late List<Color> colorCampo = [];
  String? res;

  @override
  void initState() {
    cantidad = false;
    materia = false;
    listaTipo.add('Tipo');
    listaArea.add('Área');
    listaTipo.addAll(widget.listaTipo.map((item) => item as String).toList());
    listaArea.addAll(widget.listaArea.map((item) => item as String).toList());
    valorArea = listaArea.first;
    valorTipo = listaTipo.first;
    for (int i = 0; i < 5; i++) {
      colorCampo.add(Color(0x00FFFFFF));
    }
    super.initState();
  }

  @override
  void dispose() {
    colorCampo.clear();
    controller.clear();
    listaArea.clear();
    listaTipo.clear();
    super.dispose();
  }

  void cantidadValido(String value) {
    cantidad = false;
    controller[1].text = '1';
    if (value == 'Bulto' ||
        value == 'Caja' ||
        value == 'Costal' ||
        value == 'Paquete' ||
        value == 'Bote') {
      cantidad = true;
      controller[1].clear();
    } else if (value == 'Tipo') {
      cantidad = false;
      controller[1].clear();
    }
  }

  void registrarProducto(BuildContext ctx) async {
    setState(() {
      context.read<Carga>().cargaBool(true);
    });
    for (int i = 0; i < colorCampo.length; i++) {
      colorCampo[i] = Color(0x00FFFFFF);
    }
    if (controller[0].text.isEmpty) {
      colorCampo[0] = Color(0xFFFF0000);
    }
    if (controller[1].text.isEmpty) {
      colorCampo[3] = Color(0xFFFF0000);
    }
    if (controller[3].text.isEmpty) {
      colorCampo[4] = Color(0xFFFF0000);
    }
    if (valorArea == 'Área') {
      colorCampo[2] = Color(0xFFFF0000);
    }
    if (valorTipo == 'Tipo') {
      colorCampo[1] = Color(0xFFFF0000);
    }
    if (controller[0].text.isNotEmpty &&
        controller[1].text.isNotEmpty &&
        controller[3].text.isNotEmpty &&
        valorTipo != 'Tipo' &&
        valorArea != 'Área') {
      String respuesta = await ArticulosModel.addArticulo(
        controller[0].text,
        valorTipo,
        valorArea,
        double.parse(controller[1].text),
        controller[2].text,
        double.parse(controller[3].text),
        materia,
      );
      if (respuesta.split(': ')[0] != 'Error') {
        controller[0].text = '';
        controller[1].text = '';
        controller[2].text = '';
        controller[3].text = '';
        cantidad = false;
        valorTipo = listaTipo.first;
        valorArea = listaArea.first;
        respuesta = 'Se guardo $respuesta correctamente.';
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
      if (controller[2].text.isEmpty) {
        _iconoScan = Icons.refresh_rounded;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
      drawer: RecDrawer.drawer(context, [
        Consumer<Carga>(
          builder: (context, carga, child) {
            return Botones.icoCirMor(
              'Ver artículos',
              Icons.list,
              false,
              () => {
                carga.cargaBool(true),
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Articulos()),
                ),
                carga.cargaBool(false),
              },
              () => {},
              true,
            );
          },
        ),
        Consumer<Carga>(
          builder: (context, carga, child) {
            return Botones.icoCirMor(
              'Ver almacen',
              Icons.inventory_rounded,
              false,
              () => {
                carga.cargaBool(true),
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OrdenesInventario()),
                ),
                carga.cargaBool(false),
              },
              () => {},
              true,
            );
          },
        ),
        Consumer<Carga>(
          builder: (context, carga, child) {
            return Botones.icoCirMor(
              'Ordenes',
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
              () => {},
              true,
            );
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .675,
                          Icons.file_copy_rounded,
                          'Nombre',
                          controller[0],
                          colorCampo[0],
                          true,
                          false,
                          () => FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                        Column(
                          children: [
                            Textos.textoBlanco('Materia prima', 15),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .075,
                              child: Botones.btnRctMor(
                                'Materia Prima',
                                20,
                                materia
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                false,
                                () => setState(() {
                                  materia = !materia;
                                }),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Textos.textoBlanco('Área', 15),
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
                            Textos.textoBlanco('Tipo', 15),
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
                    Row(
                      spacing: 5,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .365,
                          Icons.numbers_rounded,
                          'Cantidad por unidades',
                          controller[1],
                          colorCampo[3],
                          cantidad,
                          false,
                          () => FocusManager.instance.primaryFocus?.unfocus(),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          formato: FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,3})'),
                          ),
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .365,
                          Icons.numbers_rounded,
                          'Precio',
                          controller[3],
                          colorCampo[4],
                          true,
                          false,
                          () => FocusManager.instance.primaryFocus?.unfocus(),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          formato: FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,3})'),
                          ),
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75 * .925,
                          Icons.barcode_reader,
                          'Codigo de barras',
                          controller[2],
                          Color(0x00FFFFFF),
                          false,
                          false,
                          () => {},
                        ),
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width * (.75 * .075),
                          child: Botones.btnSimple(
                            'Escanear código',
                            _iconoScan,
                            Color(0xFFFFFFFF),
                            () async => {
                              if (controller[2].text.isEmpty)
                                {
                                  controller[2].text = await Textos.scan(
                                    context,
                                  ),
                                  if (controller[2].text == '-1')
                                    {controller[2].text = ''},
                                }
                              else
                                {controller[2].text = ''},
                              iconoScan(),
                            },
                          ),
                        ),
                      ],
                    ),
                    Botones.iconoTexto(
                      'Añadir',
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
