import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/empleado_view.dart';
import 'package:inventarios/pages/historial.dart';
import 'package:inventarios/pages/producto.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:inventarios/components/botones.dart';
import 'package:provider/provider.dart';

class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<ProductoModel>> getProductos(
    String filtro,
    String busqueda,
  ) async => await ProductoModel.getProductos(filtro, busqueda);

  Future<void> getProductoInfo(BuildContext ctx, int id) async {
    ctx.read<Carga>().cargaBool(true);
    ProductoModel producto = await ProductoModel.getProducto(id);
    (producto.mensaje.isEmpty)
        ? {
            await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text),
            if (ctx.mounted)
              RecDrawer.pushAnim(
                Producto(productoInfo: producto, ruta: Inventario()),
                ctx,
              ),
          }
        : Textos.toast(producto.mensaje, true);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: RecDrawer.drawer(context, [
        if (LocalStorage.local('puesto') == 'Administrador')
          Consumer<Carga>(
            builder: (ctx, carga, child) {
              return Botones.icoCirMor(
                'Cambiar de tienda',
                Icons.change_circle_rounded,
                () => {
                  Navigator.of(ctx).pop(),
                  carga.cargaBool(true),
                  ctx.read<Ventanas>().cambio(true),
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
              'Añadir un producto',
              Icons.edit_note_rounded,
              () async => {
                carga.cargaBool(true),
                await RecDrawer.getListas(context, EmpleadoView(index: 0)),
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
              'Descargar reporte',
              Icons.download_rounded,
              () async => await RecDrawer.datosExcel(context),
              () => Textos.toast('Espera a que los datos carguen.', false),
              false,
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Historial movimientos',
              Icons.history_toggle_off_rounded,
              () => {
                carga.cargaBool(true),
                if (CampoTexto.seleccionFiltro == Filtros.unidades)
                  CampoTexto.seleccionFiltro = Filtros.id,
                RecDrawer.pushAnim(Historial(ruta: Inventario()), context),
                false,
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
              'Reiniciar movimientos',
              Icons.refresh_rounded,
              () => {
                Navigator.of(context).pop(),
                context.read<Ventanas>().emergente(true),
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
              'Escanear codigo',
              Icons.barcode_reader,
              () => RecDrawer.scanProducto(context, EmpleadoView(index: 0)),
              () => Textos.toast('Espera a que los datos carguen.', false),
              false,
              Carga.getValido(),
            );
          },
        ),
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
                            'Entrada',
                            'Salida',
                            'Perdida',
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 144,
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
            if (LocalStorage.local('puesto') == 'Administrador')
              Consumer2<Ventanas, Carga>(
                builder: (context, ventanas, carga, child) {
                  return Ventanas.cambioDeTienda(
                    context,
                    () async => context.read<Tablas>().datos(
                      await getProductos(
                        CampoTexto.filtroTexto(),
                        CampoTexto.busquedaTexto.text,
                      ),
                    ),
                  );
                },
              ),
            Consumer2<Ventanas, Carga>(
              builder: (context, ventanas, carga, child) {
                return Ventanas.ventanaScan(
                  context,
                  (texto) =>
                      RecDrawer.rutaProducto(texto, Inventario(), context),
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
      shrinkWrap: true,
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        List<Color> colores = List.filled(8, Colors.transparent);
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
              (unidad.split('.').length > 1)
                  ? (unidad.split('.')[1] == '0')
                        ? unidad.split('.')[0]
                        : unidad
                  : unidad,
              lista[index].area,
              lista[index].tipo,
              (entrada.split('.').length > 1)
                  ? (entrada.split('.')[1] == '0')
                        ? entrada.split('.')[0]
                        : entrada
                  : entrada,
              (salida.split('.').length > 1)
                  ? (salida.split('.')[1] == '0')
                        ? salida.split('.')[0]
                        : salida
                  : salida,
              '${lista[index].perdidaCantidad.length}',
            ],
            colores,
            2,
            true,
            extra: () async => await getProductoInfo(context, lista[index].id),
          ),
        );
      },
    );
  }
}
