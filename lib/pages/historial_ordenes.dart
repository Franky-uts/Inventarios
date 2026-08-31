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

//Esta es una página principal encargada de mostrar todas las ordenes
//registrados en la base de datos que coincidan con la tienda en la que esta
//ubicado el usuario, las ordenes que se muestran se pueden ordenar por id,
//estado y remitente, se puede presionar sobre una orden y ver su información
//más a detalle con la posibilidad de editar ciertos valores.
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
  int indexComentario = 0;
  List<bool> filtros = List.filled(6, true, growable: true);

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
      await OrdenModel.getOrdenes(filtro, filtros);

  //Esta es una función que se encarga de obtener el id de la orden seleccionada
  //en la lista y con este se pida la información de la orden en la base de
  //datos para mostrarlo a detalle en una ventana, en caso de que suceda algún
  //error por parte del servidor se abortara el proceso y se le hará conocer al
  //usuario por medio de toast.
  Future<void> getOrdenInfo(BuildContext ctx, int id) async {
    ctx.read<Carga>().cargaBool(true);
    OrdenModel orden = await OrdenModel.getOrden(id);
    if (orden.mensaje.isEmpty) {
      if (ctx.mounted) {
        ctx.read<VenDatos>().setDatos(orden);
        ctx.read<Ventanas>().tabla(true);
      }
    } else {
      Textos.toast(orden.mensaje);
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  //Esta es una función que se ejecuta al momento de seleccionar un botón de
  //filtro, si el filtro es igual al filtro actual no se realizara ninguna
  //acción, de lo contrario el filtro seleccionado tendrá un borde morado en su
  //botón correspondiente y se volverá a hacer una petición al servidor para que
  //envíe la información de nuevo con el filtro aplicado.
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

  //Este método se encarga de cambiar el estado de la orden a "Cancelado", esto
  //solo se hace si el estado es estado de la orden es "En proceso" de lo
  //contrario mostrara un mensaje en forma de toast señalándole que no se puede
  //cancelar la orden.
  void cancelarOrden() {
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
    if (mensaje.isNotEmpty) Textos.toast(mensaje);
  }

  //Este método se encarga de cambiar el estado de una orden dependiendo del
  //apartado de producto confirmado en cada producto ordenado en una orden, en
  //caso de que todos los productos estén confirmados la orden cambiara de
  //estado a "Finalizado", por otro lado, si hay algún producto sin confirmar
  //en la lista entonces el estado de la orden cambiara a Incompleto, antes del
  //cambio de estado se abrirá una ventana para confirmar el cambio de estado.
  void confirmarEntragas(List lista) {
    datos = 'Finalizado';
    for (bool obj in lista) {
      if (!obj) datos = 'Incompleto';
    }
    venNum = 1;
    context.read<Ventanas>().emergente(true);
  }

  //Este método se encarga de abrir la ventana correspondiente a mostrar los
  //comentarios, más en específico el comentario final.
  void verComentarios(String comFin, int index) {
    indexComentario = index;
    venNum = 2;
    if (context.read<VenDatos>().est() == 'Entregado') {
      if (comFin == 'Sin comentarios') {
        comFin = '';
      }
    }
    controller.text = comFin;
    context.read<Ventanas>().emergente(true);
  }

  //Este método se encarga de actualizar un comentario el comentario final, el
  //comentario final se puede editar al momento que la orden ya está entregada,
  //de otro modo solo se mostrara el comentario que dejaron.
  Future<void> guardarComentario(BuildContext ctx) async {
    String datos;
    List<String> listaDatos = [];
    ctx.read<Carga>().cargaBool(true);
    if (controller.text.isEmpty) controller.text = 'Sin comentarios';
    if (controller.text != ctx.read<VenDatos>().comFin(indexComentario)) {
      ctx.read<Ventanas>().emergente(false);
      ctx.read<VenDatos>().setComFin(indexComentario, controller.text);
      ctx.read<VenDatos>().ordenarPor(false);
      for (int i = 0; i < ctx.read<VenDatos>().length(); i++) {
        listaDatos.add("'${ctx.read<VenDatos>().comFin(i)}'");
      }
      datos = 'Array$listaDatos';
      datos = await OrdenModel.editarOrden(
        ctx.read<VenDatos>().id(),
        'ComentariosFinales',
        datos,
      );
      indexComentario = 0;
      if (ctx.mounted) ctx.read<Tablas>().datos(await getOrdenes());
    } else {
      datos = 'Error: No hay datos.';
    }
    if (datos.split(': ')[0] == 'Error') datos = datos.split(': ')[1];
    if (ctx.mounted) {
      ctx.read<Carga>().cargaBool(false);
      ctx.read<VenDatos>().ordenarPor(true);
    }
    Textos.toast(datos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
      drawer: RecDrawer.drawer(context, []),
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
                  (venDatos.length() * 42 + cantDiv * 17.5 + 135 <
                          MediaQuery.sizeOf(context).height)
                      ? venDatos.length() * 42 + cantDiv * 17.5 + 135
                      : MediaQuery.sizeOf(context).height,
                  MediaQuery.of(context).size.width,
                  [
                    'Id de la orden: ${venDatos.id()}',
                    'Estado: ${venDatos.est()}',
                  ],
                  Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.05, .3, .15, .125, .125, .045, .045],
                    [
                      'id',
                      'Nombre del articulo',
                      'Tipo',
                      'Cant. ordenada',
                      'Cant. cubierta',
                      '💬',
                      '☑️',
                    ],
                  ),
                  SizedBox(
                    height:
                        (venDatos.length() * 42 + cantDiv * 17.5 <
                            MediaQuery.sizeOf(context).height - 220)
                        ? venDatos.length() * 42 + cantDiv * 17.5
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
                        Widget data = Tablas.barraDatos(
                          MediaQuery.sizeOf(context).width,
                          [.05, .3, .15, .125, .125, .045, .045],
                          [
                            '${venDatos.idArt(index)}',
                            venDatos.art(index),
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
                                    venDatos.comFin(index) != 'Sin comentarios',
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
                                        MediaQuery.sizeOf(context).width * .045,
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
                                        : Icons.check_box_outline_blank_rounded,
                                    color: Color(0xFF8A03A9),
                                    size: 30,
                                  ),
                          ],
                          maxLines: 2,
                        );
                        return Container(
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
                                    SizedBox(height: 40, child: data),
                                  ],
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
                            () => cancelarOrden(),
                          ),
                          if (venDatos.est() == 'Entregado' || venDatos.edit())
                            Botones.btnRctMor(
                              'Confirmar',
                              Icons.check_circle_rounded,
                              false,
                              () => confirmarEntragas(venDatos.comfProdLista()),
                            ),
                          if ((venDatos.est() == 'Incompleto' ||
                                  venDatos.est() == 'Finalizado') &&
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
            Consumer2<Ventanas, Tablas>(
              builder: (context, ventanas, tablas, child) {
                return ventanas.ventanaFiltroOrden(
                  context,
                  filtros,
                  () async => tablas.datos(await getOrdenes()),
                );
              },
            ),
            Consumer3<Ventanas, Carga, VenDatos>(
              builder: (context, ventana, carga, venDatos, child) {
                return Ventanas.ventanaEmergente(
                  [
                    '¿Segur@ que quieres cancelar la orden?',
                    '¿Segur@ que ya marcaste todos los productos que recibiste?',
                    'Comentarios de ${venDatos.art(indexComentario)}',
                  ][venNum],
                  ['No, volver', 'No, volver', 'Cerrar'][venNum],
                  ['Si, cancelalo', 'Si, confirmo', 'Confirmar'][venNum],
                  () => {indexComentario = 0, ventana.emergente(false)},
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
                              )
                            : Textos.toast(
                                await OrdenModel.editarOrden(
                                  venDatos.id(),
                                  'Estado',
                                  "'Cancelado'",
                                ),
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
                              venDatos.comTienda(indexComentario),
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
                              venDatos.comProv(indexComentario),
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
                                accion: () => guardarComentario(context),
                                icono: Icons.message_rounded,
                              ),
                            if (venDatos.est() == 'Finalizado' ||
                                venDatos.est() == 'Incompleto')
                              Textos.textoTilulo('Comentarios finales:', 20),
                            if (venDatos.est() == 'Finalizado' ||
                                venDatos.est() == 'Incompleto')
                              Textos.textoGeneral(
                                venDatos.comFin(indexComentario),
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

  //Este es un componente ubicado arriba de la tabla para poder mostrar la
  //opción de abrir el menú, filtrar las órdenes por estados y los botones para
  //ordenar la lista por id, estado y remitente.
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
              () => Scaffold.of(ctx).openDrawer(),
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

  //Componente que regresa una lista de ordenes correspondientes a la tienda
  //del usuario, al momento de presionar una orden se abrirá una ventana con
  //información más detallada de la orden, con la posibilidad de editar ciertos
  //datos si así se requiere.
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
            maxLines: 1,
            extra: () async => await getOrdenInfo(context, lista[index].id),
            colores: coloresLista,
          ),
        );
      },
    );
  }
}
