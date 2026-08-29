import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/articulos_model.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/add_articulo.dart';
import 'package:inventarios/pages/articulo.dart';
import 'package:provider/provider.dart';

//Esta es una página principal encargada de mostrar todos los artículos
//registrados en la base de datos, los artículos que se muestran se pueden
//filtrar por búsquedas y se pueden ordenar por id, nombre, área o tipo, se
//puede presionar sobre un artículo y ver su información más a detalle con la
//posibilidad de editar ciertos campos.
class Articulos extends StatefulWidget {
  const Articulos({super.key});

  @override
  State<Articulos> createState() => _ArticulosState();
}

class _ArticulosState extends State<Articulos> {
  Future<List<ArticulosModel>> getArticulos(
    String filtro,
    String busqueda,
  ) async => await ArticulosModel.getArticulos(filtro, busqueda);

  //Esta es una función que se encarga de obtener el id del artículo
  //seleccionado en la lista y con este se pida la información del artículo en
  //la base de datos para mostrarlo a detalle en una ventana, en caso de que
  //suceda algún error por parte del servidor se abortara el proceso y se le
  //hará conocer al usuario por medio de toast.
  Future<void> getArticuloInfo(BuildContext ctx, int id) async {
    ctx.read<Carga>().cargaBool(true);
    ArticulosModel articulo = await ArticulosModel.getArticulo(id);
    if (articulo.mensaje.isEmpty) {
      //await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text);
      if (ctx.mounted) {
        ctx.read<Articulo>().articulo(articulo);
        ctx.read<Articulo>().art(true);
      }
    } else {
      Textos.toast(articulo.mensaje);
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  //Método que se encarga de obtener las listas de tipos y áreas que requiere la
  //página encargada a añadir artículos a la base de datos, en caso de que
  //alguna petición tenga algún error entonces se abortara el cambio de página y
  //se le informara el error al usuario por medio de un mensaje toast.
  Future<void> _getListas(BuildContext ctx) async {
    String texto = '';
    ctx.read<Carga>().cargaBool(true);
    Navigator.of(ctx).pop();
    List tipos = await ProductoModel.getTipos();
    List areas = await ProductoModel.getAreas();
    if (tipos.last.split(': ')[0] == 'Error') texto = tipos.last.split(': ')[1];
    if (areas.last.split(': ')[0] == 'Error') texto = areas.last.split(': ')[1];
    (texto.isNotEmpty)
        ? Textos.toast(texto)
        : {
            //await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text),
            if (ctx.mounted)
              Navigator.of(ctx).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      Addarticulo(listaArea: areas, listaTipo: tipos),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.ease)),
                          ),
                          child: child,
                        );
                      },
                ),
              ),
          };
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
      drawer: RecDrawer.drawer(context, [
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Añadir un artículo',
              Icons.edit_note_rounded,
              () async => await _getListas(context),
              () => Textos.toast('Espera a que los datos carguen.'),
              false,
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Descargar articulos',
              Icons.download_rounded,
              () async => await RecDrawer.articulosExcel(context),
              () => Textos.toast('Espera a que los datos carguen.'),
              false,
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Escanear artículo',
              Icons.barcode_reader,
              () async => RecDrawer.scanArticulo(context),
              () => Textos.toast('Espera a que los datos carguen.'),
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
            Builder(
              builder: (context) => SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    barraSuperior(context),
                    Tablas.contenedorInfo(
                      MediaQuery.sizeOf(context).width,
                      [.1, .4, .2, .2],
                      ['id', 'Nombre', 'Área', 'Tipo'],
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
                            () => getArticulos(
                              CampoTexto.filtroTexto(),
                              CampoTexto.busquedaTexto.text,
                            ),
                            accionRefresh: () async => tablas.datos(
                              await getArticulos(
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
              ),
            ),
            Consumer<Articulo>(
              builder: (context, articulo, child) {
                return articulo.articuloInfo(context);
              },
            ),
            Consumer2<Ventanas, Carga>(
              builder: (context, ventanas, carga, child) {
                return Ventanas.ventanaScan(
                  context,
                  () => ventanas.scan(false),
                  (texto) => RecDrawer.rutaArticulo(texto, context),
                );
              },
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }

  //Componente encargado de separar componentes son relación a la tabla en
  //~exacto~ una barra superior, se compone de un botón para la barra lateral y
  //una barra de búsqueda con un botón para los filtros.
  Widget barraSuperior(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
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
          Container(
            width: MediaQuery.of(context).size.width * .875,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Consumer2<Tablas, CampoTexto>(
              builder: (context, tablas, campoTexto, child) {
                return CampoTexto.barraBusqueda(
                  () async => tablas.datos(
                    await getArticulos(
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

  //Componente que regresa una lista de artículos, al momento de presionar un
  //artículo se abrirá una ventana con información más detallada del artículo,
  //con la posibilidad de editar ciertos datos si así se requiere.
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
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.1, .4, .2, .2],
            [
              '${lista[index].id}',
              lista[index].nombre,
              lista[index].area,
              lista[index].tipo,
            ],
            maxLines: 2,
            extra: () async => await getArticuloInfo(context, lista[index].id),
          ),
        );
      },
    );
  }
}
