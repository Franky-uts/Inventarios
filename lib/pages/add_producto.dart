import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:provider/provider.dart';
import '../services/local_storage.dart';

class Addproducto extends StatefulWidget {
  final List listaArea;
  final List listaTipo;

  const Addproducto({
    super.key,
    required this.listaArea,
    required this.listaTipo,
  });

  @override
  State<Addproducto> createState() => _AddproductoState();
}

class _AddproductoState extends State<Addproducto> {
  late List<String> listaArea = [];
  late List<String> listaTipo = [];
  late String valorArea, respuesta, valorTipo;
  late bool cantidad, cantidadLimite;
  IconData _iconoScan = Icons.document_scanner_rounded;
  final nombreControl = TextEditingController(),
      cantidadControl = TextEditingController(),
      cantidadLimiteControl = TextEditingController(),
      barrasControl = TextEditingController(),
      limiteFocus = FocusNode();
  late List<Color> colorCampo = [];
  String? res;

  @override
  void initState() {
    cantidad = false;
    cantidadLimite = false;
    listaTipo.add("Tipo");
    listaArea.add("Área");
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
    nombreControl.dispose();
    cantidadControl.dispose();
    barrasControl.dispose();
    limiteFocus.dispose();
    cantidadLimiteControl.dispose();
    listaArea.clear();
    listaTipo.clear();
    super.dispose();
  }

  void cantidadValido(String value) {
    cantidad = false;
    cantidadLimite = true;
    cantidadControl.text = "1";
    if (value == "Bulto" ||
        value == "Caja" ||
        value == "Costal" ||
        value == "Paquete" ||
        value == "Bote" ||
        value == "Granel") {
      cantidad = true;
      cantidadLimite = true;
      cantidadControl.clear();
    } else if (value == "Tipo") {
      cantidad = false;
      cantidadLimite = false;
      cantidadControl.clear();
      cantidadLimiteControl.clear();
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
    if (cantidadLimiteControl.text.isEmpty) {
      colorCampo[4] = Color(0xFFFF0000);
    }
    if (valorArea == "Área") {
      colorCampo[2] = Color(0xFFFF0000);
    }
    if (valorTipo == "Tipo") {
      colorCampo[1] = Color(0xFFFF0000);
    }
    if (nombreControl.text.isNotEmpty &&
        cantidadControl.text.isNotEmpty &&
        cantidadLimiteControl.text.isNotEmpty &&
        valorTipo != "Tipo" &&
        valorArea != "Área") {
      respuesta = await ProductoModel.addProducto(
        nombreControl.text,
        int.parse(cantidadControl.text),
        valorTipo,
        valorArea,
        LocalStorage.local('usuario'),
        LocalStorage.local('locación'),
        barrasControl.text,
        int.parse(cantidadLimiteControl.text),
      );
      String res = respuesta.toString().split(": ")[1];
      if (respuesta.toString().split(": ")[0] != "Error") {
        nombreControl.text = "";
        cantidadControl.text = "";
        cantidadLimiteControl.text = "";
        cantidad = false;
        cantidadLimite = false;
        valorTipo = listaTipo.first;
        valorArea = listaArea.first;
        res = "Se guardo $respuesta correctamente.";
      }
      Textos.toast(res, true);
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
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .365,
                          Icons.numbers_rounded,
                          "Cantidad por unidades",
                          cantidadControl,
                          colorCampo[3],
                          cantidad,
                          false,
                          () => limiteFocus.requestFocus(),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          formato: FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,10})'),
                          ),
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .365,
                          Icons.production_quantity_limits_rounded,
                          "Limite de unidades",
                          cantidadLimiteControl,
                          colorCampo[4],
                          cantidadLimite,
                          false,
                          () => registrarProducto(context),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          focus: limiteFocus,
                          inputType: TextInputType.numberWithOptions(),
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
                MaterialPageRoute(builder: (context) => Inventario()),
              ),
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }
}
