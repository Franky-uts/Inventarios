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
import 'package:inventarios/pages/articulo_info.dart';
import 'package:inventarios/pages/ordenes.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';
import 'ordenes_inventario.dart';

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

  Future<void> getArticuloInfo(BuildContext ctx, int id) async {
    ctx.read<Carga>().cargaBool(true);
    ArticulosModel articulo = await ArticulosModel.getArticulo(id);
    (articulo.mensaje.isEmpty)
        ? {
            await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text),
            if (ctx.mounted)
              Navigator.pushReplacement(
                ctx,
                MaterialPageRoute(
                  builder: (ctx) => ArticuloInfo(articulo: articulo),
                ),
              ),
          }
        : Textos.toast(articulo.mensaje, true);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  Future<void> _getListas(BuildContext ctx) async {
    String texto = '';
    ctx.read<Carga>().cargaBool(true);
    Navigator.of(ctx).pop();
    List tipos = await ProductoModel.getTipos();
    List areas = await ProductoModel.getAreas();
    if (tipos.last.split(': ')[0] == 'Error') texto = tipos.last.split(': ')[1];
    if (areas.last.split(': ')[0] == 'Error') texto = areas.last.split(': ')[1];
    (texto.isNotEmpty)
        ? Textos.toast(texto, false)
        : {
            await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text),
            if (ctx.mounted)
              Navigator.pushReplacement(
                ctx,
                MaterialPageRoute(
                  builder: (context) =>
                      Addarticulo(listaArea: areas, listaTipo: tipos),
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
              () => Textos.toast('Espera a que los datos carguen.', false),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OrdenesInventario()),
                ),
                carga.cargaBool(false),
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
              'Ordenes',
              Icons.border_color_rounded,
              () => {
                carga.cargaBool(true),
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Ordenes()),
                ),
                carga.cargaBool(false),
              },
              () => {},
              true,
              true,
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
                      height: MediaQuery.of(context).size.height - 97,
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
            Consumer2<Ventanas, Carga>(
              builder: (context, ventanas, carga, child) {
                return Ventanas.ventanaScan(
                  context,
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

  Widget barraSuperior(BuildContext context) {
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
                false,
                false,
              );
            },
          ),
        ),
      ],
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
            [],
            2,
            true,
            extra: () async => await getArticuloInfo(context, lista[index].id),
          ),
        );
      },
    );
  }
}
