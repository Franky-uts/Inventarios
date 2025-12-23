import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
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

  Future<void> _getListas(BuildContext ctx) async {
    String texto = "";
    context.read<Carga>().cargaBool(true);
    Navigator.of(context).pop();
    List tipos = await ProductoModel.getTipos();
    List areas = await ProductoModel.getAreas();
    if (tipos[0].toString().split(": ")[0] == "Error") {
      texto = tipos[0].toString().split(": ")[1];
    }
    if (areas[0].toString().split(": ")[0] == "Error") {
      texto = areas[0].toString().split(": ")[1];
    }
    if (texto.isNotEmpty) {
      Textos.toast(texto, false);
    } else {
      await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text);
      if (ctx.mounted) {
        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(
            builder: (context) =>
                Addarticulo(listaArea: areas, listaTipo: tipos),
          ),
        );
      }
    }
    if (ctx.mounted) {
      ctx.read<Carga>().cargaBool(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
      drawer: RecDrawer.drawer(context, [
        Botones.icoCirMor(
          "Añadir un artículo",
          Icons.edit_note_rounded,
          false,
          () async => {
            if (Tablas.getValido())
              {context.read<Carga>().cargaBool(true), await _getListas(context)}
            else
              {Textos.toast("Espera a que los datos carguen.", false)},
          },
        ),
        Botones.icoCirMor(
          "Escanear artículo",
          Icons.barcode_reader,
          false,
          () async => RecDrawer.scanArticulo(context),
        ),
        Botones.icoCirMor(
          "Ver almacen",
          Icons.inventory_rounded,
          false,
          () => {
            context.read<Carga>().cargaBool(true),
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrdenesInventario()),
            ),
            context.read<Carga>().cargaBool(false),
          },
        ),
        Botones.icoCirMor(
          "Ordenes",
          Icons.border_color_rounded,
          true,
          () => {
            context.read<Carga>().cargaBool(true),
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Ordenes()),
            ),
            context.read<Carga>().cargaBool(false),
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
                      ["id", "Nombre", "Área", "Tipo"],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - 97,
                      child: Consumer<Tablas>(
                        builder: (context, tablas, child) {
                          return Tablas.listaFutura(
                            listaPrincipal,
                            "No hay productos registrados.",
                            "No hay coincidencias.",
                            () => getArticulos(
                              CampoTexto.filtroTexto(false),
                              CampoTexto.busquedaTexto.text,
                            ),
                            accionRefresh: () async => tablas.datos(
                              await getArticulos(
                                CampoTexto.filtroTexto(false),
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
          "Abrir menú",
          35,
          Icons.menu_rounded,
          false,
          () => Scaffold.of(context).openDrawer(),
        ),
        Container(
          width: MediaQuery.of(context).size.width * .875,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Consumer2<Tablas, CampoTexto>(
            builder: (context, tablas, campoTexto, child) {
              return CampoTexto.barraBusqueda(
                () async => {
                  tablas.valido(CampoTexto.busquedaTexto.text.isNotEmpty),
                  tablas.datos(
                    await getArticulos(
                      CampoTexto.filtroTexto(false),
                      CampoTexto.busquedaTexto.text,
                    ),
                  ),
                },
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
          height: 40,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.1, .4, .2, .2],
            [
              lista[index].id.toString(),
              lista[index].nombre,
              lista[index].area,
              lista[index].tipo,
            ],
            [],
            true,
            extra: () async => {
              await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text),
              if (context.mounted)
                {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ArticuloInfo(articulo: lista[index]),
                    ),
                  ),
                },
            },
          ),
        );
      },
    );
  }
}
