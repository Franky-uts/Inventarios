import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:inventarios/pages/ordenes.dart';
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
  late bool verContr;
  late IconData iconoContr;

  @override
  void initState() {
    colorUsu = 0x00FFFFFF;
    colorCont = 0x00FFFFFF;
    verContr = true;
    carga = true;
    iconoContr = Icons.remove_red_eye_rounded;
    super.initState();
  }

  @override
  void dispose() {
    contr.dispose();
    usuarioContr.dispose();
    super.dispose();
  }

  void verificar(BuildContext ctx) async {
    if (usuarioContr.text.isNotEmpty && contr.text.isNotEmpty) {
      setState(() {
        carga = !carga;
      });
      usuarioMod = await UsuarioModel.getUsuario(usuarioContr.text, contr.text);
      if (usuarioMod.nombre != "error") {
        await LocalStorage.preferencias.setString(
          'conexion',
          "http://189.187.153.15:3000",
        );
        await LocalStorage.preferencias.setString('usuario', usuarioMod.nombre);
        await LocalStorage.preferencias.setString('puesto', usuarioMod.puesto);
        await LocalStorage.preferencias.setString(
          'locación',
          usuarioMod.locacion,
        );
        await LocalStorage.preferencias.setString('busqueda', "");
        if (ctx.mounted) {
          if (usuarioMod.puesto == "Proveedor") {
            Navigator.pushReplacement(
              ctx,
              MaterialPageRoute(builder: (ctx) => Ordenes()),
            );
          } else {
            Navigator.pushReplacement(
              ctx,
              MaterialPageRoute(builder: (ctx) => Inventario()),
            );
          }
        }
      } else {
        if (usuarioMod.puesto == "El usuario no existe") {
          setState(() {
            carga = !carga;
            colorUsu = 0xFFFF0000;
          });
        } else if (usuarioMod.puesto == "Contraseña incorrecta") {
          setState(() {
            carga = !carga;
            colorCont = 0xFFFF0000;
          });
        } else {
          Fluttertoast.showToast(
            msg: usuarioMod.puesto,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Color(0x80FDC930),
            textColor: Colors.white,
            fontSize: 15,
          );
          setState(() {
            carga = !carga;
            colorUsu = 0x00FFFFFF;
            colorCont = 0x00FFFFFF;
          });
        }
      }
    }
    if (usuarioContr.text.isEmpty) {
      setState(() {
        colorUsu = 0xFFFF0000;
      });
    }
    if (contr.text.isEmpty) {
      setState(() {
        colorCont = 0xFFFF0000;
      });
    }
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Image.asset(
                        'assets/logo.jpg',
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .75,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: usuarioContr,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        cursorColor: Color(0xFF8F01AF),
                        style: TextStyle(color: Color(0xFF8F01AF)),
                        decoration: InputDecoration(
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Color(0xFFFDC930),
                              width: 3.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Color(0xFFFDC930),
                              width: 3.5,
                            ),
                          ),
                          prefixIcon: Icon(Icons.person_rounded),
                          prefixIconColor: Color(0xFF8F01AF),
                          suffixIcon: Icon(Icons.warning_rounded),
                          suffixIconColor: Color(colorUsu),
                          fillColor: Colors.white,
                          label: Text(
                            "Usuario",
                            style: TextStyle(color: Color(0xFF8F01AF)),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * .69,
                          margin: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 0,
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            obscureText: verContr,
                            controller: contr,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            cursorColor: Color(0xFF8F01AF),
                            style: TextStyle(color: Color(0xFF8F01AF)),
                            decoration: InputDecoration(
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Color(0xFFFDC930),
                                  width: 3.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Color(0xFFFDC930),
                                  width: 3.5,
                                ),
                              ),
                              prefixIcon: Icon(Icons.lock_rounded),
                              prefixIconColor: Color(0xFF8F01AF),
                              suffixIcon: Icon(Icons.warning_rounded),
                              suffixIconColor: Color(colorCont),
                              fillColor: Colors.white,
                              label: Text(
                                "Contraseña",
                                style: TextStyle(color: Color(0xFF8F01AF)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * .057,
                          alignment: Alignment.center,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                verContr = !verContr;
                                if (verContr) {
                                  iconoContr = Icons.remove_red_eye_rounded;
                                } else {
                                  iconoContr = Icons.remove_red_eye_outlined;
                                }
                              });
                            },
                            icon: Icon(
                              iconoContr,
                              color: Color(0xFFFFFFFF),
                              size: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: carga,
                      child: TextButton.icon(
                        onPressed: () async => {
                          setState(() {
                            colorCont = 0x00FFFFFF;
                            colorUsu = 0x00FFFFFF;
                          }),
                          verificar(context),
                        },
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.all(15),
                          backgroundColor: Color(0xFF8A03A9),
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
                    Visibility(
                      visible: !carga,
                      child: CircularProgressIndicator(
                        color: Color(0xFFF6AFCF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: !kIsWeb,
              child: Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: IconButton.filled(
                  onPressed: () {},
                  icon: Icon(
                    Icons.settings,
                    size: 35,
                    color: Color(0xFFFFFFFF),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Color(0xFF8F01AF),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
