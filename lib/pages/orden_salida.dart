import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/orden_model.dart';
import 'package:provider/provider.dart';
import '../models/producto_model.dart';

//Esta es una página principal encargada de mostrar todos los productos
//registrados en la base de datos con base a al almacén en que se encuentra
//registrado el usuario, los productos que se muestran se pueden filtrar por
//búsquedas y se pueden ordenar por id, nombre, área o tipo, se puede presionar
//sobre un producto y ver su información más a detalle con la posibilidad de
//editar ciertos campos y añadir las entradas, salidas y perdidas de ese día.
class OrdenSalida extends StatefulWidget {
  const OrdenSalida({super.key});

  @override
  State<OrdenSalida> createState() => _OrdenSalidaState();
}

class _OrdenSalidaState extends State<OrdenSalida> {
  List<TextEditingController> cantidad = [];
  List<ProductoModel> listaProd = [];
  List<String> comentarios = [];
  String comTit = '';
  int comid = 0;
  bool valido = true;
  TextEditingController controller = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    listaProd.clear();
    cantidad.clear();
    comentarios.clear();
    controller.dispose();
    super.dispose();
  }

  Future<List<ProductoModel>> getProductos(
    String filtro,
    String busqueda,
  ) async => await ProductoModel.getProductos(filtro, busqueda);

  //Método que se encarga de enviar los datos relacionados para añadir una
  //orden a la base de datos, con los productos, cantidades y comentarios
  //correspondientes.
  Future<void> addOrden(BuildContext ctx) async {
    valido = true;
    List<double> cantidades = [];
    List<int> idProductos = [];
    ctx.read<Carga>().cargaBool(true);
    for (ProductoModel prod in listaProd) {
      cantidades.add(double.parse(cantidad[prod.id - 1].text));
      idProductos.add(prod.id);
    }
    for (int i = 0; i < cantidades.length; i++) {
      if (comentarios[i].isNotEmpty) comentarios[i] = "'${comentarios[i]}'";
    }
    String respuesta = await OrdenModel.postOrden(
      idProductos,
      cantidades,
      comentarios,
    );
    if (respuesta.split(': ')[0] != 'Error') {
      if (ctx.mounted) ctx.read<Ventanas>().tabla(false);
      cantidad.addAll(
        List.filled(
          cantidad.length,
          TextEditingController(text: ''),
          growable: true,
        ),
      );
      listaProd.clear();
      comentarios.clear();
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
    Textos.toast(respuesta);
  }

  //Método que se encarga de llenar la lista de controladores, la lista tendrá
  //el mismo tamaño que el último id en el almacén, una lista se dedica para
  //registrar la cantidad de ese producto que se va a ordenar.
  void listas(int length) {
    if (cantidad.isEmpty) {
      for (int i = 0; i < length; i++) {
        cantidad.add(TextEditingController(text: ''));
      }
    }
  }

  //Método que se encarga revisar las cantidades de texto ingresadas en cada
  //producto, para después ingresar esa información a una ventana con la cual
  //se confirmará la cantidad de las órdenes, en caso de que ningún campo de
  //texto tenga información, se le hará saber al usuario.
  void generarTabla(BuildContext ctx) async {
    if (valido) {
      valido = false;
      List<ProductoModel> lista = await getProductos('id', '');
      String mensaje = 'Espera a que los datos carguen.';
      listaProd.clear();
      comentarios.clear();
      if (Carga.getValido()) {
        mensaje = '';
        int j = 0;
        for (int i = 0; i < cantidad.length; i++) {
          if (cantidad[i].text.isNotEmpty &&
              double.parse(cantidad[i].text) > 0) {
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
      if (mensaje.isNotEmpty) Textos.toast(mensaje);
    }
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
                          [.1, .25, .175, .175, .1],
                          ['id', 'Nombre', 'Área', 'Tipo', 'Acciones'],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 143.5,
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
                  (listaProd.length * 44 + 120 <
                          MediaQuery.sizeOf(context).height - 100)
                      ? listaProd.length * 44 + 120
                      : MediaQuery.sizeOf(context).height - 100,
                  MediaQuery.of(context).size.width,
                  ['Productos seleccionados:'],
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
                  SizedBox(
                    height:
                        (listaProd.length * 44 <
                            MediaQuery.sizeOf(context).height - 220)
                        ? listaProd.length * 44
                        : MediaQuery.sizeOf(context).height - 220,
                    child: ListView.separated(
                      itemCount: listaProd.length,
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) => Container(
                        height: 2,
                        decoration: BoxDecoration(color: Color(0xFFFDC930)),
                      ),
                      itemBuilder: (context, index) {
                        return Consumer<Tablas>(
                          builder: (context, tablas, child) {
                            String cantUni =
                                '${listaProd[index].cantidadPorUnidad}';
                            String total =
                                '${double.parse(cantidad[listaProd[index].id - 1].text) * listaProd[index].cantidadPorUnidad}';
                            return Container(
                              width: MediaQuery.sizeOf(context).width,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                              ),
                              child: Tablas.barraDatos(
                                MediaQuery.sizeOf(context).width,
                                [.045, .215, .15, .105, .075, .075, .075, .05],
                                [
                                  "${listaProd[index].id}",
                                  listaProd[index].nombre,
                                  listaProd[index].area,
                                  listaProd[index].tipo,
                                  cantidad[listaProd[index].id - 1].text,
                                  (cantUni.split('.').length > 1)
                                      ? (cantUni.split('.')[1] == '0')
                                            ? cantUni.split('.')[0]
                                            : cantUni
                                      : cantUni,
                                  (total.split('.').length > 1)
                                      ? (total.split('.')[1] == '0')
                                            ? total.split('.')[0]
                                            : total
                                      : total,
                                  Botones.btnRctMor(
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
                                    alert: comentarios[index].isNotEmpty,
                                  ),
                                ],
                                maxLines: 2,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 2.5,
                      horizontal: 10,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      spacing: 7.5,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Textos.textoGeneral(
                          'Enviar orden:',
                          false,
                          1,
                          size: 20,
                        ),
                        Botones.btnCirRos(
                          'No',
                          () => {
                            valido = true,
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
                    ),
                  ),
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
                      Textos.toast('Comentario añadido'),
                    comentarios[comid] = controller.text,
                    context.read<Ventanas>().emergente(false),
                  },
                  widget: CampoTexto.inputTexto(
                    MediaQuery.sizeOf(context).width,
                    'Comentario',
                    '',
                    controller,
                    accion: () => {
                      if (controller.text.isNotEmpty &&
                          controller.text != comentarios[comid])
                        Textos.toast('Comentario añadido'),
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

  //Componente encargado de separar componentes son relación a la tabla en ~lo
  //conoces muy bien~ una barra superior, se compone de un botón para la barra
  //lateral, un botón para revisar la orden y una barra de búsqueda con un
  //botón para los filtros.
  Widget barraDeBusqueda(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Botones.btnRctMor(
            'Regresar',
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //Componente que regresa una lista de productos, cada producto tiene un campo
  //de texto que guarda la cantidad del producto que se quiere ordenar.
  ListView listaPrincipal(List lista, ScrollController controller) {
    listas(lista.last.id);
    return ListView.separated(
      controller: controller,
      itemCount: lista.length,
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
            [.1, .25, .175, .175, .1],
            [
              '${lista[index].id}',
              lista[index].nombre,
              lista[index].area,
              lista[index].tipo,
              Consumer<Textos>(
                builder: (ctx, textos, child) {
                  return SizedBox(
                    width: MediaQuery.sizeOf(context).width * .1,
                    child: CampoTexto.inputTexto(
                      MediaQuery.sizeOf(context).width * .1,
                      '',
                      '0',
                      cantidad[lista[index].id - 1],
                      borderColor: Color(0xFF8A03A9),
                      formato: FilteringTextInputFormatter.allow(
                        RegExp(r'(^\d*\.?\d{0,3})'),
                      ),
                      inputType: TextInputType.numberWithOptions(decimal: true),
                      fontSize: 17.5,
                      align: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
            maxLines: 2,
          ),
        );
      },
    );
  }
}
