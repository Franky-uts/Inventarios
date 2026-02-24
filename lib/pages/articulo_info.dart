import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/articulos_model.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/articulos.dart';
import 'package:provider/provider.dart';

class ArticuloInfo extends StatefulWidget {
  final ArticulosModel articulo;

  const ArticuloInfo({super.key, required this.articulo});

  @override
  State<ArticuloInfo> createState() => _ArticuloInfoState();
}

class _ArticuloInfoState extends State<ArticuloInfo> {
  late ArticulosModel articulo = widget.articulo;
  late String texto = '', columna = '';
  String tituloVen = '';
  TextEditingController controller = TextEditingController();
  Color color = Color(0x00000000);

  void iniciarScan(BuildContext ctx) async {
    if (kIsWeb) {
      ctx.read<Ventanas>().scan(true);
    } else {
      ctx.read<Carga>().cargaBool(true);
      String respuesta = await Textos.scan(context);
      if (ctx.mounted) scanCod(ctx, respuesta);
    }
  }

  void scanCod(BuildContext ctx, String texto) async {
    if (texto == '-1' || texto.isEmpty) {
      texto = articulo.codigoBarras;
    } else {
      List<ArticulosModel> lista = await ArticulosModel.getArticulos('id', '');
      bool flag = true;
      for (ArticulosModel articulo in lista) {
        if (articulo.codigoBarras == texto) flag = false;
      }
      if (flag) {
        tituloVen = 'Confirmar Código de barras';
        this.texto = 'Código de barras';
        columna = 'CodigoBarras';
        controller.text = texto;
        if (ctx.mounted) {
          (kIsWeb)
              ? {cambioColumna(ctx)}
              : {
                  ctx.read<Ventanas>().emergente(true),
                  ctx.read<Carga>().cargaBool(false),
                };
        }
      } else {
        Textos.toast('El código ya esta registrado', flag);
      }
    }
  }

  void cambioColumna(BuildContext ctx) async {
    if (controller.text.isEmpty) {
      setState(() {
        color = Color(0xFFFF0000);
      });
    } else {
      ctx.read<Carga>().cargaBool(true);
      String mensaje = await ArticulosModel.editarArticulo(
        articulo.id,
        "'${controller.text}'",
        columna,
      );
      if (mensaje.split(': ')[0] != 'Error') {
        setState(() {
          color = Color(0x00000000);
          switch (columna) {
            case 'CodigoBarras':
              articulo.codigoBarras = controller.text;
              mensaje = 'Se actualizó el código de barras de $mensaje.';
              break;
            case 'CantidadPorUnidad':
              articulo.cantidadPorUnidad = double.parse(controller.text);
              mensaje =
                  'Se actualizó la cantidad de productos por unidad de $mensaje.';
              break;
            case 'Precio':
              articulo.precio = double.parse(controller.text);
              mensaje = 'Se actualizó el precio de $mensaje.';
              break;
          }
        });
      }
      Textos.toast(mensaje, true);
      if (ctx.mounted) {
        ctx.read<Ventanas>().emergente(false);
        ctx.read<Carga>().cargaBool(false);
      }
    }
  }

