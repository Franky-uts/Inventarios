import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/pages/inventario.dart';

class Addproducto extends StatefulWidget {
  final UsuarioModel usuario;
  final String busqueda;
  final List listaArea;
  final List listaTipo;

  const Addproducto({
    super.key,
    required this.usuario,
    required this.busqueda,
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
  final nombreControl = TextEditingController(),
      cantidadControl = TextEditingController();
  late int colorNombre = 0xFFFFFFFFFF,
      colorTipo = 0xFFFFFFFF,
      colorArea = 0xFFFFFFFFFF,
      colorCantidad = 0xFFFFFFFFFF;

  @override
  void initState() {
    carga = false;
    listaTipo.add("Tipo");
    listaArea.add("Área");
    valorArea = listaArea.last;
    valorTipo = listaTipo.last;
    super.initState();
  }

  @override
  void dispose() {
    carga;
    super.dispose();
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
            Container(
              alignment: Alignment.center,
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  campoDeTexto(
                    nombreControl,
                    colorNombre,
                    "Nombre",
                    Icon(Icons.file_copy_rounded),
                  ),
                  campoDeTexto(
                    cantidadControl,
                    colorCantidad,
                    "Cantidad por unidades",
                    Icon(Icons.numbers_rounded),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Tipo",
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * (.365),
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.settings_suggest,
                                  color: Colors.black,
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
                                      alignment: AlignmentGeometry.center,
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
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          valorTipo = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.warning_rounded,
                                  color: Color(colorTipo),
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
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * (.365),
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.door_front_door_rounded,
                                  color: Colors.black,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  width:
                                      MediaQuery.of(context).size.width *
                                      (.276),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      elevation: 1,
                                      alignment: AlignmentGeometry.center,
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
                                          child: Text(value),
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
                                  color: Color(colorArea),
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
                        colorCantidad = 0xFFFFFFFF;
                        colorTipo = 0xFFFFFFFF;
                        colorNombre = 0xFFFFFFFF;
                        colorArea = 0xFFFFFFFF;
                      }),
                      if (nombreControl.text.isEmpty)
                        {
                          setState(() {
                            colorNombre = 0xFFFF0000;
                          }),
                        },
                      if (cantidadControl.text.isEmpty)
                        {
                          setState(() {
                            colorCantidad = 0xFFFF0000;
                          }),
                        },
                      if (valorArea == "Área")
                        {
                          setState(() {
                            colorArea = 0xFFFF0000;
                          }),
                        },
                      if (valorTipo == "Tipo")
                        {
                          setState(() {
                            colorTipo = 0xFFFF0000;
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
                            widget.usuario.nombre,
                          ),
                          if (respuesta.toString().split(": ")[0] != "Error")
                            {
                              setState(() {
                                nombreControl.text = "";
                                cantidadControl.text = "";
                                valorTipo = listaTipo.last;
                                valorArea = listaArea.last;
                              }),
                              Fluttertoast.showToast(
                                msg: "Se guardo $respuesta correctamente",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.grey,
                                textColor: Colors.white,
                                fontSize: 15,
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
                              Fluttertoast.showToast(
                                msg: respuesta.toString().split(": ")[1],
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.grey,
                                textColor: Colors.white,
                                fontSize: 15,
                              ),
                            },
                        },
                    },
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.all(15),
                      backgroundColor: Colors.black,
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

  Container campoDeTexto(
    TextEditingController control,
    int color,
    String texto,
    Icon icono,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * .75,
      child: TextField(
        controller: control,
        keyboardType: TextInputType.text,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.black, width: 10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          prefixIcon: icono,
          prefixIconColor: Colors.black,
          suffixIcon: Icon(Icons.warning_rounded),
          suffixIconColor: Color(color),
          fillColor: Colors.white,
          label: Text(texto, style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }

  Container campoDeSeleccion(
    TextEditingController control,
    int color,
    String texto,
    Icon icono,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * (.365),
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        keyboardType: TextInputType.none,
        readOnly: true,
        controller: control,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onTap: () {},
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.black, width: 10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          prefixIcon: Container(
            width: 66,
            alignment: Alignment.center,
            padding: EdgeInsets.zero,
            margin: EdgeInsetsGeometry.only(left: 5),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: dropDownOpciones(icono, control),
          ),
          prefixIconColor: Colors.white,
          suffixIcon: Icon(Icons.warning_rounded),
          suffixIconColor: Color(color),
          fillColor: Colors.white,
          label: Text(texto, style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }

  DropdownButton dropDownOpciones(Icon icono, TextEditingController control) {
    return DropdownButton(
      elevation: 16,
      dropdownColor: Colors.white,
      icon: icono,
      items: listaArea.map<DropdownMenuItem>((String value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        control.text = value;
      },
    );
  }
}
