import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/orden_model.dart';
import 'package:provider/provider.dart';
import '../services/local_storage.dart';

class HistorialOrdenes extends StatefulWidget {
  const HistorialOrdenes({super.key});

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
  TextEditingController controller = TextEditingController();
  int venNum = 0;
  String datos = '';
  int? indexComentario;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
                ctx.read<VenDatos>().setDatos(orden),
                ctx.read<Ventanas>().tabla(true),
              },
          }
        : Textos.toast(orden.mensaje, true);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  Future<void> filtroTexto(int valor) async {
    colores = List.filled(3, Color(0xFFFFFFFF), growable: true);
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
        venNum = 0;
        datos = 'Cancelado';
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

  void confirmarEntragas(List lista) {
    datos = 'Finalizado';
    for (bool obj in lista) {
      if (!obj) datos = 'Incompleto';
    }
    venNum = 1;
    context.read<Ventanas>().emergente(true);
  }

  void verComentarios(String comFin, int index) {
    indexComentario = index;
    venNum = 2;
    controller.text = (context.read<VenDatos>().est() == 'Entregado')
        ? (comFin == 'Sin comentarios')
              ? ''
              : comFin
        : comFin;
    context.read<Ventanas>().emergente(true);
  }

  Future<void> guardarComentario(BuildContext ctx) async {
    String datos;
    List<String> listaDatos = [];
    ctx.read<VenDatos>().ordenarPor(false);
    ctx.read<Carga>().cargaBool(true);
    if (controller.text != ctx.read<VenDatos>().comFin(indexComentario!)) {
      ctx.read<Ventanas>().emergente(false);
      ctx.read<VenDatos>().setComFin(indexComentario!, controller.text);
      for (int i = 0; i < ctx.read<VenDatos>().length(); i++) {
        String texto = "'${ctx.read<VenDatos>().comFin(i)}'";
        if (ctx.read<VenDatos>().comProv(i).isEmpty) {
          texto = "'Sin comentarios'";
        }
        listaDatos.add(texto);
      }
      datos = 'Array$listaDatos';
      datos = await OrdenModel.editarOrden(
        ctx.read<VenDatos>().id(),
        'ComentariosFinales',
        datos,
      );
      if (ctx.mounted) ctx.read<Tablas>().datos(await getOrdenes());
    } else {
      datos = 'Error: No hay datos.';
    }
    if (datos.split(': ')[0] == 'Error') datos = datos.split(': ')[1];
    if (ctx.mounted) {
      ctx.read<Carga>().cargaBool(false);
      ctx.read<VenDatos>().ordenarPor(true);
    }
    Textos.toast(datos, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
      drawer: RecDrawer.drawer(context, [
        /*Consumer<Carga>(
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
                RecDrawer.pushAnim(Inventario(), context),
                carga.cargaBool(false),
              },
              () => Textos.toast('Espera a que los datos carguen.', false),
              true,
              Carga.getValido(),
            );
          },
        ),*/
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
            ),
            Consumer2<Ventanas, VenDatos>(
              builder: (context, ventana, venDatos, child) {
                return Ventanas.ventanaTabla(
                  (venDatos.length() * 44 + 135 <
                          MediaQuery.sizeOf(context).height)
                      ? venDatos.length() * 44 + 135
                      : MediaQuery.sizeOf(context).height,
                  MediaQuery.of(context).size.width,
                  [
                    'Id de la orden: ${venDatos.id()}',
                    'Estado: ${venDatos.est()}',
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
                  SizedBox(
                    height:
                        (venDatos.length() * 44 <
                            MediaQuery.sizeOf(context).height - 220)
                        ? venDatos.length() * 44
                        : MediaQuery.sizeOf(context).height - 220,
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
                        return Container(
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                          child: Tablas.barraDatos(
                            MediaQuery.sizeOf(context).width,
                            [.05, .225, .15, .1, .125, .115, .045, .045],
                            [
                              '${venDatos.idArt(index)}',
                              venDatos.art(index),
                              venDatos.are(index),
                              venDatos.tip(index),
                              cantidad,
                              cantidadCub,
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * .045,
                                child: Botones.btnRctMor(
                                  'Ver comentarios ${venDatos.art(index)}',
                                  Icons.comment_rounded,
                                  false,
                                  alert:
                                      venDatos.comTienda(index) !=
                                          'Sin comentarios' ||
                                      venDatos.comProv(index) !=
                                          'Sin comentarios' ||
                                      venDatos.comFin(index) !=
                                          'Sin comentarios',
                                  () => verComentarios(
                                    venDatos.comFin(index),
                                    index,
                                  ),
                                  size: 20,
                                ),
                              ),
                              venDatos.est() == 'Entregado' || venDatos.edit()
                                  ? SizedBox(
                                      width:
                                          MediaQuery.sizeOf(context).width *
                                          .045,
                                      child: Botones.btnRctMor(
                                        'Confirmar ${venDatos.art(index)}',
                                        venDatos.comfProd(index)
                                            ? Icons.check_box_rounded
                                            : Icons
                                                  .check_box_outline_blank_rounded,
                                        false,
                                        () => venDatos.setComfProd(index),
                                        size: 20,
                                      ),
                                    )
                                  : Icon(
                                      venDatos.comfProd(index)
                                          ? Icons.check_box_rounded
                                          : Icons
                                                .check_box_outline_blank_rounded,
                                      color: Color(0xFF8A03A9),
                                      size: 30,
                                    ),
                            ],
                            [],
                            2,
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
                      Row(
                        spacing: 7.5,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Botones.btnRctMor(
                            'Cerrar',
                            Icons.clear_rounded,
                            false,
                            () => {
                              venDatos.setEdit(false),
                              ventana.tabla(false),
                            },
                          ),
                          Botones.btnRctMor(
                            'Cancelar',
                            Icons.cancel_schedule_send_rounded,
                            false,
                            () => cambiarEstado(),
                          ),
                          if (venDatos.est() == 'Entregado' || venDatos.edit())
                            Botones.btnRctMor(
                              'Confirmar',
                              Icons.check_circle_rounded,
                              false,
                              () => confirmarEntragas(venDatos.comfProdLista()),
                            ),
                          if (venDatos.est() == 'Incompleto' &&
                              !venDatos.edit())
                            Botones.btnRctMor(
                              'Editar confirmaciones',
                              Icons.edit_note_rounded,
                              false,
                              () => venDatos.setEdit(true),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            Consumer3<Ventanas, Carga, VenDatos>(
              builder: (context, ventana, carga, venDatos, child) {
                return Ventanas.ventanaEmergente(
                  [
                    '¿Segur@ que quieres cancelar la orden?',
                    '¿Segur@ que ya marcaste todos los productos que recibiste?',
                    indexComentario != null
                        ? 'Comentarios de ${venDatos.art(indexComentario!)}'
                        : '',
                  ][venNum],
                  ['No, volver', 'No, volver', 'Cerrar'][venNum],
                  ['Si, cancelalo', 'Si, confirmo', 'Confirmar'][venNum],
                  () => ventana.emergente(false),
                  () async => {
                    if (venNum != 2)
                      {
                        carga.cargaBool(true),
                        ventana.tabla(false),
                        ventana.emergente(false),
                        venDatos.ordenarPor(false),
                        venDatos.setEdit(false),
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
                          {
                            venDatos.ordenarPor(false),
                            context.read<Tablas>().datos(await getOrdenes()),
                          },
                        carga.cargaBool(false),
                      }
                    else
                      {
                        if (venDatos.est() == 'Entregado')
                          guardarComentario(context),
                      },
                  },
                  widget: (venNum == 2)
                      ? Column(
                          children: [
                            Textos.textoTilulo('Comentarios de la tienda:', 20),
                            Textos.textoGeneral(
                              indexComentario != null
                                  ? venDatos.comTienda(indexComentario!)
                                  : '',
                              true,
                              5,
                              size: 20,
                              alignment: TextAlign.center,
                            ),
                            Textos.textoTilulo(
                              'Comentarios del almacenista:',
                              20,
                            ),
                            Textos.textoGeneral(
                              indexComentario != null
                                  ? venDatos.comProv(indexComentario!)
                                  : '',
                              true,
                              5,
                              size: 20,
                              alignment: TextAlign.center,
                            ),
                            if (venDatos.est() == 'Entregado')
                              CampoTexto.inputTexto(
                                MediaQuery.sizeOf(context).width,
                                'Comentarios finales:',
                                '',
                                controller,
                                true,
                                false,
                                accion: () => guardarComentario(context),
                                icono: Icons.message_rounded,
                              ),
                            if (venDatos.est() == 'Finalizado' ||
                                venDatos.est() == 'Incompleto')
                              Textos.textoTilulo('Comentarios finales:', 20),
                            if (venDatos.est() == 'Finalizado' ||
                                venDatos.est() == 'Incompleto')
                              Textos.textoGeneral(
                                indexComentario != null
                                    ? venDatos.comFin(indexComentario!)
                                    : '',
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

  Widget opciones(BuildContext ctx) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Consumer2<Tablas, Carga>(
        builder: (ctx, tablas, carga, child) {
          List<Widget> filtroList = [
            Botones.btnRctMor(
              'Abrir menú',
              Icons.menu_rounded,
              false,
              () => Scaffold.of(context).openDrawer(),
              size: 35,
            ),
          ];
          /*filtroList.add(
            Botones.btnRctMor(
              'Regresar',
              Icons.arrow_back_rounded,
              false,
              () => {
                carga.cargaBool(true),
                RecDrawer.pushAnim(widget.ruta, ctx),
                carga.cargaBool(false),
              },
              size: 35,
            ),
          );*/
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
              lista[index].fechaOrden,
            ],
            coloresLista,
            1,
            extra: () async => await getOrdenInfo(context, lista[index].id),
          ),
        );
      },
    );
  }
}
