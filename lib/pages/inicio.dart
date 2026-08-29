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

//Esta es la página login encargada de validar la información del usuario,
//consulta con la base de datos y regresa un mensaje de error, se le informará
//al usuario y se le permitirá volver a ingresar información válida; o regresa
//un usuario relacionado con la información dada, si este es el caso entonces
//se le dará acceso a las demás funciones de la aplicación.
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

  //Este método se encarga de verificar la información ingresada, si se dejó un
  //campo vacío o tiene información inválida se resaltara el borde del campo de
  //texto en rojo, dando a entender que el campo en rojo tiene un problema, si
  //la información es válida se enviara una petición al servidor, si la
  //respuesta tiene un error se mostrara el error en forma de toast, en caso de
  //que regrese la información de un usuario válido este cambiara la página a
  //una correspondiente al puesto del usuario.
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
      if (mensaje.isNotEmpty) Textos.toast(mensaje);
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
                          password: verContr,
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
