import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:inventarios/services/local_storage.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final usuarioContr = TextEditingController();
  final contr = TextEditingController();
  late int colorUsu, colorCont;
  late UsuarioModel usuarioMod;
  late bool carga;

  @override
  void initState() {
    colorUsu = 0xFFFFFFFF;
    colorCont = 0xFFFFFFFF;
    carga = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: PopScope(
        canPop: false,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .75,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: usuarioContr,
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
                    prefixIcon: Icon(Icons.person_rounded),
                    prefixIconColor: Colors.black,
                    suffixIcon: Icon(Icons.warning_rounded),
                    suffixIconColor: Color(colorUsu),
                    fillColor: Colors.white,
                    label: Text(
                      "Usuario",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .75,
                margin: EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: TextField(
                  obscureText: true,
                  controller: contr,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.black, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock_rounded),
                    prefixIconColor: Colors.black,
                    suffixIcon: Icon(Icons.warning_rounded),
                    suffixIconColor: Color(colorCont),
                    fillColor: Colors.white,
                    label: Text(
                      "Contraseña",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: carga,
                child: TextButton.icon(
                  onPressed: () async => {
                    setState(() {
                      colorCont = 0xFFFFFFFF;
                      colorUsu = 0xFFFFFFFF;
                    }),
                    if (usuarioContr.text.isNotEmpty && contr.text.isNotEmpty)
                      {
                        setState(() {
                          carga = !carga;
                        }),
                        usuarioMod = await UsuarioModel.getUsuario(
                          usuarioContr.text,
                          contr.text,
                        ),
                        if (usuarioMod.nombre != "error")
                          {
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
                                    Inventario(usuario: usuarioMod, busqueda: "",),
                              ),
                            ),
                          }
                        else
                          {
                            if (usuarioMod.puesto == "El usuario no existe")
                              {
                                setState(() {
                                  carga = !carga;
                                  colorUsu = 0xFFFF0000;
                                }),
                              }
                            else if (usuarioMod.puesto ==
                                "Contraseña incorrecta")
                              {
                                setState(() {
                                  carga = !carga;
                                  colorCont = 0xFFFF0000;
                                }),
                              }
                            else
                              {
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
                    if (usuarioContr.text.isEmpty)
                      {
                        setState(() {
                          colorUsu = 0xFFFF0000;
                        }),
                      },
                    if (contr.text.isEmpty)
                      {
                        setState(() {
                          colorCont = 0xFFFF0000;
                        }),
                      },
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
              ),
              Visibility(visible: !carga, child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
