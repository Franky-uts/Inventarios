import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/inventario_prod.dart';
import 'package:provider/provider.dart';

class PerdidasProv extends StatefulWidget {
  final ProductoModel productoInfo;

  const PerdidasProv({super.key, required this.productoInfo});

  @override
  State<PerdidasProv> createState() => _PerdidasProvState();
}

class _PerdidasProvState extends State<PerdidasProv> {
  late ProductoModel productoInfo = widget.productoInfo;
  double productosPerdido = 0;
  FocusNode focus = FocusNode();
  List<Color> colores = [Color(0x00000000), Color(0x00000000)];
  List<TextEditingController> controller = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    for (double perdida in productoInfo.perdidaCantidad) {
      productosPerdido += perdida;
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void guardarPerdidas(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    setState(() {
      List.filled(2, Color(0x00FFFFFF));
    });
    if (controller[0].text.isEmpty) {
      setState(() {
        colores[0] = Color(0xFFFF0000);
      });
    }
    if (controller[1].text.isEmpty) {
      setState(() {
        colores[1] = Color(0xFFFF0000);
      });
    }
    if (controller[1].text.isNotEmpty || controller[1].text.isNotEmpty) {
      double perdidas = double.parse(controller[0].text);
      double unidades = double.parse(
        (perdidas / productoInfo.cantidadPorUnidad).toStringAsFixed(3),
      );
      String mensaje = 'Error: Las perdidas exceden la cantidad almacenada';
      if (productoInfo.unidades - unidades >= 0) {
        mensaje = await ProductoModel.guardarPerdidas(
          controller[1].text,
          perdidas,
          productoInfo.id,
        );
        if (mensaje.split(": ")[0] != 'Error') {
          ProductoModel producto = await ProductoModel.getProducto(
            productoInfo.id,
          );
          (producto.mensaje.isEmpty)
              ? setState(() {
                  productosPerdido += perdidas;
                  productoInfo = producto;
                })
              : mensaje =
                    'Se guardó la información, pero no se pudo actualizar el producto';
        }
      }
      if (ctx.mounted) {
        ctx.read<Ventanas>().emergente(mensaje.split(':')[0] == 'Error');
        ctx.read<Ventanas>().tabla(mensaje.split(':')[0] != 'Error');
      }
      Textos.toast(mensaje, true);
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
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
                return SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * .5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Textos.textoTilulo(productoInfo.nombre, 30),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .5,
                                height: 40,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Textos.textoGeneral(
                                      'Área: ${productoInfo.area}',
                                      true,
                                      1,
                                      size: 20,
                                      alignment: TextAlign.center,
                                    ),
                                    Textos.textoGeneral(
                                      '${productoInfo.tipo}:',
                                      true,
                                      1,
                                      size: 20,
                                      alignment: TextAlign.center,
                                    ),
                                    Textos.recuadroCantidad(
                                      ('${productoInfo.unidades}'.split(
                                                '.',
                                              )[1] ==
                                              '0')
                                          ? '${productoInfo.unidades}'.split(
                                              '.',
                                            )[0]
                                          : '${productoInfo.unidades}',
                                      Textos.colorLimite(
                                        productoInfo.limiteProd,
                                        productoInfo.unidades.floor(),
                                      ),
                                      1,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Botones.btnCirRos(
                                    'Agregar perdida',
                                    () => {
                                      setState(() {
                                        controller[0].text = '';
                                        controller[1].text = '';
                                        colores[0] = Color(0x00000000);
                                        colores[1] = Color(0x00000000);
                                      }),
                                      context.read<Ventanas>().emergente(true),
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * .5,
                          child: Column(
                            children: [
                              (productosPerdido > 0)
                                  ? Tablas.contenedorInfo(
                                      MediaQuery.sizeOf(context).width,
                                      [.05, .15, .6],
                                      [
                                        '#',
                                        'Cantidad perdida',
                                        'Razón de perdida',
                                      ],
                                    )
                                  : Textos.textoTilulo(
                                      'Perdidas: $productosPerdido',
                                      20,
                                    ),
                              if (productosPerdido > 0)
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * .475,
                                  child: ListView.separated(
                                    itemCount:
                                        productoInfo.perdidaCantidad.length,
                                    scrollDirection: Axis.vertical,
                                    separatorBuilder: (context, index) =>
                                        Container(
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFDC930),
                                          ),
                                        ),
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: MediaQuery.sizeOf(context).width,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                        ),
                                        child: Tablas.barraDatos(
                                          MediaQuery.sizeOf(context).width,
                                          [.05, .15, .6],
                                          [
                                            '${index + 1}',
                                            '${productoInfo.perdidaCantidad[index]}',
                                            productoInfo.perdidaRazones[index],
                                          ],
                                          [],
                                          1,
                                          false,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
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
                MaterialPageRoute(builder: (context) => InventarioProd()),
              ),
              recarga: () => recarga(context),
            ),
            Consumer3<Ventanas, Carga, Tablas>(
              builder: (context, ventana, carga, tablas, child) {
                return Ventanas.ventanaEmergente(
                  '¿Cuánto se perdió y por qué?',
                  'Volver',
                  'Guardar',
                  () => ventana.emergente(false),
                  () async => guardarPerdidas(context),
                  widget: SingleChildScrollView(
                    child: Column(
                      spacing: 10,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75,
                          'Cantidad',
                          controller[0],
                          colores[0],
                          true,
                          false,
                          () => focus.requestFocus(),
                          icono: Icons.numbers_rounded,
                          formato: FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,3})'),
                          ),
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75,
                          'Razón de la perdida',
                          controller[1],
                          colores[1],
                          true,
                          false,
                          () => guardarPerdidas(context),
                          icono: Icons.message_rounded,
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
}
