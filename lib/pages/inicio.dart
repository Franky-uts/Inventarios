import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/views/empleado.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:inventarios/views/productor.dart';
import 'package:inventarios/views/proveedor.dart';
import 'package:provider/provider.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  late UsuarioModel usuarioMod;
  bool verContr = true;
  late List<TextEditingController> controller = [
    TextEditingController(),
    TextEditingController(),
  ];
  late FocusNode focus = FocusNode();
  late List<Color> color = [Color(0x00FFFFFF), Color(0x00FFFFFF)];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.clear();
    color.clear();
    super.dispose();
  }

  void verificar(BuildContext ctx) async {
    String mensaje = '';
    setState(() {
      color.addAll(List.filled(2, Color(0x00FFFFFF)));
    });
    if (controller[0].text.isEmpty) {
      setState(() {
        color[0] = Color(0xFFFF0000);
      });
    }
    if (controller[1].text.isEmpty) {
      setState(() {
        color[1] = Color(0xFFFF0000);
      });
    }
    if (controller[0].text.isNotEmpty && controller[1].text.isNotEmpty) {
      ctx.read<Carga>().cargaBool(true);
      usuarioMod = await UsuarioModel.getUsuario(
        controller[0].text,
        controller[1].text,
      );
      mensaje = usuarioMod.puesto;
      if (usuarioMod.nombre != 'error') {
        mensaje = '';
        if (usuarioMod.puesto == 'El usuario no existe') {
          setState(() {
            color[0] = Color(0xFFFF0000);
          });
        } else if (usuarioMod.puesto == 'Contraseña incorrecta') {
          setState(() {
            color[1] = Color(0xFFFF0000);
          });
        } else {
          mensaje = '';
          await LocalStorage.set('usuario', usuarioMod.nombre);
          await LocalStorage.set('puesto', usuarioMod.puesto);
          await LocalStorage.set('locación', usuarioMod.locacion);
          StatefulWidget ruta = Empleado(index: 0);
          switch (usuarioMod.puesto) {
            case ('Proveedor'):
              ruta = Proveedor(index: 0);
              break;
            case ('Producción'):
              ruta = Productor(index: 0);
              break;
          }
          if (ctx.mounted) {
            ctx.read<Ventanas>().setInventario(usuarioMod.locacion);
            Navigator.of(ctx).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => ruta,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.ease)),
                        ),
                        child: child,
                      );
                    },
              ),
            );
          }
        }
      }
      if (mensaje.isNotEmpty) Textos.toast(mensaje, false);
      if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
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
                      'Usuario',
                      '',
                      controller[0],
                      true,
                      false,
                      accion: () => focus.requestFocus(),
                      icono: Icons.person_rounded,
                      errorColor: color[0],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * (.75 * .925),
                          'Contraseña',
                          '',
                          controller[1],
                          true,
                          verContr,
                          accion: () => verificar(context),
                          icono: Icons.lock_rounded,
                          errorColor: color[1],
                          focus: focus,
                        ),
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width * (.75 * .075),
                          child: Botones.btnSimple(
                            'Ver/Ocultar Contraseña',
                            verContr
                                ? Icons.remove_red_eye_rounded
                                : Icons.remove_red_eye_outlined,
                            Color(0xFFFFFFFF),
                            () => {
                              setState(() {
                                verContr = !verContr;
                              }),
                            },
                          ),
                        ),
                      ],
                    ),
                    Botones.iconoTexto(
                      'Ingresar',
                      Icons.login_rounded,
                      () => verificar(context),
                    ),
                  ],
                ),
              ),
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }
}
