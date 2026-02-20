import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/orden_model.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/inventario_prod.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';

import 'historial_ordenes.dart';

class OrdenSalidaProd extends StatefulWidget {
  const OrdenSalidaProd({super.key});

  @override
  State<OrdenSalidaProd> createState() => _OrdenSalidaProdState();
}

class _OrdenSalidaProdState extends State<OrdenSalidaProd> {
  List<int> cantidad = [];
  List<ProductoModel> listaProd = [];
  List<String> comentarios = [];
  String comTit = '';
  int comid = 0;
  TextEditingController controller = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  Future<List<ProductoModel>> getProductos(
    String filtro,
    String busqueda,
  ) async => await ProductoModel.getProductosProd(filtro, busqueda);

  @override
  void dispose() {
    listaProd.clear();
    cantidad.clear();
    comentarios.clear();
    controller.dispose();
    super.dispose();
  }

  Future<void> addOrden(BuildContext ctx) async {
    List<int> cantidades = [];
    List<int> idProductos = [];
    ctx.read<Carga>().cargaBool(true);
    for (ProductoModel prod in listaProd) {
      cantidades.add(cantidad[prod.id - 1]);
      idProductos.add(prod.id);
    }
    String respuesta = await OrdenModel.postOrden(
      idProductos,
      cantidades,
      comentarios,
    );
    if (respuesta.split(': ')[0] != 'Error') {
      for (int i = 0; i < cantidad.length; i++) {
        cantidad[i] = 0;
      }
      listaProd.clear();
      comentarios.clear();
    }
    if (ctx.mounted) {
      ctx.read<Textos>().setAllColor(Color(0xFFFDC930));
      ctx.read<Carga>().cargaBool(false);
      ctx.read<Ventanas>().tabla(false);
    }
    Textos.toast(respuesta, true);
  }

  void listas(int length) {
    if (cantidad.isEmpty) {
      cantidad.addAll(List.filled(length, 0));
    }
  }

