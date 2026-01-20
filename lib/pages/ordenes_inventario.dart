import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/articulos.dart';
import 'package:inventarios/pages/historial.dart';
import 'package:inventarios/pages/ordenes.dart';
import 'package:inventarios/pages/producto.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';

class OrdenesInventario extends StatefulWidget {
  const OrdenesInventario({super.key});

  @override
  State<OrdenesInventario> createState() => _OrdenesInventarioState();
}

class _OrdenesInventarioState extends State<OrdenesInventario> {
  Future<List<ProductoModel>> getProductos(
    String filtro,
    String busqueda,
  ) async => await ProductoModel.getProductos(filtro, busqueda);

  Future<void> getProductoInfo(BuildContext ctx, int id) async {
    ctx.read<Carga>().cargaBool(true);
    ProductoModel producto = await ProductoModel.getProducto(id);
    if (producto.mensaje.isEmpty) {
      await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text);
      if (ctx.mounted) {
        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(
            builder: (context) =>
                Producto(productoInfo: producto, ruta: OrdenesInventario()),
          ),
        );
      }
    } else {
      Textos.toast(producto.mensaje, true);
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: RecDrawer.drawer(context, [
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Añadir un producto',
              Icons.edit_note_rounded,
              false,
              () async => {
                carga.cargaBool(true),
                await RecDrawer.getListas(context, OrdenesInventario()),
              },
              () => Textos.toast('Espera a que los datos carguen.', false),
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Descargar reporte',
              Icons.download_rounded,
              false,
              () async => {await RecDrawer.datosExcel(context)},
              () => Textos.toast('Espera a que los datos carguen.', false),
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Escanear producto',
              Icons.barcode_reader,
              false,
              () => RecDrawer.scanProducto(context, OrdenesInventario()),
              () => Textos.toast('Espera a que los datos carguen.', false),
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Historial movimientos',
              Icons.history_toggle_off_rounded,
              false,
              () => {
                carga.cargaBool(true),
                if (CampoTexto.seleccionFiltro == Filtros.unidades)
                  {CampoTexto.seleccionFiltro = Filtros.id},
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Historial(ruta: OrdenesInventario()),
                  ),
                ),
                carga.cargaBool(false),
              },
              () => Textos.toast('Espera a que los datos carguen.', false),
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Reiniciar movimientos',
              Icons.refresh_rounded,
              false,
              () => {
                Navigator.of(context).pop(),
                context.read<Ventanas>().emergente(true),
              },
              () => Textos.toast('Espera a que los datos carguen.', false),
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Ver artículos',
              Icons.list,
              false,
              () => {
                carga.cargaBool(true),
                if (CampoTexto.seleccionFiltro == Filtros.unidades)
                  {CampoTexto.seleccionFiltro = Filtros.id},
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Articulos()),
                ),
                carga.cargaBool(false),
              },
              () => {},
              true,
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Ordenes',
              Icons.border_color_rounded,
              true,
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
                    barraSuperior(context),
                    Column(
                      children: [
                        Tablas.contenedorInfo(
                          MediaQuery.sizeOf(context).width,
                          [.1, .25, .08, .175, .15, .075, .075, .075],
                          [
                            'id',
                            'Nombre',
                            'Unidades',
                            'Área',
                            'Tipo',
                            'Entradas',
                            'Salidas',
                            'Perdidas',
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
              builder: (context, ventanas, carga, child) {
                return Ventanas.ventanaEmergente(
                  '¿Seguro quieres establecer todas las entradas, salidas y perdidas en 0?',
                  'No, volver',
                  'Si, continuar',
                  () => ventanas.emergente(false),
                  () async => {
                    ventanas.emergente(false),
                    carga.cargaBool(true),
                    Textos.toast(await ProductoModel.reiniciarESP(), true),
                    if (context.mounted)
                      {
                        context.read<Tablas>().datos(
                          await getProductos(
                            CampoTexto.filtroTexto(),
                            CampoTexto.busquedaTexto.text,
                          ),
                        ),
                        carga.cargaBool(false),
                      },
                  },
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
                  tablas.datos(
                    await getProductos(
                      CampoTexto.filtroTexto(),
                      CampoTexto.busquedaTexto.text,
                    ),
                  ),
                },
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
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        List<Color> colores = [];
        for (int i = 0; i < 8; i++) {
          colores.add(Colors.transparent);
        }
        colores[2] = Textos.colorLimite(
          lista[index].limiteProd,
          lista[index].unidades.floor(),
        );
        String unidad = '${lista[index].unidades}';
        String entrada = '${lista[index].entrada}';
        String salida = '${lista[index].salida}';
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.1, .25, .08, .175, .15, .075, .075, .075],
            [
              "${lista[index].id}",
              lista[index].nombre,
              (unidad.split('.')[1] == '0') ? unidad.split('.')[0] : unidad,
              lista[index].area,
              lista[index].tipo,
              (entrada.split('.')[1] == '0') ? entrada.split('.')[0] : entrada,
              (salida.split('.')[1] == '0') ? salida.split('.')[0] : salida,
              '${lista[index].perdidaCantidad.length}',
            ],
            colores,
            2,
            true,
            extra: () async => getProductoInfo(context, lista[index].id),
          ),
        );
      },
    );
  }
}
