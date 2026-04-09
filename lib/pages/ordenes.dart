import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/botones.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import '../models/orden_model.dart';

class Ordenes extends StatefulWidget {
  const Ordenes({super.key});

  @override
  State<Ordenes> createState() => _OrdenesState();
}

class _OrdenesState extends State<Ordenes> {
  List<Color> colores = [
    Color(0xFF8A03A9),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
  ];
  List<bool> filtros = List.filled(6, true, growable: true);
  List canCubOrg = [];
  List<TextEditingController> cantidades = [];
  TextEditingController controller = TextEditingController();
  String filtro = 'id', accion = '';
  int id = 0, venNum = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    colores.clear();
    controller.dispose();
    super.dispose();
  }

  Future<List<OrdenModel>> getOrdenes() async =>
      await OrdenModel.getAllOrdenes(filtro, filtros);

  Future<void> getOrdenInfo(BuildContext ctx, int id) async {
    ctx.read<Carga>().cargaBool(true);
    OrdenModel orden = await OrdenModel.getOrden(id);
    if (orden.mensaje.isEmpty) {
      Textos.limpiarLista();
      if (ctx.mounted) {
        canCubOrg.clear();
        ctx.read<VenDatos>().setDatos(orden);
        Textos.crearLista(orden.cantArticulos, Color(0xFF8A03A9));
        canCubOrg.addAll(ctx.read<VenDatos>().canCubLista());
        cantidades.clear();
        for (int i = 0; i < orden.cantArticulos; i++) {
          String cantidadCub = '${ctx.read<VenDatos>().canCub(i)}';
          if (cantidadCub.split('.').length > 1) {
            if (cantidadCub.split('.')[1] == '0') {
              cantidadCub = cantidadCub.split('.')[0];
            }
          }
          cantidades.add(TextEditingController(text: cantidadCub));
        }
        ctx.read<Ventanas>().tabla(true);
      }
    } else {
      Textos.toast(orden.mensaje, true);
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  void cambiarEstado(String accion) {
    venNum = 0;
    this.accion = accion;
    context.read<Ventanas>().emergente(true);
  }

  void guardar(List lista) {
    bool guardar = false;
    for (int i = 0; i < canCubOrg.length; i++) {
      if (!guardar) guardar = (lista[i] != canCubOrg[i]);
    }
    guardar ? cambiarEstado('guardar') : Textos.toast('No hay cambios', true);
  }

  void verComentarios(
    String nombre,
    String estado,
    String comTienda,
    String comProv,
    String comFin,
  ) {
    accion = 'confirmar';
    controller.text = (estado == 'En proceso')
        ? (comProv == 'Sin comentarios')
              ? ''
              : comProv
        : comProv;
    context.read<Ventanas>().emergente(true);
  }

  Future<String> guardarDatos(BuildContext ctx) async {
    String columna = 'Estado';
    String datos = accion;
    List listaDatos = [];
    ctx.read<VenDatos>().ordenarPor(false);
    switch (accion) {
      case ('guardar'):
        columna = 'CantidadesCubiertas';
        datos = 'Array${ctx.read<VenDatos>().canCubLista()}';
        break;
      case ('entregar'):
        datos = "'Entregado'";
        break;
      case ('denegar'):
        datos = "'Denegado'";
        break;
      case ('confirmar'):
        if (controller.text != ctx.read<VenDatos>().comProv(id)) {
          columna = 'ComentariosProveedor';
          ctx.read<VenDatos>().setComProv(id, controller.text);
          for (int i = 0; i < ctx.read<VenDatos>().length(); i++) {
            String texto = "'${ctx.read<VenDatos>().comProv(i)}'";
            if (ctx.read<VenDatos>().comProv(i).isEmpty) {
              texto = "'Sin comentarios'";
            }
            listaDatos.add(texto);
          }
          datos = 'Array$listaDatos';
        }
        break;
    }
    (datos != 'confirmar')
        ? {
            datos = await OrdenModel.editarOrden(
              ctx.read<VenDatos>().id(),
              columna,
              datos,
            ),
            if (ctx.mounted)
              ctx.read<Tablas>().datos(
                await OrdenModel.getAllOrdenes(filtro, filtros),
              ),
          }
        : datos = 'No hay cambios';
    if ((accion == 'guardar' ||
        (accion == 'confirmar' && datos != 'confirmar'))) {
      (datos.split(': ')[0] != 'Error')
          ? {
              if (columna == 'CantidadesCubiertas')
                {
                  canCubOrg.clear(),
                  if (ctx.mounted)
                    for (double valor in ctx.read<VenDatos>().canCubLista())
                      canCubOrg.add(valor),
                },
            }
          : datos = datos.split(': ')[1];
    }
    if (ctx.mounted) {
      ctx.read<VenDatos>().ordenarPor(true);
      if (accion == 'entregar') {
        accion = 'guardar';
        datos = await guardarDatos(ctx);
        accion = 'entregar';
      }
    }
    return datos;
  }

  void imprimir(
    BuildContext ctx,
    List<String> tituloTexto,
    OrdenModel orden,
  ) async {
    ctx.read<Carga>().cargaBool(true);
    PdfPageFormat formato = PdfPageFormat.standard;
    final doc = pw.Document();
    List<pw.Widget> titulos = [];
    List<pw.Widget> listaArticulos = [];
    for (String titulo in tituloTexto) {
      titulos.add(
        pw.Text(
          titulo,
          textAlign: pw.TextAlign.center,
          maxLines: 2,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      );
    }
    for (int i = 0; i < orden.cantArticulos; i++) {
      listaArticulos.add(
        pw.Column(
          children: [
            pw.Divider(height: 1, thickness: 1),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: formato.availableWidth * .4,
                  child: pw.Text(
                    orden.articulos[i],
                    textAlign: pw.TextAlign.start,
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Container(
                  width: formato.availableWidth * .175,
                  child: pw.Text(
                    orden.tipos[i],
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Container(
                  width: formato.availableWidth * .2,
                  child: pw.Text(
                    orden.areas[i],
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Container(
                  width: formato.availableWidth * .1,
                  child: pw.Text(
                    '${orden.cantidades[i]}',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Container(
                  width: formato.availableWidth * .1,
                  child: pw.Text(
                    '[      ]',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      if (orden.comentariosTienda[i] != 'Sin comentarios') {
        listaArticulos.add(
          pw.Container(
            width: formato.availableWidth * .9,
            child: pw.Text(
              'Comentario: ${orden.comentariosTienda[i]}',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 10),
            ),
          ),
        );
      }
    }
    int cantPag =
        ((listaArticulos.length - (listaArticulos.length / 55).floor() * 55) >
            50)
        ? (listaArticulos.length / 55).ceil() + 1
        : (listaArticulos.length / 55).ceil();
    for (int i = 0; i < (orden.cantArticulos / 55).ceil(); i++) {
      doc.addPage(
        pw.Page(
          pageFormat: formato,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Container(
                  width: formato.availableWidth,
                  alignment: pw.Alignment.topCenter,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: titulos,
                      ),
                      pw.Column(
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.only(bottom: 5),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColor(0, 0, 0),
                                      width: .5,
                                    ),
                                  ),
                                  width: formato.availableWidth * .4,
                                  child: pw.Text(
                                    'Nombre del articulo',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(fontSize: 10),
                                  ),
                                ),
                                pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColor(0, 0, 0),
                                      width: .5,
                                    ),
                                  ),
                                  width: formato.availableWidth * .175,
                                  child: pw.Text(
                                    'Tipo',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(fontSize: 10),
                                  ),
                                ),
                                pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColor(0, 0, 0),
                                      width: .5,
                                    ),
                                  ),
                                  width: formato.availableWidth * .2,
                                  child: pw.Text(
                                    'Área',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(fontSize: 10),
                                  ),
                                ),
                                pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColor(0, 0, 0),
                                      width: .5,
                                    ),
                                  ),
                                  width: formato.availableWidth * .1,
                                  child: pw.Text(
                                    'Cantidad',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(fontSize: 10),
                                  ),
                                ),
                                pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColor(0, 0, 0),
                                      width: .5,
                                    ),
                                  ),
                                  width: formato.availableWidth * .1,
                                  child: pw.Text(
                                    'Conf.',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Column(
                            children: listaArticulos.sublist(
                              i * 55,
                              (i != (listaArticulos.length / 55).ceil() - 1)
                                  ? ((i + 1) * 55)
                                  : listaArticulos.length,
                            ),
                          ),
                        ],
                      ),
                      if (i == (listaArticulos.length / 55).ceil() - 1)
                        pw.Container(
                          padding: pw.EdgeInsets.only(top: 50),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                            children: [
                              pw.Column(
                                children: [
                                  pw.Text(
                                    '____________________________________',
                                    textAlign: pw.TextAlign.center,
                                    maxLines: 1,
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Text(
                                    'Almacen',
                                    textAlign: pw.TextAlign.center,
                                    maxLines: 2,
                                    style: pw.TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              pw.Column(
                                children: [
                                  pw.Text(
                                    '____________________________________',
                                    textAlign: pw.TextAlign.center,
                                    maxLines: 1,
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Text(
                                    'Empleado',
                                    textAlign: pw.TextAlign.center,
                                    maxLines: 1,
                                    style: pw.TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                pw.Container(
                  width: formato.availableWidth,
                  height: formato.availableHeight,
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Text(
                    '${i + 1} de $cantPag',
                    textAlign: pw.TextAlign.end,
                    maxLines: 1,
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
    if ((listaArticulos.length - (listaArticulos.length / 55).floor() * 55) >
        50) {
      doc.addPage(
        pw.Page(
          pageFormat: formato,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Container(
                  padding: pw.EdgeInsets.only(top: 30),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text(
                            '____________________________________',
                            textAlign: pw.TextAlign.center,
                            maxLines: 1,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Almacen',
                            textAlign: pw.TextAlign.center,
                            maxLines: 2,
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(
                            '____________________________________',
                            textAlign: pw.TextAlign.center,
                            maxLines: 1,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Empleado',
                            textAlign: pw.TextAlign.center,
                            maxLines: 1,
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  width: formato.availableWidth,
                  height: formato.availableHeight,
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Text(
                    '$cantPag de $cantPag',
                    textAlign: pw.TextAlign.end,
                    maxLines: 1,
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    ).whenComplete(() {
      if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
    });
  }

  Future<void> filtroTexto(int valor) async {
    colores = List.filled(colores.length, Color(0xFFFFFFFF));
    colores[valor] = Color(0xFF8A03A9);
    switch (valor) {
      case (0):
        filtro = 'id';
      case (1):
        filtro = 'Estado';
      case (2):
        filtro = 'Remitente';
      case (3):
        filtro = 'Locacion';
    }
    context.read<Tablas>().datos(await getOrdenes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: RecDrawer.drawer(context, []),
      backgroundColor: Color(0xFFFF5600),
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    opciones(context),
                    Column(
                      children: [
                        Tablas.contenedorInfo(
                          MediaQuery.sizeOf(context).width,
                          [.05, .125, .15, .2, .2, .25],
                          [
                            'id',
                            'Art. ordenados',
                            'Estado',
                            'Remitente',
                            'Locacion',
                            'Ordenado el:',
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 143.5,
                          child: Consumer<Tablas>(
                            builder: (context, tablas, child) {
                              return Tablas.listaFutura(
                                listaPrincipal,
                                'Todo está en orden, no hay órdenes entrantes.',
                                'No se recuperaron órdenes.',
                                () => getOrdenes(),
                                accionRefresh: () async =>
                                    tablas.datos(await getOrdenes()),
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
            Consumer2<Ventanas, VenDatos>(
              builder: (context, ventana, venDatos, child) {
                String area = '';
                double cantDiv = 0;
                for (int i = 0; i < venDatos.length(); i++) {
                  if (area != venDatos.are(i)) {
                    venDatos.setMen(i, venDatos.are(i));
                    area = venDatos.are(i);
                    cantDiv += 1;
                  }
                }
                return Ventanas.ventanaTabla(
                  (venDatos.length() * 44 + cantDiv * 17.5 + 160 <
                          MediaQuery.sizeOf(context).height)
                      ? venDatos.length() * 44 + cantDiv * 17.5 + 160
                      : MediaQuery.sizeOf(context).height,
                  MediaQuery.of(context).size.width,
                  [
                    'Id de la orden: ${venDatos.id()}',
                    'Estado: ${venDatos.est()}',
                  ],
                  Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.1, .25, .1, .125, .1, .1, .045, .045],
                    [
                      'id',
                      'Nombre del articulo',
                      'Tipo',
                      'Área',
                      'Cant. orden',
                      'Cant. cubierta',
                      '💬',
                      '☑️',
                    ],
                  ),
                  SizedBox(
                    height:
                        (venDatos.length() * 44 + cantDiv * 17.5 <
                            MediaQuery.sizeOf(context).height - 250)
                        ? venDatos.length() * 44 + cantDiv * 17.5
                        : MediaQuery.sizeOf(context).height - 250,
                    child: ListView.separated(
                      itemCount: venDatos.length(),
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) => Container(
                        height: 2,
                        decoration: BoxDecoration(color: Color(0xFFFDC930)),
                      ),
                      itemBuilder: (context, index) {
                        String cantidad = '${venDatos.can(index)}';
                        String cantidadCub = '${venDatos.canCub(index)}';
                        if (cantidad.split('.').length > 1) {
                          if (cantidad.split('.')[1] == '0') {
                            cantidad = cantidad.split('.')[0];
                          }
                        }
                        if (cantidadCub.split('.').length > 1) {
                          if (cantidadCub.split('.')[1] == '0') {
                            cantidadCub = cantidadCub.split('.')[0];
                          }
                        }
                        Widget data = Tablas.barraDatos(
                          MediaQuery.sizeOf(context).width,
                          [.1, .25, .1, .125, .1, .1, .045, .045],
                          [
                            '${venDatos.idArt(index)}',
                            venDatos.art(index),
                            venDatos.tip(index),
                            venDatos.are(index),
                            cantidad,
                            (venDatos.est() == 'En proceso')
                                ? Consumer2<Textos, VenDatos>(
                                    builder: (context, textos, venDatos, child) {
                                      return CampoTexto.inputTexto(
                                        MediaQuery.sizeOf(context).width * .1,
                                        '',
                                        cantidadCub,
                                        cantidades[index],
                                        true,
                                        false,
                                        cambio: () => venDatos.canCubChange(
                                          index,
                                          cantidades[index].text.isNotEmpty
                                              ? double.parse(
                                                  cantidades[index].text,
                                                )
                                              : canCubOrg[index],
                                        ),
                                        borderColor: Color(0xFF8A03A9),
                                        formato:
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'(^\d*\.?\d{0,3})'),
                                            ),
                                        inputType:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        fontSize: 17.5,
                                        align: TextAlign.center,
                                      );
                                    },
                                  )
                                : cantidadCub,
                            Consumer<VenDatos>(
                              builder: (context, venDatos, child) {
                                return SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * .045,
                                  child: Botones.btnRctMor(
                                    'Ver comentarios',
                                    Icons.comment_rounded,
                                    false,
                                    () => {
                                      venNum = 1,
                                      id = index,
                                      verComentarios(
                                        venDatos.art(index),
                                        venDatos.est(),
                                        venDatos.comTienda(index),
                                        venDatos.comProv(index),
                                        venDatos.comFin(index),
                                      ),
                                    },
                                    alert:
                                        venDatos.comTienda(index) !=
                                            'Sin comentarios' ||
                                        venDatos.comFin(index) !=
                                            'Sin comentarios',
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                            Icon(
                              venDatos.comfProd(index)
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              color: Color(0xFF8A03A9),
                              size: 30,
                            ),
                          ],
                          [],
                          1,
                        );
                        return SingleChildScrollView(
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: venDatos.getMensaje(index).isEmpty
                                ? 40
                                : 57.5,
                            decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                            child: venDatos.getMensaje(index).isEmpty
                                ? data
                                : Column(
                                    children: [
                                      Tablas.contenedorInfo(
                                        MediaQuery.sizeOf(context).width,
                                        [.5],
                                        [venDatos.getMensaje(index)],
                                      ),
                                      data,
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Textos.textoGeneral(
                            'Destino: ${venDatos.loc()}',
                            false,
                            1,
                            alignment: TextAlign.center,
                          ),
                          Textos.textoGeneral(
                            'Remitente: ${venDatos.rem()}',
                            false,
                            1,
                            alignment: TextAlign.center,
                          ),
                          Textos.textoGeneral(
                            'Última modificación: ${venDatos.mod()}',
                            false,
                            1,
                            alignment: TextAlign.center,
                          ),
                        ],
                      ),
                      Column(
                        spacing: 7.5,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            spacing: 7.5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Botones.btnRctMor(
                                'Imprimir',
                                Icons.print_rounded,
                                false,
                                () => imprimir(context, [
                                  'Id de la orden: ${venDatos.id()}',
                                  'Pide: ${venDatos.loc()}',
                                  'Para: ${venDatos.rem()}',
                                  'Fecha: ${venDatos.mod().split(' ')[0]}',
                                ], venDatos.getDatos()),
                              ),
                              Botones.btnRctMor(
                                'Cerrar',
                                Icons.clear_rounded,
                                false,
                                () => ventana.tabla(false),
                              ),
                              if (venDatos.est() == 'En proceso')
                                Botones.btnRctMor(
                                  'Guardar',
                                  Icons.save_rounded,
                                  false,
                                  () => guardar(venDatos.canCubLista()),
                                ),
                            ],
                          ),
                          if (venDatos.est() == 'En proceso')
                            Row(
                              spacing: 7.5,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Botones.btnRctMor(
                                  'Denegar',
                                  Icons.cancel_schedule_send_rounded,
                                  false,
                                  () => cambiarEstado('denegar'),
                                ),
                                Botones.btnRctMor(
                                  'Entregar',
                                  Icons.store_rounded,
                                  false,
                                  () => cambiarEstado('entregar'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            Consumer2<Ventanas, Tablas>(
              builder: (context, ventanas, tablas, child) {
                return ventanas.ventanaFiltroOrden(
                  context,
                  filtros,
                  () async => tablas.datos(await getOrdenes()),
                );
              },
            ),
            Consumer4<Ventanas, Carga, VenDatos, Tablas>(
              builder: (context, ventana, carga, venDatos, tablas, child) {
                return Ventanas.ventanaEmergente(
                  [
                    '¿Segur@ que quieres $accion la orden?',
                    'Comentarios de ${id != 0 ? venDatos.art(id) : ''}',
                  ][venNum],
                  ['No, volver', 'Volver'][venNum],
                  ['Si, $accion', 'Guardar'][venNum],
                  () => ventana.emergente(false),
                  () async => {
                    ventana.emergente(false),
                    carga.cargaBool(true),
                    Textos.toast(await guardarDatos(context), false),
                    carga.cargaBool(false),
                    ventana.tabla(accion == 'guardar'),
                  },
                  widget: (venNum == 1)
                      ? Column(
                          children: [
                            Textos.textoTilulo('Comentarios de la tienda:', 20),
                            Textos.textoGeneral(
                              venDatos.comTienda(id),
                              true,
                              5,
                              size: 20,
                              alignment: TextAlign.center,
                            ),
                            if (venDatos.est() == 'En proceso')
                              CampoTexto.inputTexto(
                                MediaQuery.sizeOf(context).width,
                                'Comentarios del Proveedor',
                                '',
                                controller,
                                true,
                                false,
                                icono: Icons.message_rounded,
                              ),
                            if (venDatos.est() != 'En proceso')
                              Textos.textoTilulo(
                                'Comentarios del proveedor:',
                                20,
                              ),
                            if (venDatos.est() != 'En proceso')
                              Textos.textoGeneral(
                                venDatos.comProv(id),
                                true,
                                5,
                                size: 20,
                                alignment: TextAlign.center,
                              ),
                            if (venDatos.est() == 'Finalizado' ||
                                venDatos.est() == 'Incompleto')
                              Textos.textoTilulo('Comentarios finales:', 20),
                            if (venDatos.est() == 'Finalizado' ||
                                venDatos.est() == 'Incompleto')
                              Textos.textoGeneral(
                                venDatos.comFin(id),
                                true,
                                5,
                                size: 20,
                                alignment: TextAlign.center,
                              ),
                          ],
                        )
                      : null,
                );
              },
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }

  Widget opciones(BuildContext context) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Consumer2<Tablas, Carga>(
        builder: (context, tablas, carga, child) {
          List<Widget> filtroList = [
            Botones.btnRctMor(
              'Abrir menú',
              Icons.menu_rounded,
              false,
              () => Scaffold.of(context).openDrawer(),
              size: 35,
            ),
            Consumer<Ventanas>(
              builder: (context, ventanas, child) {
                return Botones.btnRctMor(
                  'Filtro de estado',
                  Icons.filter_list_rounded,
                  false,
                  () => ventanas.ordenFiltro(true),
                  size: 35,
                );
              },
            ),
          ];
          List<String> txt = ['id', 'Estado', 'Remitente', 'Locación'];
          List<IconData> icono = [
            Icons.numbers_rounded,
            Icons.query_builder_rounded,
            Icons.perm_identity_rounded,
            Icons.place_rounded,
          ];
          for (int i = 0; i < txt.length; i++) {
            filtroList.add(
              Botones.icoRctBor(
                txt[i],
                icono[i],
                colores[i],
                () async => {if (filtro != txt[i]) await filtroTexto(i)},
              ),
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: filtroList,
          );
        },
      ),
    );
  }

  ListView listaPrincipal(List lista, ScrollController controller) {
    return ListView.separated(
      controller: controller,
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        List<Color> coloresLista = List.filled(6, Colors.transparent);
        coloresLista[2] = Textos.colorEstado(lista[index].estado);
        return Consumer3<Textos, VenDatos, Ventanas>(
          builder: (context, textos, venDatos, ventanas, child) {
            return Container(
              width: MediaQuery.sizeOf(context).width,
              height: 40,
              decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
              child: Tablas.barraDatos(
                MediaQuery.sizeOf(context).width,
                [.05, .125, .175, .2, .2, .25],
                [
                  '${lista[index].id}',
                  '${lista[index].cantArticulos}',
                  lista[index].estado,
                  lista[index].remitente,
                  lista[index].locacion,
                  lista[index].fechaOrden,
                ],
                coloresLista,
                1,
                extra: () async => await getOrdenInfo(context, lista[index].id),
              ),
            );
          },
        );
      },
    );
  }
}