  void recarga(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    String mensaje = 'Se actualizó el articulo.';
    ArticulosModel articulo = await ArticulosModel.getArticulo(
      this.articulo.id,
    );
    articulo.mensaje.isEmpty
        ? {
            setState(() {
              this.articulo = articulo;
            }),
          }
        : mensaje = articulo.mensaje;

    Textos.toast(mensaje, false);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  String codigoTexto(String codigo) {
    (codigo.isEmpty)
        ? codigo = 'Sin codigo establecido'
        : codigo = 'Código de barras: $codigo';
    return codigo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Textos.textoTilulo(articulo.nombre, 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        spacing: 20,
                        children: [
                          rectanguloContainer('Área: ${articulo.area}'),
                          rectanguloContainer('Tipo: ${articulo.tipo}'),
                          rowBoton(),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0x59F6AFCF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Textos.textoGeneral(
                                  'Materia prima:',
                                  true,
                                  1,
                                  size: 20,
                                  alignment: TextAlign.center,
                                ),
                              ),
                              Botones.btnRctMor(
                                'Materia Prima',
                                articulo.materia
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                false,
                                () => {},
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              rectanguloContainer(
                                codigoTexto(articulo.codigoBarras),
                              ),
                              Botones.btnSimple(
                                'Cambiar Código de barras',
                                Icons.edit_note_rounded,
                                Color(0xFF8A03A9),
                                () => iniciarScan(context),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              rectanguloContainer(
                                ('${articulo.precio}'.split('')[1] == '0')
                                    ? 'Precio: ${articulo.precio}'.split('.')[0]
                                    : 'Precio: ${articulo.precio}',
                              ),
                              Botones.btnSimple(
                                'Cambiar precio',
                                Icons.price_change_rounded,
                                Color(0xFF8A03A9),
                                () => {
                                  tituloVen = 'Editar precio',
                                  texto = '',
                                  columna = 'Precio',
                                  controller.text =
                                      ('${articulo.precio}'.split('')[1] == '0')
                                      ? '${articulo.precio}'.split('.')[0]
                                      : '${articulo.precio}',
                                  context.read<Ventanas>().emergente(true),
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tablas.contenedorInfo(
                          MediaQuery.sizeOf(context).width,
                          [0.2, 0.075, 0.075, 0.075, 0.075, 0.2, 0.25],
                          [
                            'Tienda',
                            'Unidades',
                            'Entradas',
                            'Salidas',
                            'Perdidas',
                            'Ultimo usuario',
                            'Ultima modificación',
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 185,
                          child: Consumer<Tablas>(
                            builder: (context, tablas, child) {
                              return Tablas.listaFutura(
                                listaPrincipal,
                                'No hay productos registrados.',
                                'No hay coincidencias.',
                                () =>
                                    ProductoModel.getDatosArticulo(articulo.id),
                                accionRefresh: () async => tablas.datos(
                                  await ProductoModel.getDatosArticulo(
                                    articulo.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Botones.layerButton(
              () => RecDrawer.pushAnim(Articulos(), context),
              recarga: () => recarga(context),
            ),
            Consumer2<Ventanas, Carga>(
              builder: (context, ventana, carga, child) {
                return Ventanas.ventanaEmergente(
                  tituloVen,
                  'Cancelar',
                  'Confirmar',
                  () => setState(() {
                    color = Color(0x00000000);
                    ventana.emergente(false);
                  }),
                  () => cambioColumna(context),
                  widget: CampoTexto.inputTexto(
                    MediaQuery.of(context).size.width * .75,
                    texto,
                    controller,
                    color,
                    texto != 'Código de barras',
                    false,
                    () => cambioColumna(context),
                    icono: Icons.mode_edit_outline_rounded,
                    formato: FilteringTextInputFormatter.allow(
                      RegExp(r'(^\d*\.?\d{0,3})'),
                    ),
                    inputType: TextInputType.numberWithOptions(decimal: true),
                  ),
                );
              },
            ),
            Consumer2<Ventanas, Carga>(
              builder: (context, ventanas, carga, child) {
                return Ventanas.ventanaScan(
                  context,
                  (texto) => scanCod(context, texto),
                );
              },
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }

  ListView listaPrincipal(List lista) {
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        List<Color> colores = [];
        colores = List.filled(7, Colors.transparent);
        colores[1] = Textos.colorLimite(
          lista[index].limiteProd,
          lista[index].unidades.floor(),
        );
        String unidad = '${lista[index].unidades}';
        String entrada = '${lista[index].entrada}';
        String salida = '${lista[index].salida}';
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [0.2, 0.075, 0.075, 0.075, 0.075, 0.2, 0.25],
            [
              lista[index].nombre,
              (unidad.split('.').length > 1)
                  ? (unidad.split('.')[1] == '0')
                        ? unidad.split('.')[0]
                        : unidad
                  : unidad,
              (entrada.split('.').length > 1)
                  ? (entrada.split('.')[1] == '0')
                        ? entrada.split('.')[0]
                        : entrada
                  : entrada,
              (salida.split('.').length > 1)
                  ? (salida.split('.')[1] == '0')
                        ? salida.split('.')[0]
                        : salida
                  : salida,
              '${lista[index].perdidaCantidad.length}',
              lista[index].ultimoUsuario,
              lista[index].ultimaModificacion,
            ],
            colores,
            2,
            true,
            extra: () => {},
            extraWid: Text(lista[index].mensaje),
          ),
        );
      },
    );
  }

  Row rowBoton() {
    String texto = '${articulo.cantidadPorUnidad}';
    if (texto.split('.').length > 1) {
      if (texto.split('.')[1] == '0') texto = texto.split('.')[0];
    }
    return Row(
      children: [
        rectanguloContainer('Cantidad por unidad: $texto'),
        if (articulo.tipo == 'Bote' ||
            articulo.tipo == 'Bulto' ||
            articulo.tipo == 'Caja' ||
            articulo.tipo == 'Costal' ||
            articulo.tipo == 'Paquete')
          Botones.btnSimple(
            'Cambiar cantidad por unidad',
            Icons.edit_rounded,
            Color(0xFF8A03A9),
            () => {
              tituloVen = 'Editar cantidad por unidad',
              texto = 'Cantidad por unidad',
              columna = 'CantidadPorUnidad',
              controller.text = '${articulo.cantidadPorUnidad}',
              context.read<Ventanas>().emergente(true),
            },
          ),
      ],
    );
  }

  Container rectanguloContainer(String texto) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Color(0x59F6AFCF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Textos.textoGeneral(
        texto,
        true,
        1,
        size: 20,
        alignment: TextAlign.center,
      ),
    );
  }
}
