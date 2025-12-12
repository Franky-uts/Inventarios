import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:inventarios/pages/ordenes.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final usuarioContr = TextEditingController(),
      contr = TextEditingController(),
      usuFocus = FocusNode(),
      contFocus = FocusNode();
  late Color colorUsu, colorCont;
  late UsuarioModel usuarioMod;
  late bool verContr;
  late IconData iconoContr;

  @override
  void initState() {
    colorUsu = Color(0x00FFFFFF);
    colorCont = Color(0x00FFFFFF);
    verContr = true;
    iconoContr = Icons.remove_red_eye_rounded;
    super.initState();
  }

  @override
  void dispose() {
    contr.dispose();
    usuarioContr.dispose();
    usuFocus.dispose();
    contFocus.dispose();
    super.dispose();
  }

  void verificar(BuildContext ctx) async {
    if (usuarioContr.text.isNotEmpty && contr.text.isNotEmpty) {
      context.read<Carga>().cargaBool(true);
      usuarioMod = await UsuarioModel.getUsuario(usuarioContr.text, contr.text);
      if (usuarioMod.nombre != "error") {
        //await LocalStorage.set('conexion', "http://189.187.144.139:3000");
        await LocalStorage.set('conexion', "http://192.168.1.130:3000");
        await LocalStorage.set('usuario', usuarioMod.nombre);
        await LocalStorage.set('puesto', usuarioMod.puesto);
        await LocalStorage.set('locación', usuarioMod.locacion);
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
            colorUsu = Color(0xFFFF0000);
          });
        } else if (usuarioMod.puesto == "Contraseña incorrecta") {
          setState(() {
            colorCont = Color(0xFFFF0000);
          });
        } else {
          Textos.toast(usuarioMod.puesto, false);
          setState(() {
            colorUsu = Color(0x00FFFFFF);
            colorCont = Color(0x00FFFFFF);
          });
        }
      }
      if (ctx.mounted) {
        ctx.read<Carga>().cargaBool(false);
      }
    }
    if (usuarioContr.text.isEmpty) {
      setState(() {
        colorUsu = Color(0xFFFF0000);
      });
    }
    if (contr.text.isEmpty) {
      setState(() {
        colorCont = Color(0xFFFF0000);
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
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .125,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 20,
                  children: [
                    SizedBox(
                      child: Image.asset(
                        'assets/logo.jpg',
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    CampoTexto.inputTexto(
                      MediaQuery.of(context).size.width * .75,
                      Icons.person_rounded,
                      "Usuario",
                      usuarioContr,
                      colorUsu,
                      true,
                      false,
                      () => contFocus.requestFocus(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * (.75 * .925),
                          Icons.lock_rounded,
                          "Contraseña",
                          contr,
                          colorCont,
                          true,
                          verContr,
                          () => verificar(context),
                          focus: contFocus,
                        ),
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width * (.75 * .075),
                          child: Botones.btnSimple(
                            "Ver/Ocultar Contraseña",
                            iconoContr,
                            () => {
                              setState(() {
                                verContr = !verContr;
                                iconoContr = Icons.remove_red_eye_outlined;
                                if (verContr) {
                                  iconoContr = Icons.remove_red_eye_rounded;
                                }
                              }),
                            },
                          ),
                        ),
                      ],
                    ),
                    Botones.iconoTexto(
                      "Ingresar",
                      Icons.login_rounded,
                      () async => {
                        setState(() {
                          colorCont = Color(0x00FFFFFF);
                          colorUsu = Color(0x00FFFFFF);
                        }),
                        verificar(context),
                      },
                    ),
                  ],
                ),
              ),
            ),
            Consumer<Carga>(
              builder: (context, carga, child) {
                return Carga.ventanaCarga();
              },
            ),
            Visibility(
              visible: !kIsWeb,
              child: Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: Botones.btnRctMor(
                  "Ajustes",
                  35,
                  Icons.settings,
                  false,
                  () => {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
