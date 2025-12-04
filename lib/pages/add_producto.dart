import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/toast_text.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/inventario.dart';
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
  late List<String> listaArea = widget.listaArea
      .map((item) => item as String)
      .toList();
  late List<String> listaTipo = widget.listaTipo
      .map((item) => item as String)
      .toList();
  late String valorArea;
  late String valorTipo;
  late String respuesta;
  late bool carga;
  late bool cantidad;
  final nombreControl = TextEditingController(),
      cantidadControl = TextEditingController();
  late List<int> colorCampo = [0x00FFFFFF, 0x00FFFFFF, 0x00FFFFFF, 0x00FFFFFF];

  @override
  void initState() {
    carga = false;
    cantidad = false;
    listaTipo.add("Tipo");
    listaArea.add("Área");
    valorArea = listaArea.last;
    valorTipo = listaTipo.last;
    super.initState();
  }

  @override
  void dispose() {
    colorCampo.clear();
    nombreControl.dispose();
    cantidadControl.dispose();
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
        value == "Kilo") {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
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
            Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    campoDeTexto(
                      nombreControl,
                      colorCampo[0],
                      "Nombre",
                      Icon(Icons.file_copy_rounded, color: Color(0xFF8F01AF)),
                      TextInputType.text,
                      FilteringTextInputFormatter.singleLineFormatter,
                      true,
                    ),
                    campoDeTexto(
                      cantidadControl,
                      colorCampo[3],
                      "Cantidad por unidades",
                      Icon(Icons.numbers_rounded, color: Color(0xFF8F01AF)),
                      TextInputType.number,
                      FilteringTextInputFormatter.digitsOnly,
                      cantidad,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Tipo",
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * (.365),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Color(0xFFFDC930),
                                  width: 2.5,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.settings_suggest,
                                    color: Color(0xFF8F01AF),
                                  ),
                                  Container(
                                    padding: EdgeInsetsGeometry.symmetric(
                                      horizontal: 10,
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width *
                                        (.276),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        elevation: 1,
                                        alignment: AlignmentGeometry.centerLeft,
                                        value: valorTipo,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white,
                                        ),
                                        dropdownColor: Colors.white,
                                        items: listaTipo.map<DropdownMenuItem>((
                                          String value,
                                        ) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                color: Color(0xFF8F01AF),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          cantidadValido(value);
                                          setState(() {
                                            valorTipo = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.warning_rounded,
                                    color: Color(colorCampo[1]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Área",
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * (.365),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Color(0xFFFDC930),
                                  width: 2.5,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.door_front_door_rounded,
                                    color: Color(0xFF8F01AF),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width *
                                        (.276),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        elevation: 1,
                                        alignment: AlignmentGeometry.centerLeft,
                                        value: valorArea,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white,
                                        ),
                                        dropdownColor: Colors.white,
                                        items: listaArea.map<DropdownMenuItem>((
                                          String value,
                                        ) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                color: Color(0xFF8F01AF),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            valorArea = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.warning_rounded,
                                    color: Color(colorCampo[2]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () async => {
                        setState(() {
                          colorCampo[3] = 0x00FFFFFF;
                          colorCampo[1] = 0x00FFFFFF;
                          colorCampo[0] = 0x00FFFFFF;
                          colorCampo[2] = 0x00FFFFFF;
                        }),
                        if (nombreControl.text.isEmpty)
                          {
                            setState(() {
                              colorCampo[0] = 0xFFFF0000;
                            }),
                          },
                        if (cantidadControl.text.isEmpty)
                          {
                            setState(() {
                              colorCampo[3] = 0xFFFF0000;
                            }),
                          },
                        if (valorArea == "Área")
                          {
                            setState(() {
                              colorCampo[2] = 0xFFFF0000;
                            }),
                          },
                        if (valorTipo == "Tipo")
                          {
                            setState(() {
                              colorCampo[1] = 0xFFFF0000;
                            }),
                          },
                        if (nombreControl.text.isNotEmpty &&
                            cantidadControl.text.isNotEmpty &&
                            valorTipo != "Tipo" &&
                            valorArea != "Área")
                          {
                            setState(() {
                              carga = !carga;
                            }),
                            respuesta = await ProductoModel.addProducto(
                              nombreControl.text,
                              int.parse(cantidadControl.text),
                              valorTipo,
                              valorArea,
                              LocalStorage.local('usuario'),
                              LocalStorage.local('locación'),
                            ),
                            if (respuesta.toString().split(": ")[0] != "Error")
                              {
                                setState(() {
                                  nombreControl.text = "";
                                  cantidadControl.text = "";
                                  cantidad = false;
                                  valorTipo = listaTipo.last;
                                  valorArea = listaArea.last;
                                }),
                                ToastText.toast(
                                  "Se guardo $respuesta correctamente.",
                                  true,
                                ),
                                setState(() {
                                  carga = !carga;
                                }),
                              }
                            else
                              {
                                setState(() {
                                  carga = !carga;
                                }),
                                ToastText.toast(
                                  respuesta.toString().split(": ")[1],
                                  true,
                                ),
                              },
                          },
                      },
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.all(15),
                        backgroundColor: Color(0xFF8F01AF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: Icon(Icons.add_circle_rounded, color: Colors.white),
                      label: Text(
                        "Añadir",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Carga.ventanaCarga(carga),
          ],
        ),
      ),
    );
  }

  SizedBox campoDeTexto(
    TextEditingController control,
    int color,
    String texto,
    Icon icono,
    TextInputType input,
    TextInputFormatter filtro,
    bool enabled,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .75,
      child: TextField(
        controller: control,
        inputFormatters: [filtro],
        keyboardType: input,
        enabled: enabled,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        cursorColor: Color(0xFF8F01AF),
        style: TextStyle(color: Color(0xFF8F01AF)),
        decoration: InputDecoration(
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color(0xFFFDC930), width: 2.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color(0xFFFDC930), width: 2.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color(0x80FDC930), width: 1.5),
          ),
          prefixIcon: icono,
          suffixIcon: Icon(Icons.warning_rounded),
          suffixIconColor: Color(color),
          fillColor: Colors.white,
          label: Text(texto, style: TextStyle(color: Color(0xFF8F01AF))),
        ),
      ),
    );
  }
}
