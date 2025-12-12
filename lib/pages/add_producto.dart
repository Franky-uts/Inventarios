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
  late bool cantidad;
  IconData _iconoScan = Icons.document_scanner_rounded;
  final nombreControl = TextEditingController(),
      cantidadControl = TextEditingController(),
      barrasControl = TextEditingController();
  late List<Color> colorCampo = [
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
  ];
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
    } else {
      cantidad = false;
      cantidadControl.text = "1";
    }
  }

  void registrarProducto(BuildContext ctx) async {
    setState(() {
      colorCampo[3] = Color(0x00FFFFFF);
      colorCampo[1] = Color(0x00FFFFFF);
      colorCampo[0] = Color(0x00FFFFFF);
      colorCampo[2] = Color(0x00FFFFFF);
    });
    if (nombreControl.text.isEmpty) {
      setState(() {
        colorCampo[0] = Color(0xFFFF0000);
      });
    }
    if (cantidadControl.text.isEmpty) {
      setState(() {
        colorCampo[3] = Color(0xFFFF0000);
      });
    }
    if (valorArea == "Área") {
      setState(() {
        colorCampo[2] = Color(0xFFFF0000);
      });
    }
    if (valorTipo == "Tipo") {
      setState(() {
        colorCampo[1] = Color(0xFFFF0000);
      });
    }
    if (nombreControl.text.isNotEmpty &&
        cantidadControl.text.isNotEmpty &&
        valorTipo != "Tipo" &&
        valorArea != "Área") {
      context.read<Carga>().cargaBool(true);
      respuesta = await ProductoModel.addProducto(
        nombreControl.text,
        int.parse(cantidadControl.text),
        valorTipo,
        valorArea,
        LocalStorage.local('usuario'),
        LocalStorage.local('locación'),
        barrasControl.text,
      );
      if (respuesta.toString().split(": ")[0] != "Error") {
        setState(() {
          nombreControl.text = "";
          cantidadControl.text = "";
          cantidad = false;
          valorTipo = listaTipo.first;
          valorArea = listaArea.first;
        });
        Textos.toast("Se guardo $respuesta correctamente.", true);
        if (ctx.mounted) {
          ctx.read<Carga>().cargaBool(false);
        }
      } else {
        if (ctx.mounted) {
          ctx.read<Carga>().cargaBool(false);
        }
        Textos.toast(respuesta.toString().split(": ")[1], true);
      }
    }
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
                  spacing: 20,
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
                    CampoTexto.inputTexto(
                      MediaQuery.of(context).size.width * .75,
                      Icons.numbers_rounded,
                      "Cantidad por unidades",
                      cantidadControl,
                      colorCampo[3],
                      cantidad,
                      false,
                      () => registrarProducto(context),
                      formato: FilteringTextInputFormatter.allow(
                        RegExp(r'(^\d*\.?\d{0,10})'),
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
                            () async => {
                              iconoScan(),
                              if (barrasControl.text.isEmpty)
                                {
                                  barrasControl.text = await Textos.scan(
                                    context,
                                  ),
                                }
                              else
                                {barrasControl.text = ""},
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
}
