import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
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
  late String barras = articulo.codigoBarras, texto = '', columna = '';
  String tituloVen = '';
  TextEditingController controller = TextEditingController();
  Color color = Color(0x00000000);

  void scanCod(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    barras = await Textos.scan(context);
    if (barras == '-1' || barras.isEmpty) {
      barras = articulo.codigoBarras;
    } else {
      List<ArticulosModel> lista = await ArticulosModel.getArticulos('id', '');
      bool flag = true;
      for (int i = 0; i < lista.length; i++) {
        if (lista[i].codigoBarras == barras) {
          flag = false;
        }
      }
      if (flag) {
        tituloVen = 'Confirmar Código de barras';
        texto = 'Código de barras';
        columna = 'CodigoBarras';
        controller.text = barras;
        if (ctx.mounted) {
          ctx.read<Ventanas>().emergente(true);
        }
      } else {
        Textos.toast('El código ya esta registrado', flag);
      }
    }
    if (ctx.mounted) {
      ctx.read<Carga>().cargaBool(false);
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
        controller.text,
        columna,
      );
      if (mensaje.split(': ')[0] != 'Error') {
        setState(() {
          color = Color(0x00000000);
          switch (columna) {
            case 'CodigoBarras':
              articulo.codigoBarras = barras;
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
    if (codigo.isEmpty) {
      codigo = 'Sin codigo establecido';
    }
    return 'Código de barras: $codigo';
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
                                  20,
                                  true,
                                  true,
                                  1,
                                ),
                              ),
                              Botones.btnRctMor(
                                'Materia Prima',
                                20,
                                articulo.materia
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                false,
                                () => {},
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
                                () => scanCod(context),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              rectanguloContainer(
                                ('${articulo.precio}'.split('')[1] ==
                                        '0')
                                    ? 'Precio: ${articulo.precio}'.split(
                                        '.',
                                      )[0]
                                    : 'Precio: ${articulo.precio}',
                              ),
                              Botones.btnSimple(
                                'Cambiar precio',
                                Icons.price_change_rounded,
                                Color(0xFF8A03A9),
                                () => {
                                  tituloVen = 'Editar precio',
                                  texto =
                                      ('${articulo.precio}'.split(
                                            '',
                                          )[1] ==
                                          '0')
                                      ? '${articulo.precio}'.split(
                                          '.',
                                        )[0]
                                      : '${articulo.precio}',
                                  columna = 'Precio',
                                  controller.text = texto,
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
                                () => ProductoModel.getDatosArticulo(
                                  articulo.id,
                                ),
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
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Articulos()),
              ),
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
                    Icons.mode_edit_outline_rounded,
                    texto,
                    controller,
                    color,
                    texto != 'Código de barras',
                    false,
                    () => cambioColumna(context),
                    formato: FilteringTextInputFormatter.allow(
                      RegExp(r'(^\d*\.?\d{0,3})'),
                    ),
                    inputType: TextInputType.numberWithOptions(decimal: true),
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
        for (int i = 0; i < 7; i++) {
          colores.add(Colors.transparent);
        }
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
              (unidad.split('.')[1] == '0') ? unidad.split('.')[0] : unidad,
              (entrada.split('.')[1] == '0') ? entrada.split('.')[0] : entrada,
              (salida.split('.')[1] == '0') ? salida.split('.')[0] : salida,
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
    if (texto.split('.')[1] == '0') texto = texto.split('.')[0];
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
      child: Textos.textoGeneral(texto, 20, true, true, 1),
    );
  }
}
