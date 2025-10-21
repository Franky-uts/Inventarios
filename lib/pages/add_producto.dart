import 'package:flutter/material.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/pages/inventario.dart';

class Addproducto extends StatefulWidget {
  final UsuarioModel usuario;
  final String busqueda;

  const Addproducto({super.key, required this.usuario, required this.busqueda});

  @override
  State<Addproducto> createState() => _AddproductoState();
}

class _AddproductoState extends State<Addproducto> {
  late List<String> lista = <String>['One', 'Two', 'Three', 'Four'];
  late bool carga;
  final nombreControl = TextEditingController(),
      tipoControl = TextEditingController(),
      areaControl = TextEditingController(),
      cantidadControl = TextEditingController();
  late int colorNombre = 0xFFFFFFFFFF,
      colorTipo = 0xFFFFFFFF,
      colorArea = 0xFFFFFFFFFF,
      colorCantidad = 0xFFFFFFFFFF;

  void cambioSeleccionTipo(TextEditingController control, String valor) {
    control.text = valor;
  }

  void cambioSeleccionArea(TextEditingController control, String valor) {
    control.text = valor;
  }

  @override
  void initState() {
    carga = false;
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
                spacing: 25,
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
                      campoDeSeleccion(
                        tipoControl,
                        colorTipo,
                        "Tipo",
                        Icon(Icons.settings_suggest, color: Colors.white),
                      ),
                      campoDeSeleccion2(
                        areaControl,
                        colorArea,
                        "Área",
                        Icon(
                          Icons.door_front_door_rounded,
                          color: Colors.white,
                        ),
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
                      }) /*
                    if (usuarioContr.text.isNotEmpty &&
                        contr.text.isNotEmpty){
                      setState(() {
                        carga = !carga;
                      }),
                      usuarioMod = await UsuarioModel.getUsuario(
                        usuarioContr.text,
                        contr.text,
                      ),
                      if (usuarioMod.nombre != "error"){
                          await LocalStorage.preferencias.setString(
                            'usuario',
                            usuarioMod.nombre,
                          ),
                          await LocalStorage.preferencias.setString(
                            'puesto',
                            usuarioMod.puesto,
                          ),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Inventario(usuario: usuarioMod),
                            ),
                          ),
                        }
                      else {
                          if (usuarioMod.puesto == "El usuario no existe"){
                              setState(() {
                                carga = !carga;
                                colorUsu = 0xFFFF0000;
                              }),
                            }
                          else
                            if (usuarioMod.puesto ==
                                "Contraseña incorrecta"){
                                setState(() {
                                  carga = !carga;
                                  colorCont = 0xFFFF0000;
                                }),
                              }
                            else {
                                Fluttertoast.showToast(
                                  msg: usuarioMod.puesto,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.grey,
                                  textColor: Colors.white,
                                  fontSize: 15,
                                ),
                                setState(() {
                                  carga = !carga;
                                  colorUsu = 0xFFFFFFFF;
                                  colorCont = 0xFFFFFFFF;
                                }),
                              },
                        },
                    },
                    if (usuarioContr.text.isEmpty){
                      setState(() {
                        colorUsu = 0xFFFF0000;
                      }),
                    },
                    if(contr.text.isEmpty){
                      setState(() {
                        colorCont = 0xFFFF0000;
                      }),
                    }*/,
                    },
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.all(15),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: Icon(Icons.login_rounded, color: Colors.white),
                    label: Text(
                      "Ingresar",
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

  Container campoDeSeleccion2(
    TextEditingController control,
    int color,
    String texto,
    Icon icono,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * (.365),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(30),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          elevation: 16,
          dropdownColor: Colors.white,
          icon: icono,
          items: lista.map<DropdownMenuItem>((String value) {
            return DropdownMenuItem(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) {
            control.text = value;
          },
        ),
      ),
    );
  }

  /*PopupMenuButton popUpButton(Icon icono, TextEditingController control) {
    return PopupMenuButton(
      icon: icono,
      itemBuilder: (context){
        return <PopupMenuEntry>[
          for(int i = 0;i<lista.length; i++){
            PopupMenuItem(
              value: "SampleItem.itemThree",
              child: Text('Item 3'),
            )
          },
        ];
      }
    );
  }*/

  DropdownButton dropDownOpciones(Icon icono, TextEditingController control) {
    return DropdownButton(
      elevation: 16,
      dropdownColor: Colors.white,
      icon: icono,
      items: lista.map<DropdownMenuItem>((String value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        control.text = value;
      },
    );
  }
}
