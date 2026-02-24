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
import 'package:inventarios/pages/articulos.dart';
import 'package:inventarios/pages/ordenes_inventario.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../models/orden_model.dart';

class Acc extends Intent {
  const Acc();
}

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
  List canCubOrg = [];
  TextEditingController controller = TextEditingController();
  String filtro = 'id', accion = '', titulo = '', btnNo = '', btnSi = '';
  int id = 0;
  List<Widget> wid = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    colores.clear();
    controller.dispose();
    wid.clear();
    super.dispose();
  }

  Future<List<OrdenModel>> getOrdenes() async =>
      await OrdenModel.getAllOrdenes(filtro);

  Future<void> getOrdenInfo(BuildContext ctx, int id) async {
    ctx.read<Carga>().cargaBool(true);
    OrdenModel orden = await OrdenModel.getOrden(id);
    (orden.mensaje.isEmpty)
        ? {
            Textos.limpiarLista(),
            if (ctx.mounted)
              {
                canCubOrg.clear(),
                ctx.read<VenDatos>().setDatos(
                  orden.idProductos,
                  orden.articulos,
                  orden.cantidades,
                  orden.areas,
                  orden.tipos,
                  orden.cantidadesCubiertas,
                  orden.cantidadAlmacen,
                  orden.comentariosProveedor,
                  orden.comentariosTienda,
                  orden.confirmacion,
                  '${orden.id}',
                  orden.remitente,
                  orden.estado,
                  orden.ultimaModificacion,
                  orden.locacion,
                ),
                Textos.crearLista(orden.cantArticulos, Color(0xFF8A03A9)),
                canCubOrg.addAll(ctx.read<VenDatos>().canCubLista()),
                ctx.read<Ventanas>().tabla(true),
              },
          }
        : Textos.toast(orden.mensaje, true);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  void cambiarEstado(String accion) {
    wid = [];
    titulo = '¿Segur@ que quieres $accion la orden?';
    btnNo = 'No, volver';
    btnSi = 'Si, $accion';
    this.accion = accion;
    context.read<Ventanas>().emergente(true);
  }

  void guardar(List lista) {
    bool guardar = false;
    int i = 0;
    while (i < canCubOrg.length) {
      if (!guardar) guardar = (lista[i] != canCubOrg[i]);
      i++;
    }
    guardar ? cambiarEstado('guardar') : Textos.toast('No hay cambios', true);
  }

  void verComentarios(
    String nombre,
    String estado,
    String comTienda,
    String comProv,
  ) {
    titulo = 'Comentarios de $nombre';
    btnNo = 'Volver';
    btnSi = 'Guardar';
    accion = 'confirmar';
    wid = [
      Textos.textoTilulo('Comentarios de la tienda:', 20),
      Textos.textoGeneral(
        comTienda,
        true,
        5,
        size: 20,
        alignment: TextAlign.center,
      ),
    ];
    (estado == 'En proceso')
        ? {
            if (comProv == 'Sin comentarios') comProv = '',
            wid.add(
              CampoTexto.inputTexto(
                MediaQuery.sizeOf(context).width,
                'Comentarios de la del almacenista',
                controller,
                Color(0x00000000),
                true,
                false,
                () => {},
                icono: Icons.message_rounded,
              ),
            ),
          }
        : wid.addAll([
            Textos.textoTilulo('Comentarios del proveedor:', 20),
            Textos.textoGeneral(
              comProv,
              true,
              5,
              size: 30,
              alignment: TextAlign.center,
            ),
          ]);
    controller.text = comProv;
    context.read<Ventanas>().emergente(true);
  }

  Future<String> guardarDatos(BuildContext ctx) async {
    String columna = 'Estado';
    String datos = accion;
    List listaDatos = [];
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
              ctx.read<Tablas>().datos(await OrdenModel.getAllOrdenes(filtro)),
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
                    for (
                      int i = 0;
                      i < ctx.read<VenDatos>().canCubLista().length;
                      i++
                    )
                      {canCubOrg.add(ctx.read<VenDatos>().canCub(i))},
                },
            }
          : datos = datos.split(': ')[1];
    }
    return datos;
  }

  void imprimir(int id) async {
    Printing.pickPrinter(context: context, title: 'hola');
    //await Printing.directPrintPdf(printer: printer, onLayout: onLayout)
    Textos.toast('prueba', true);
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
      drawer: RecDrawer.drawer(context, [
        Consumer<Carga>(
          builder: (context, carga, child) {
            return Botones.icoCirMor(
              'Ver artículos',
              Icons.list,
              () => {
                carga.cargaBool(true),
                if (CampoTexto.seleccionFiltro == Filtros.unidades)
                  CampoTexto.seleccionFiltro = Filtros.id,
                RecDrawer.pushAnim(Articulos(), context),
                carga.cargaBool(false),
              },
              () => {},
              false,
              true,
            );
          },
        ),
        Consumer<Carga>(
          builder: (context, carga, child) {
            return Botones.icoCirMor(
              'Ver almacen',
              Icons.inventory_rounded,
              () => {
                carga.cargaBool(true),
                RecDrawer.pushAnim(OrdenesInventario(), context),
                carga.cargaBool(false),
              },
              () => {},
              true,
              true,
            );
          },
        ),
      ]),
      backgroundColor: Color(0xFFFF5600),
      body: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): Acc(),
        },
        child: PopScope(
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
                              'Última modificación',
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height - 82,
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
                  return Ventanas.ventanaTabla(
                    MediaQuery.of(context).size.height,
                    MediaQuery.of(context).size.width,
                    [
                      'Id de la orden: ${venDatos.id()}',
                      'Estado: ${venDatos.est()}',
                    ],
                    [
                      'Locación: ${venDatos.loc()}',
                      'Remitente: ${venDatos.rem()}',
                      'Última modificación: ${venDatos.mod()}',
                    ],
                    Tablas.contenedorInfo(
                      MediaQuery.sizeOf(context).width,
                      [.1, .25, .1, .125, .1, .155, .045, .045],
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
                    ListView.separated(
                      itemCount: venDatos.length(),
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) => Container(
                        height: 2,
                        decoration: BoxDecoration(color: Color(0xFFFDC930)),
                      ),
                      itemBuilder: (context, index) {
                        return SingleChildScrollView(
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                            child: Tablas.barraDatos(
                              MediaQuery.sizeOf(context).width,
                              [.1, .25, .1, .125, .1, .245],
                              [
                                '${venDatos.idArt(index)}',
                                venDatos.art(index),
                                venDatos.tip(index),
                                venDatos.are(index),
                                '${venDatos.can(index)}',
                                '',
                              ],
                              [],
                              1,
                              false,
                              extraWid: botones(index),
                            ),
                          ),
                        );
                      },
                    ),
                    [
                      /*if (venDatos.est() == 'En proceso')
                        Botones.btnCirRos(
                          'Imprimir',
                          () => imprimir(
                            int.parse(context.read<VenDatos>().id()),
                          ),
                        ),*/
                      Botones.btnCirRos(
                        'Cerrar',
                        () => context.read<Ventanas>().tabla(false),
                      ),
                      if (venDatos.est() == 'En proceso')
                        Botones.btnCirRos(
                          'Guardar',
                          () => guardar(context.read<VenDatos>().canCubLista()),
                        ),
                      if (venDatos.est() == 'En proceso')
                        Botones.btnCirRos(
                          'Denegar',
                          () => cambiarEstado('denegar'),
                        ),
                      if (venDatos.est() == 'En proceso')
                        Botones.btnCirRos(
                          'Entregar',
                          () => cambiarEstado('entregar'),
                        ),
                    ],
                  );
                },
              ),
              Consumer4<Ventanas, Carga, VenDatos, Tablas>(
                builder: (context, ventana, carga, venDatos, tablas, child) {
                  return Ventanas.ventanaEmergente(
                    titulo,
                    btnNo,
                    btnSi,
                    () => ventana.emergente(false),
                    () async => {
                      ventana.emergente(false),
                      carga.cargaBool(true),
                      Textos.toast(await guardarDatos(context), false),
                      carga.cargaBool(false),
                      ventana.tabla(
                        accion == 'guardar' || accion == 'confirmar',
                      ),
                    },
                    widget: Column(children: wid),
                  );
                },
              ),
              Carga.ventanaCarga(),
            ],
          ),
        ),
      ),
    );
  }

  Widget opciones(BuildContext context) {
    return Container(
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

  SizedBox botones(int index) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * .245,
      child: Consumer2<Textos, VenDatos>(
        builder: (context, textos, venDatos, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * .155,
                child: Botones.botonesSumaResta(
                  venDatos.art(index),
                  venDatos.canCub(index),
                  Textos.getColor(index),
                  () => {
                    if (venDatos.est() == 'En proceso')
                      {
                        textos.setColor(index, Color(0xFFFF0000)),
                        if (venDatos.canCub(index) > 0)
                          {
                            textos.setColor(index, Color(0xFF8A03A9)),
                            context.read<VenDatos>().canCubSub(index),
                          },
                      },
                  },
                  () => {
                    if (venDatos.canCub(index) < venDatos.can(index) &&
                        venDatos.est() == 'En proceso')
                      {
                        textos.setColor(index, Color(0xFFFF0000)),
                        if (venDatos.canAlm(index) - 1 >= 0)
                          {
                            textos.setColor(index, Color(0xFF8A03A9)),
                            venDatos.canCubAdd(index),
                          },
                      },
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * .045,
                child: Botones.btnRctMor(
                  'Ver comentarios',
                  Icons.comment_rounded,
                  false,
                  () => {
                    id = index,
                    verComentarios(
                      venDatos.art(index),
                      venDatos.est(),
                      venDatos.comTienda(index),
                      venDatos.comProv(index),
                    ),
                  },
                  size: 20,
                ),
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * .045,
                child: Botones.btnRctMor(
                  'Confirmar',
                  venDatos.comfProd(index)
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  false,
                  () => {},
                  size: 20,
                ),
              ),
            ],
          );
        },
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
                  lista[index].ultimaModificacion,
                ],
                coloresLista,
                1,
                true,
                extra: () async => await getOrdenInfo(context, lista[index].id),
              ),
            );
          },
        );
      },
    );
  }
}
