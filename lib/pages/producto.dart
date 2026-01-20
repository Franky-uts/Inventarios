import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:provider/provider.dart';

class Producto extends StatefulWidget {
  final ProductoModel productoInfo;
  final StatefulWidget ruta;

  const Producto({super.key, required this.productoInfo, required this.ruta});

  @override
  State<Producto> createState() => _ProductoState();
}

class _ProductoState extends State<Producto> {
  late ProductoModel productoInfo = widget.productoInfo;
  double entr = 0, sali = 0;
  double productosPerdido = 0;
  Timer? timer;
  String texto = '';
  FocusNode focus = FocusNode();
  late final List<Color> color = [
    productoInfo.tipo == 'Granel' ? Color(0x00FFFFFF) : Color(0xFF8A03A9),
    productoInfo.tipo == 'Granel' ? Color(0x00FFFFFF) : Color(0xFF8A03A9),
    Color(0xFF8A03A9),
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
  ];
  List<TextEditingController> controllerPerdidas = [
    TextEditingController(),
    TextEditingController(),
  ];
  List<TextEditingController> controllerGranel = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    productosPerdido = calcularPerdidas(productoInfo.perdidaCantidad);
    super.initState();
  }

  @override
  void dispose() {
    controllerPerdidas.clear();
    controllerGranel.clear();
    timer?.cancel();
    color.clear();
    super.dispose();
  }

  double calcularPerdidas(List<double> lista) {
    double perdida = 0;
    for (int i = 0; i < lista.length; i++) {
      perdida += lista[i];
    }
    return perdida;
  }

  void recarga(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    String mensaje = 'Se actualizó el producto.';
    ProductoModel producto = await ProductoModel.getProducto(productoInfo.id);
    producto.mensaje.isEmpty
        ? {
            setState(() {
              productoInfo = producto;
            }),
          }
        : mensaje = producto.mensaje;
    Textos.toast(mensaje, false);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  Future enviarDatos(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    ProductoModel producto = await ProductoModel.guardarES(
      entr,
      sali,
      productoInfo.id,
    );
    String mensaje = 'No se pudieron guardar los datos';
    if (producto.mensaje.isEmpty) {
      mensaje = 'Cambios realizados con exito';
      setState(() {
        productoInfo.unidades = producto.unidades;
        productoInfo.entrada = producto.entrada;
        productoInfo.salida = producto.salida;
        productoInfo.perdidaRazones = producto.perdidaRazones;
        productoInfo.perdidaCantidad = producto.perdidaCantidad;
        productoInfo.ultimoUsuario = producto.ultimoUsuario;
        productoInfo.ultimaModificacion = producto.ultimaModificacion;
        productosPerdido = calcularPerdidas(producto.perdidaCantidad);
        entr = 0;
        sali = 0;
        color[0] = Color(0xFF8A03A9);
        color[1] = Color(0xFF8A03A9);
      });
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
    Textos.toast(mensaje, true);
  }

  Future enviarDatosGranel(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    double ent, sal;
    String mensaje = 'No hay datos';
    if (!(controllerGranel[0].text.isEmpty &&
        controllerGranel[1].text.isEmpty)) {
      if (controllerGranel[0].text.isEmpty) {
        ent = 0;
      } else {
        ent = double.parse(controllerGranel[0].text);
      }
      if (controllerGranel[1].text.isEmpty) {
        sal = 0;
      } else {
        sal = double.parse(controllerGranel[1].text);
      }
      if (ent < 0) {
        color[0] = Color(0xFFFF0000);
      }
      if (sal < 0) {
        color[1] = Color(0xFFFF0000);
      }
      if (ent >= 0 && sal >= 0) {
        ProductoModel producto = await ProductoModel.guardarES(
          ent,
          sal,
          productoInfo.id,
        );
        mensaje = producto.mensaje;
        if (producto.mensaje.isEmpty) {
          mensaje = 'Cambios realizados con exito';
          setState(() {
            productoInfo.unidades = producto.unidades;
            productoInfo.entrada = producto.entrada;
            productoInfo.salida = producto.salida;
            productoInfo.perdidaRazones = producto.perdidaRazones;
            productoInfo.perdidaCantidad = producto.perdidaCantidad;
            productoInfo.ultimoUsuario = producto.ultimoUsuario;
            productoInfo.ultimaModificacion = producto.ultimaModificacion;
            color[0] = Color(0x00000000);
            color[1] = Color(0x00000000);
            controllerGranel[0].text = '';
            controllerGranel[1].text = '';
          });
        }
      }
    }
    Textos.toast(mensaje, true);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  void cambioValor(int tipo, int valor) {
    Color color = Color(0xFFFF0000);
    switch (tipo) {
      case 0:
        if ((entr + productoInfo.entrada + valor) >= productoInfo.entrada) {
          color = Color(0xFF8A03A9);
          entr += valor;
          if (valor < 0 && productoInfo.unidades + entr - sali < 0) {
            sali += valor;
            if (sali == 0) this.color[1] = Color(0xFF8A03A9);
          }
        }
        if (entr + productoInfo.entrada != productoInfo.entrada) {
          color = Color(0xFF00be00);
        }
        break;
      case 1:
        if ((sali + productoInfo.salida + valor) >= productoInfo.salida) {
          color = Color(0xFF8A03A9);
          if ((productoInfo.unidades + entr - (sali + valor)) >= 0) {
            sali += valor;
          }
          if (sali + productoInfo.salida != productoInfo.salida) {
            color = Color(0xFF00be00);
          }
        }
        break;
    }
    setState(() {
      this.color[tipo] = color;
    });
  }

  void guardarPerdidas(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    bool valido = true;
    for (int i = 0; i < controllerPerdidas.length; i++) {
      setState(() {
        color[i + 3] = Color(0x00FFFFFF);
      });
      if (controllerPerdidas[i].text.isEmpty) {
        valido = false;
        setState(() {
          color[i + 3] = Color(0xFFFF0000);
        });
      }
    }
    if (valido) {
      double perdidas = double.parse(controllerPerdidas[0].text);
      double unidades = double.parse(
        (productoInfo.unidades - (perdidas / productoInfo.cantidadPorUnidad))
            .toStringAsFixed(3),
      );
      String mensaje = 'Error: Las perdidas exceden la cantidad almacenada';
      if (unidades >= 0) {
        ProductoModel producto = await ProductoModel.guardarPerdidas(
          controllerPerdidas[1].text,
          perdidas,
          productoInfo.id,
        );
        if (producto.mensaje.isEmpty) {
          mensaje = (productoInfo.tipo == 'Granel')
              ? 'Se registro la perdida de ${(perdidas / productoInfo.cantidadPorUnidad).toStringAsFixed(3)} kilos'
              : 'Se registro la perdida de ${(perdidas / productoInfo.cantidadPorUnidad).toStringAsFixed(3)} unidades';
          setState(() {
            productosPerdido += perdidas;
            productoInfo.unidades = producto.unidades;
            productoInfo.entrada = producto.entrada;
            productoInfo.salida = producto.salida;
            productoInfo.perdidaRazones = producto.perdidaRazones;
            productoInfo.perdidaCantidad = producto.perdidaCantidad;
            productoInfo.ultimoUsuario = producto.ultimoUsuario;
            productoInfo.ultimaModificacion = producto.ultimaModificacion;
          });
        }
        if (ctx.mounted) {
          ctx.read<Ventanas>().emergente(mensaje.split(':')[0] == 'Error');
          ctx.read<Ventanas>().tabla(mensaje.split(':')[0] != 'Error');
        }
        Textos.toast(mensaje, true);
      }
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  void editarLimite(BuildContext ctx) async {
    if (controllerPerdidas[0].text.isEmpty) {
      setState(() {
        color[3] = Color(0xFFFF0000);
      });
    } else {
      ctx.read<Carga>().cargaBool(true);
      String mensaje = await ProductoModel.editarProducto(
        productoInfo.id,
        controllerPerdidas[0].text,
        'LimiteProd',
      );
      if (mensaje.split(': ')[0] != 'Error') {
        setState(() {
          color[3] = Color(0x00000000);
          productoInfo.limiteProd = double.parse(
            controllerPerdidas[0].text,
          ).floor();
          controllerPerdidas[0].text = '';
        });
        mensaje =
            'Se actualizó el límite de productos del producto con id $mensaje.';
        if (ctx.mounted) {
          ctx.read<Ventanas>().emergente(false);
          ctx.read<Carga>().cargaBool(false);
        }
      }
      Textos.toast(mensaje, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Consumer<Carga>(
              builder: (context, carga, child) {
                String entradas = '${productoInfo.entrada + entr}';
                String salidas = '${productoInfo.salida + sali}';
                String perd = '$productosPerdido';
                return SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Textos.textoTilulo(productoInfo.nombre, 30),
                        tipoTexto(productoInfo.tipo),
                        productoInfo.tipo != 'Granel'
                            ? contenedorInfo(
                                ' que entraron:',
                                (entradas.split('.')[1] == '0')
                                    ? entradas.split('.')[0]
                                    : entradas,
                                0,
                              )
                            : contenedorInfoGranel(
                                ' que entraron:',
                                (entradas.split('.')[1] == '0')
                                    ? entradas.split('.')[0]
                                    : entradas,
                                0,
                              ),
                        productoInfo.tipo != 'Granel'
                            ? contenedorInfo(
                                ' que salieron:',
                                (salidas.split('.')[1] == '0')
                                    ? salidas.split('.')[0]
                                    : salidas,
                                1,
                              )
                            : contenedorInfoGranel(
                                ' que salieron:',
                                (salidas.split('.')[1] == '0')
                                    ? salidas.split('.')[0]
                                    : salidas,
                                1,
                              ),
                        contenedorInfoPerdidas(
                          (perd.split('.')[1] == '0')
                              ? perd.split('.')[0]
                              : perd,
                          2,
                        ),
                        Botones.icoCirMor(
                          'Guardar movimientos',
                          Icons.save_rounded,
                          false,
                          () => productoInfo.tipo != 'Granel'
                              ? enviarDatos(context)
                              : enviarDatosGranel(context),
                          () => Textos.toast('No hay hay cambios.', false),
                          productoInfo.tipo != 'Granel'
                              ? entr > 0 || sali > 0
                              : true,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            footer([
                              'Ultima modificación:',
                              productoInfo.ultimaModificacion,
                            ]),
                            footer([
                              'Modificada por:',
                              productoInfo.ultimoUsuario,
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Botones.layerButton(
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => widget.ruta),
              ),
              recarga: () => recarga(context),
            ),
            Consumer2<Ventanas, VenDatos>(
              builder: (context, ventana, venDatos, child) {
                return Ventanas.ventanaTabla(
                  MediaQuery.of(context).size.height,
                  MediaQuery.of(context).size.width,
                  ['Perdidas: $productosPerdido'],
                  [],
                  (productosPerdido > 0)
                      ? Tablas.contenedorInfo(
                          MediaQuery.sizeOf(context).width,
                          [.05, .15, .6],
                          ['#', 'Cantidad perdida', 'Razón de perdida'],
                        )
                      : Textos.textoTilulo('No hay perdidas registradas.', 30),
                  (productosPerdido > 0)
                      ? ListView.separated(
                          itemCount: productoInfo.perdidaCantidad.length,
                          scrollDirection: Axis.vertical,
                          separatorBuilder: (context, index) => Container(
                            height: 2,
                            decoration: BoxDecoration(color: Color(0xFFFDC930)),
                          ),
                          itemBuilder: (context, index) {
                            String cantidad =
                                '${productoInfo.perdidaCantidad[index]}';
                            return Container(
                              width: MediaQuery.sizeOf(context).width,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                              ),
                              child: Tablas.barraDatos(
                                MediaQuery.sizeOf(context).width,
                                [.05, .15, .6],
                                [
                                  '${index + 1}',
                                  (cantidad.split('.')[1] == '0')
                                      ? cantidad.split('.')[0]
                                      : cantidad,
                                  productoInfo.perdidaRazones[index],
                                ],
                                [],
                                2,
                                false,
                              ),
                            );
                          },
                        )
                      : Botones.btnCirRos(
                          'Agregar perdida',
                          () => {
                            setState(() {
                              controllerPerdidas[0].text = '';
                              controllerPerdidas[1].text = '';
                              color[3] = Color(0x00000000);
                              color[4] = Color(0x00000000);
                            }),
                            ventana.emergente(true),
                            ventana.tabla(false),
                          },
                        ),
                  [
                    Botones.btnCirRos('Cerrar', () => ventana.tabla(false)),
                    if (productosPerdido > 0)
                      Botones.btnCirRos(
                        'Agregar perdida',
                        () => {
                          setState(() {
                            controllerPerdidas[0].text = '';
                            controllerPerdidas[1].text = '';
                            color[3] = Color(0x00000000);
                            color[4] = Color(0x00000000);
                          }),
                          ventana.emergente(true),
                          ventana.tabla(false),
                        },
                      ),
                  ],
                );
              },
            ),
            Consumer3<Ventanas, Carga, Tablas>(
              builder: (context, ventana, carga, tablas, child) {
                return Ventanas.ventanaEmergente(
                  texto,
                  'Volver',
                  'Guardar',
                  () => {
                    ventana.emergente(false),
                    setState(() {
                      color[3] = Color(0x00000000);
                      color[4] = Color(0x00000000);
                    }),
                    ventana.tabla(texto == '¿Cuánto se perdió y por qué?'),
                  },
                  () async => {
                    if (texto == '¿Cuánto se perdió y por qué?')
                      {guardarPerdidas(context)}
                    else
                      {editarLimite(context)},
                  },
                  widget: SingleChildScrollView(
                    child: Column(
                      spacing: 10,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75,
                          Icons.numbers_rounded,
                          'Cantidad',
                          controllerPerdidas[0],
                          color[3],
                          true,
                          false,
                          () => {
                            if (texto == '¿Cuánto se perdió y por qué?')
                              {focus.requestFocus()}
                            else
                              {editarLimite(context)},
                          },
                          formato: FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,3})'),
                          ),
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        if (texto == '¿Cuánto se perdió y por qué?')
                          CampoTexto.inputTexto(
                            MediaQuery.of(context).size.width * .75,
                            Icons.message_rounded,
                            'Razón de la perdida',
                            controllerPerdidas[1],
                            color[4],
                            true,
                            false,
                            () => guardarPerdidas(context),
                            focus: focus,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }

  SizedBox tipoTexto(String tipo) {
    String titulo = '${tipo}s:';
    String cantidad = '';
    if (tipo == 'Granel') {
      titulo = 'Kilos:';
    } else if (tipo == 'Costal') {
      titulo = 'Unidades:';
      cantidad = '${productoInfo.cantidadPorUnidad}';
      if (cantidad.split('.')[1] == '0') cantidad = cantidad.split('.')[0];
      cantidad = 'Kilos por unidad: $cantidad';
    } else if (tipo == 'Bote') {
      titulo = 'Unidades:';
      cantidad = '${productoInfo.cantidadPorUnidad}';
      if (cantidad.split('.')[1] == '0') cantidad = cantidad.split('.')[0];
      cantidad = 'Kilos/Piezas por unidad: $cantidad';
    } else if (tipo == 'Caja' || tipo == 'Bulto' || tipo == 'Paquete') {
      cantidad = '${productoInfo.cantidadPorUnidad}';
      if (cantidad.split('.')[1] == '0') cantidad = cantidad.split('.')[0];
      cantidad = 'Productos por $tipo: $cantidad';
    } else if (tipo == 'Galón') {
      titulo = 'Galones:';
    }
    String unidades = '${productoInfo.unidades + entr - sali}';
    if (unidades.split('.')[1] == '0') unidades = unidades.split('.')[0];
    return SizedBox(
      width: MediaQuery.of(context).size.width * .5,
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Textos.textoGeneral(titulo, 20, true, true, 1),
              if (cantidad.isNotEmpty)
                Textos.textoGeneral(cantidad, 15, false, true, 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Textos.textoGeneral(
                    'Minimo requerido: ${productoInfo.limiteProd}',
                    15,
                    false,
                    true,
                    1,
                  ),
                  SizedBox(
                    height: 40,
                    child: Botones.btnSimple(
                      'Editar limite',
                      Icons.edit_rounded,
                      Color(0xFF8A03A9),
                      () => {
                        context.read<Ventanas>().emergente(true),
                        setState(() {
                          controllerPerdidas[0].text =
                              '${productoInfo.limiteProd}';
                          color[3] = Color(0x00000000);
                          texto = 'Confirma el nuevo límite de productos.';
                        }),
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          Textos.recuadroCantidad(
            unidades,
            Textos.colorLimite(
              productoInfo.limiteProd,
              productoInfo.unidades.floor(),
            ),
            20,
            1,
          ),
        ],
      ),
    );
  }

  SizedBox contenedorInfo(String textoInfo, String textoValor, int valor) {
    String text = '${productoInfo.tipo}s$textoInfo';
    if (productoInfo.tipo == 'Granel') {
      text = 'Unidades$textoInfo';
    } else if (productoInfo.tipo == 'Galón') {
      text = 'Galones$textoInfo';
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * .55,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Textos.textoGeneral(text, 20, true, false, 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onLongPress: () => timer = Timer.periodic(
                  Duration(milliseconds: 150),
                  (timer) => cambioValor(valor, -1),
                ),
                onLongPressEnd: (_) => setState(() {
                  timer?.cancel();
                }),
                child: Botones.btnRctMor(
                  '',
                  0,
                  Icons.remove,
                  false,
                  () => cambioValor(valor, -1),
                ),
              ),
              Textos.recuadroCantidad(textoValor, color[valor], 20, 1),
              GestureDetector(
                onLongPress: () => timer = Timer.periodic(
                  Duration(milliseconds: 150),
                  (timer) => cambioValor(valor, 1),
                ),
                onLongPressEnd: (_) => setState(() {
                  timer?.cancel();
                }),
                child: Botones.btnRctMor(
                  '',
                  0,
                  Icons.add,
                  false,
                  () => cambioValor(valor, 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox contenedorInfoGranel(
    String textoInfo,
    String textoValor,
    int valor,
  ) {
    String text = '${productoInfo.tipo}s$textoInfo';
    if (productoInfo.tipo == 'Granel') {
      text = 'Kilos$textoInfo';
    } else if (productoInfo.tipo == 'Galón') {
      text = 'Galones$textoInfo';
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * .55,
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CampoTexto.inputTexto(
            MediaQuery.sizeOf(context).width * .3575,
            Icons.info_outline_rounded,
            text,
            controllerGranel[valor],
            color[valor],
            true,
            false,
            () => FocusManager.instance.primaryFocus?.unfocus(),
            formato: FilteringTextInputFormatter.allow(
              RegExp(r'(^\d*\.?\d{0,3})'),
            ),
            inputType: TextInputType.numberWithOptions(decimal: true),
            borderColor: Color(0xFF8A03A9),
          ),
          Textos.recuadroCantidad(textoValor, Color(0xFF8A03A9), 20, 1),
        ],
      ),
    );
  }

  SizedBox contenedorInfoPerdidas(String textoValor, int valor) {
    String text = 'Productos perdidos:';
    if (productoInfo.tipo == 'Granel' || productoInfo.tipo == 'Costal') {
      text = 'Kilos perdidos:';
    } else if (productoInfo.tipo == 'Bote') {
      text = 'Gramos/Piezas perdidos:';
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * .55,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Textos.textoGeneral(text, 20, true, false, 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Textos.recuadroCantidad(textoValor, color[valor], 20, 1),
              Botones.btnRctMor(
                texto.split(':')[0],
                0,
                Icons.info_outline_rounded,
                false,
                () => {
                  context.read<Ventanas>().tabla(true),
                  setState(() {
                    texto = '¿Cuánto se perdió y por qué?';
                  }),
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox footer(List<String> textos) {
    List<Widget> lista = [];
    for (int i = 0; i < textos.length; i++) {
      lista.add(Textos.textoGeneral(textos[i], 15, false, false, 1));
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * .35,
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: lista,
      ),
    );
  }
}