  void generarTabla(BuildContext ctx) async {
    List<ProductoModel> lista = await getProductos('id', '');
    String mensaje = 'Espera a que los datos carguen.';
    if (Carga.getValido()) {
      mensaje = '';
      int j = 0;
      for (int i = 0; i < cantidad.length; i++) {
        if (cantidad[i] > 0) {
          while (i + 1 != lista[j].id) {
            j++;
          }
          listaProd.add(lista[j]);
          comentarios.add('');
        }
      }
      if (listaProd.isEmpty) mensaje = 'No hay productos seleccionados.';
    }
    if (ctx.mounted) ctx.read<Ventanas>().tabla(listaProd.isNotEmpty);
    if (mensaje.isNotEmpty) Textos.toast(mensaje, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: RecDrawer.drawer(context, [
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Historial de ordenes',
              Icons.history_rounded,
              () async => {
                await LocalStorage.set(
                  'busqueda',
                  CampoTexto.busquedaTexto.text,
                ),
                if (context.mounted)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HistorialOrdenes(ruta: OrdenSalidaProd()),
                    ),
                  ),
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
              'Inventario',
              Icons.cookie_rounded,
              () async => {
                await LocalStorage.set(
                  'busqueda',
                  CampoTexto.busquedaTexto.text,
                ),
                Textos.limpiarLista(),
                if (context.mounted)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => InventarioProd()),
                  ),
              },
              () => Textos.toast('Espera a que los datos carguen.', false),
              true,
              Carga.getValido(),
            );
          },
        ),
      ]),
      backgroundColor: Color(0xFFFF5600),
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Builder(
              builder: (context) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    barraDeBusqueda(context),
                    Column(
                      children: [
                        Tablas.contenedorInfo(
                          MediaQuery.sizeOf(context).width,
                          [.1, .25, .175, .175, .08, .2],
                          [
                            'id',
                            'Nombre',
                            'Área',
                            'Tipo',
                            'Unidades',
                            'Acciones',
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 97,
                          child: Consumer<Tablas>(
                            builder: (context, tablas, child) {
                              return Tablas.listaFutura(
                                listaPrincipal,
                                'No hay productos registrados.',
                                'No hay coincidencias.',
                                () => getProductos(
                                  CampoTexto.filtroTexto(),
                                  CampoTexto.busquedaTexto.text,
                                ),
                                accionRefresh: () async => tablas.datos(
                                  await getProductos(
                                    CampoTexto.filtroTexto(),
                                    CampoTexto.busquedaTexto.text,
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
            Consumer2<Ventanas, Carga>(
              builder: (context, ventana, carga, child) {
                return Ventanas.ventanaTabla(
                  MediaQuery.of(context).size.height,
                  MediaQuery.of(context).size.width,
                  ['Productos seleccionados:'],
                  ['Enviar orden:'],
                  Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.045, .215, .15, .105, .075, .075, .075, .05],
                    [
                      'id',
                      'Nombre',
                      'Área',
                      'Tipo',
                      'Ordenar',
                      'Prod./Caja',
                      'Prod. Total',
                      '💬',
                    ],
                  ),
                  ListView.separated(
                    itemCount: listaProd.length,
                    scrollDirection: Axis.vertical,
                    separatorBuilder: (context, index) => Container(
                      height: 2,
                      decoration: BoxDecoration(color: Color(0xFFFDC930)),
                    ),
                    itemBuilder: (context, index) {
                      return Consumer<Tablas>(
                        builder: (context, tablas, child) {
                          List<Color> colores = List.filled(
                            8,
                            Color(0x00000000),
                          );
                          colores[4] = Textos.colorLimite(
                            listaProd[index].limiteProd,
                            cantidad[listaProd[index].id - 1] +
                                listaProd[index].unidades.floor(),
                          );
                          String cantUni =
                              '${listaProd[index].cantidadPorUnidad}';
                          String total =
                              '${cantidad[listaProd[index].id - 1] * listaProd[index].cantidadPorUnidad}';
                          return Container(
                            width: MediaQuery.sizeOf(context).width,
                            decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                            child: Tablas.barraDatos(
                              MediaQuery.sizeOf(context).width,
                              [.045, .215, .15, .105, .075, .075, .075, .05],
                              [
                                "${listaProd[index].id}",
                                listaProd[index].nombre,
                                listaProd[index].area,
                                listaProd[index].tipo,
                                '${cantidad[listaProd[index].id - 1]}',
                                (cantUni.split('.')[1] == '0')
                                    ? cantUni.split('.')[0]
                                    : cantUni,
                                (total.split('.')[1] == '0')
                                    ? total.split('.')[0]
                                    : total,
                                '',
                              ],
                              colores,
                              2,
                              false,
                              extraWid: Botones.btnRctMor(
                                'Añadir comentario',
                                Icons.comment_rounded,
                                false,
                                () => {
                                  comTit = listaProd[index].nombre,
                                  comid = index,
                                  controller.text = comentarios[index],
                                  context.read<Ventanas>().emergente(true),
                                },
                                size: 15,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  [
                    Botones.btnCirRos(
                      'No',
                      () => {
                        listaProd.clear(),
                        comentarios.clear(),
                        ventana.tabla(false),
                      },
                    ),
                    Botones.btnCirRos(
                      'Si',
                      () async => await addOrden(context),
                    ),
                  ],
                );
              },
            ),
            Consumer2<Ventanas, Carga>(
              builder: (context, ventana, carga, child) {
                return Ventanas.ventanaEmergente(
                  'Comentario para: $comTit',
                  'Cancelar',
                  'Guardar',
                  () => context.read<Ventanas>().emergente(false),
                  () => {
                    if (controller.text.isNotEmpty &&
                        controller.text != comentarios[comid])
                      Textos.toast('Comentario añadido', false),
                    comentarios[comid] = "'${controller.text}'",
                    context.read<Ventanas>().emergente(false),
                  },
                  widget: CampoTexto.inputTexto(
                    MediaQuery.sizeOf(context).width,
                    'Comentario',
                    controller,
                    Color(0x00000000),
                    true,
                    false,
                    () => {
                      if (controller.text.isNotEmpty &&
                          controller.text != comentarios[comid])
                        Textos.toast('Comentario añadido', false),
                      comentarios[comid] = controller.text,
                      context.read<Ventanas>().emergente(false),
                    },
                    icono: Icons.comment_rounded,
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

  Widget barraDeBusqueda(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Botones.btnRctMor(
          'Abrir menú',
          Icons.menu_rounded,
          false,
          () => Scaffold.of(context).openDrawer(),
          size: 35,
        ),
        Botones.btnRctMor(
          'Revisar orden',
          Icons.task_rounded,
          false,
          () async => {
            context.read<Carga>().cargaBool(true),
            generarTabla(context),
            if (context.mounted) context.read<Carga>().cargaBool(false),
          },
          size: 35,
        ),
        Container(
          width: MediaQuery.of(context).size.width * .775,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Consumer<Tablas>(
            builder: (context, tablas, child) {
              return CampoTexto.barraBusqueda(
                () async => tablas.datos(
                  await getProductos(
                    CampoTexto.filtroTexto(),
                    CampoTexto.busquedaTexto.text,
                  ),
                ),
                true,
                false,
              );
            },
          ),
        ),
      ],
    );
  }

  ListView listaPrincipal(List lista) {
    listas(lista.last.id);
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        List<Color> colores = List.filled(6, Colors.transparent);
        colores[4] = Textos.colorLimite(
          lista[index].limiteProd,
          lista[index].unidades.floor(),
        );
        String unidad = '${lista[index].unidades}';
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.1, .25, .175, .175, .08, .2],
            [
              '${lista[index].id}',
              lista[index].nombre,
              lista[index].area,
              lista[index].tipo,
              (unidad.split('.')[1] == '0') ? unidad.split('.')[0] : unidad,
              '',
            ],
            colores,
            2,
            false,
            extraWid: SizedBox(
              width: MediaQuery.sizeOf(context).width * .2,
              child: Consumer<Textos>(
                builder: (context, textos, child) {
                  return Botones.botonesSumaResta(
                    lista[index].nombre,
                    cantidad[lista[index].id - 1],
                    Textos.getColor(lista[index].id - 1),
                    () => {
                      textos.setColor(lista[index].id - 1, Color(0xFFFF0000)),
                      if ((cantidad[lista[index].id - 1] - 1) > -1)
                        {
                          textos.setColor(
                            lista[index].id - 1,
                            Color(0xFFFDC930),
                          ),
                          cantidad[lista[index].id - 1] -= 1,
                        },
                    },
                    () => {
                      textos.setColor(lista[index].id - 1, Color(0xFFFDC930)),
                      cantidad[lista[index].id - 1] += 1,
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
