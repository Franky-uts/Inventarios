import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
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
  late UsuarioModel usuarioMod;
  late bool verContr;
  late IconData iconoContr;
  late List<TextEditingController> controller = [];
  late List<FocusNode> focus = [];
  late List<Color> color = [];
  String ip = "189.187.152.236";

  @override
  void initState() {
    if (LocalStorage.local('conexion').isNotEmpty) {
      ip = LocalStorage.local(
        'conexion',
      ).substring(7, LocalStorage.local('conexion').length - 5);
    }
    verContr = true;
    for (int i = 0; i < 6; i++) {
      controller.add(TextEditingController());
      focus.add(FocusNode());
      color.add(Color(0x00FFFFFF));
    }
    setIp();
    iconoContr = Icons.remove_red_eye_rounded;
    super.initState();
  }

  @override
  void dispose() {
    controller.clear();
    focus.clear();
    color.clear();
    super.dispose();
  }

  void verificar(BuildContext ctx) async {
    bool valido = true;
    String mensaje = "";
    for (int i = 0; i < 2; i++) {
      setState(() {
        color[i] = Color(0x00FFFFFF);
      });
      if (controller[i].text.isEmpty) {
        valido = false;
        setState(() {
          color[i] = Color(0xFFFF0000);
        });
      }
    }
    if (valido) {
      context.read<Carga>().cargaBool(true);
      usuarioMod = await UsuarioModel.getUsuario(
        controller[0].text,
        controller[1].text,
        ip,
      );
      mensaje = usuarioMod.puesto;
      if (usuarioMod.nombre != "error") {
        await LocalStorage.set('conexion', "http://$ip:3000");
        //await LocalStorage.set('conexion', "http://192.168.1.130:3000");
        await LocalStorage.set('usuario', usuarioMod.nombre);
        await LocalStorage.set('puesto', usuarioMod.puesto);
        await LocalStorage.set('locación', usuarioMod.locacion);
        mensaje = "";
        if (usuarioMod.puesto == "El usuario no existe") {
          setState(() {
            color[0] = Color(0xFFFF0000);
          });
        } else if (usuarioMod.puesto == "Contraseña incorrecta") {
          setState(() {
            color[1] = Color(0xFFFF0000);
          });
        } else {
          mensaje = "";
          StatefulWidget ruta = Inventario();
          if (usuarioMod.puesto == "Proveedor") {
            ruta = Ordenes();
          }
          if (ctx.mounted) {
            Navigator.pushReplacement(
              ctx,
              MaterialPageRoute(builder: (ctx) => ruta),
            );
          }
        }
      }
      if (mensaje.isNotEmpty) {
        Textos.toast(mensaje, false);
      }
      if (ctx.mounted) {
        ctx.read<Carga>().cargaBool(false);
      }
    }
  }

  void setIp() {
    List<String> texto = ip.split(".");
    for (int i = 0; i < 4; i++) {
      controller[i + 2].text = texto[i];
    }
  }

  void clearColoresIp() {
    for (int i = 0; i < 4; i++) {
      setState(() {
        color[i + 2] = Color(0x00FFFFFF);
      });
    }
  }

  void cambiarIp() {
    bool valido = true;
    String texto = "";
    clearColoresIp();
    for (int i = 0; i < 4; i++) {
      texto = "$texto${controller[i + 2].text}.";
      if (controller[i + 2].text.isEmpty ||
          int.parse(controller[i + 2].text) > 255) {
        valido = false;
        setState(() {
          color[i + 2] = Color(0xFFFF0000);
        });
      }
    }
    if (valido) {
      ip = texto.substring(0, texto.length - 1);
      Textos.toast("Se cambio la ip a: $ip", true);
      setIp();
      context.read<Ventanas>().emergente(false);
    }
  }

  List<Widget> ipCampos() {
    List<Widget> lista = [];
    for (int i = 0; i < 3; i++) {
      lista.add(
        CampoTexto.inputTexto(
          MediaQuery.of(context).size.width * .125,
          null,
          "",
          controller[i + 2],
          color[i + 2],
          true,
          false,
          () => focus[i + 3].requestFocus(),
          focus: focus[i + 2],
          formato: LengthLimitingTextInputFormatter(3),
          inputType: TextInputType.numberWithOptions(),
        ),
      );
      lista.add(Textos.textoTilulo(".", 20));
    }
    lista.add(
      CampoTexto.inputTexto(
        MediaQuery.of(context).size.width * .125,
        null,
        "",
        controller[5],
        color[5],
        true,
        false,
        () => cambiarIp(),
        focus: focus[5],
        formato: LengthLimitingTextInputFormatter(3),
        inputType: TextInputType.numberWithOptions(),
      ),
    );
    return lista;
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
                      controller[0],
                      color[0],
                      true,
                      false,
                      () => focus[1].requestFocus(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * (.75 * .925),
                          Icons.lock_rounded,
                          "Contraseña",
                          controller[1],
                          color[1],
                          true,
                          verContr,
                          () => verificar(context),
                          focus: focus[1],
                        ),
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width * (.75 * .075),
                          child: Botones.btnSimple(
                            "Ver/Ocultar Contraseña",
                            iconoContr,
                            Color(0xFFFFFFFF),
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
                      () => verificar(context),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              alignment: Alignment.topLeft,
              child: Botones.btnRctMor(
                "Ajustes",
                35,
                Icons.settings,
                false,
                () => setState(() {
                  context.read<Ventanas>().emergente(true);
                }),
              ),
            ),
            Ventanas.ventanaEmergente(
              "Cambio de dirección ip",
              "Cancelar",
              "Guardar",
              () => setState(() {
                clearColoresIp();
                setIp();
                context.read<Ventanas>().emergente(false);
              }),
              () => cambiarIp(),
              widget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: ipCampos(),
              ),
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }
}
