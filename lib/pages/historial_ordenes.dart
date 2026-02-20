import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/orden_model.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:provider/provider.dart';
import '../services/local_storage.dart';

class HistorialOrdenes extends StatefulWidget {
  final StatefulWidget ruta;

  const HistorialOrdenes({super.key, required this.ruta});

  @override
  State<HistorialOrdenes> createState() => _HistorialOrdenesState();
}

class _HistorialOrdenesState extends State<HistorialOrdenes> {
  String filtro = 'id';
  List<Color> colores = [
    Color(0xFF8A03A9),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
  ];
  String titulo = '', btnNo = '', btnSi = '', datos = '';
  List<Widget> wid = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    wid.clear();
    colores.clear();
    super.dispose();
  }

  Future<List<OrdenModel>> getOrdenes() async =>
      await OrdenModel.getOrdenes(filtro, LocalStorage.local('locación'));

  Future<void> getOrdenInfo(BuildContext ctx, int id) async {
    ctx.read<Carga>().cargaBool(true);
    OrdenModel orden = await OrdenModel.getOrden(id);
    (orden.mensaje.isEmpty)
        ? {
            if (ctx.mounted)
              {
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
                ctx.read<Ventanas>().tabla(true),
              },
          }
        : Textos.toast(orden.mensaje, true);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  Future<void> filtroTexto(int valor) async {
    colores = List.filled(3, Color(0xFFFFFFFF));
    colores[valor] = Color(0xFF8A03A9);
    switch (valor) {
      case (0):
        filtro = 'id';
      case (1):
        filtro = 'Estado';
      case (2):
        filtro = 'Remitente';
    }
    context.read<Tablas>().datos(await getOrdenes());
  }

  void cambiarEstado() {
    String mensaje = 'La orden no se puede cancelar.';
    switch (context.read<VenDatos>().est()) {
      case ('En proceso'):
        mensaje = '';
        titulo = '¿Segur@ que quieres cancelar la orden?';
        btnNo = 'No, volver';
        btnSi = 'Si, cancelalo';
        datos = 'Cancelado';
        wid = [];
        context.read<Ventanas>().emergente(true);
        break;
      case ('Cancelado'):
        mensaje = 'La orden ya esta cencelada.';
        break;
      case ('Denegado'):
        mensaje = 'La orden ya esta denegada.';
        break;
    }
    if (mensaje.isNotEmpty) Textos.toast(mensaje, false);
  }

  void confirmarEntragas(List<bool> lista) {
    datos = 'Finalizado';
    for (bool obj in lista) {
      if (!obj) datos = 'Incompleto';
    }
    titulo = '¿Segur@ que ya marcaste todos los productos que recibiste?';
    btnNo = 'No, volver';
    btnSi = 'Si, confirmo';
    wid = [];
    context.read<Ventanas>().emergente(true);
  }

  void verComentarios(String nombre, String comTienda, String comProv) {
    titulo = 'Comentarios de $nombre';
    btnNo = 'Cerrar';
    btnSi = 'Confirmar';
    wid = [
      Textos.textoTilulo('Comentarios de la tienda:', 20),
      Textos.textoGeneral(
        comTienda,
        true,
        5,
        size: 20,
        alignment: TextAlign.center,
      ),
      Textos.textoTilulo('Comentarios del almacenista:', 20),
      Textos.textoGeneral(
        comProv,
        true,
        5,
        size: 20,
        alignment: TextAlign.center,
      ),
    ];
    context.read<Ventanas>().emergente(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
      drawer: RecDrawer.drawer(context, [
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Nueva orden',
              Icons.add_shopping_cart_rounded,
              () async => {
                carga.cargaBool(true),
                await RecDrawer.salidaOrdenes(context),
              },
              () => Textos.toast('Espera a que los datos carguen.', false),
              false,
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Ver almacen',
              Icons.inventory_rounded,
              () => {
                carga.cargaBool(true),
                Textos.limpiarLista(),
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Inventario()),
                ),
                carga.cargaBool(false),
              },
              () => Textos.toast('Espera a que los datos carguen.', false),
              true,
              Carga.getValido(),
            );
          },
        ),
      ]),
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  opciones(context),
                  Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.05, .2, .2, .3, .25],
                    [
                      'id',
                      'Art. ordenados',
                      'Estado',
                      'Remitente',
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
            ),
            Consumer2<Ventanas, VenDatos>(
              builder: (context, ventana, venDatos, child) {
                List<Widget> botones = [
                  Botones.btnCirRos('Cerrar', () => ventana.tabla(false)),
                  Botones.btnCirRos('Cancelar', () => cambiarEstado()),
                ];
                if (venDatos.est() == 'Entregado') {
                  botones.add(
                    Botones.btnCirRos(
                      'Confirmar',
                      () => confirmarEntragas(venDatos.comfProdLista()),
                    ),
                  );
                }
                return Ventanas.ventanaTabla(
                  MediaQuery.of(context).size.height,
                  MediaQuery.of(context).size.width,
                  [
                    'Id de la orden: ${venDatos.id()}',
                    'Estado: ${venDatos.est()}',
                  ],
                  [
                    'Destino: ${venDatos.loc()}',
                    'Remitente: ${venDatos.rem()}',
                    'Última modificación: ${venDatos.mod()}',
                  ],
                  Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.05, .225, .15, .1, .125, .115, .045, .045],
                    [
                      'id',
                      'Nombre del articulo',
                      'Área',
                      'Tipo',
                      'Cant. ordenada',
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
                      return Container(
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                        child: Tablas.barraDatos(
                          MediaQuery.sizeOf(context).width,
                          [.05, .225, .15, .1, .125, .115, .09],
                          [
                            '${venDatos.idArt(index)}',
                            venDatos.art(index),
                            venDatos.are(index),
                            venDatos.tip(index),
                            '${venDatos.can(index)}',
                            '${venDatos.canCub(index)}',
                            '',
                          ],
                          [],
                          2,
                          false,
                          extraWid: SizedBox(
                            width: MediaQuery.sizeOf(context).width * .09,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * .045,
                                  child: Botones.btnRctMor(
                                    'Ver comentarios',
                                    Icons.comment_rounded,
                                    false,
                                    () => verComentarios(
                                      venDatos.art(index),
                                      venDatos.comTienda(index),
                                      venDatos.comProv(index),
                                    ),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * .045,
                                  child: Botones.btnRctMor(
                                    'Confirmar',
                                    venDatos.comfProd(index)
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    false,
                                    () => {
                                      if (venDatos.est() == 'Entregado')
                                        venDatos.setComfProd(index),
                                    },
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  botones,
                );
              },
            ),
            Consumer3<Ventanas, Carga, VenDatos>(
              builder: (context, ventana, carga, venDatos, child) {
                return Ventanas.ventanaEmergente(
                  titulo,
                  btnNo,
                  btnSi,
                  () => ventana.emergente(false),
                  () async => {
                    if (btnSi != 'Confirmar')
                      {
                        carga.cargaBool(true),
                        ventana.tabla(false),
                        ventana.emergente(false),
                        (datos != 'Cancelado')
                            ? Textos.toast(
                                await OrdenModel.editarOrdenConfirmacion(
                                  venDatos.id(),
                                  datos,
                                  venDatos.comfProdLista(),
                                ),
                                true,
                              )
                            : Textos.toast(
                                await OrdenModel.editarOrden(
                                  venDatos.id(),
                                  'Estado',
                                  "'Cancelado'",
                                ),
                                true,
                              ),
                        if (context.mounted)
                          context.read<Tablas>().datos(await getOrdenes()),
                        carga.cargaBool(false),
                      },
                  },
                  widget: Column(children: wid),
                );
              },
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }

  Widget opciones(BuildContext ctx) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Consumer2<Tablas, Carga>(
        builder: (ctx, tablas, carga, child) {
          List<Widget> filtroList = [];
          filtroList.add(
            Botones.btnRctMor(
              'Regresar',
              Icons.arrow_back_rounded,
              false,
              () => {
                carga.cargaBool(true),
                Navigator.pushReplacement(
                  ctx,
                  MaterialPageRoute(builder: (context) => widget.ruta),
                ),
                carga.cargaBool(false),
              },
              size: 35,
            ),
          );
          List<String> txt = ['id', 'Estado', 'Remitente'];
          List<IconData> icono = [
            Icons.numbers_rounded,
            Icons.query_builder_rounded,
            Icons.perm_identity_rounded,
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

  ListView listaPrincipal(List lista) {
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        List<Color> coloresLista = List.filled(5, Colors.transparent);
        coloresLista[2] = Textos.colorEstado(lista[index].estado);
        return Container(
          height: 40,
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Colors.white),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.05, .2, .2, .3, .25],
            [
              '${lista[index].id}',
              '${lista[index].cantArticulos}',
              lista[index].estado,
              lista[index].remitente,
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
  }
}
