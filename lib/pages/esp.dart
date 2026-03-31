import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/producto.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:inventarios/components/botones.dart';
import 'package:provider/provider.dart';

class ESP extends StatefulWidget {
  const ESP({super.key});

  @override
  State<ESP> createState() => _ESPState();
}

class _ESPState extends State<ESP> {
  List<TextEditingController> controllerSal = [];
  List<TextEditingController> controllerEnt = [];
  int textoVentana = 0;
  ProductoModel producto = ProductoModel.dummy('');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void listas(int length) {
    List<String> entradas = (LocalStorage.localLista('entradas') != null)
        ? LocalStorage.localLista('entradas')!
        : List.filled(length, '', growable: true);
    List<String> salidas = (LocalStorage.localLista('salidas') != null)
        ? LocalStorage.localLista('salidas')!
        : List.filled(length, '', growable: true);
    for (String cantidad in salidas) {
      controllerSal.add(TextEditingController(text: cantidad));
    }
    for (String cantidad in entradas) {
      controllerEnt.add(TextEditingController(text: cantidad));
    }
  }

  void enviarMovimientos(BuildContext ctx) async {
    List<ProductoModel> listaProductos = await getProductos('id', '');
    List<int> idProductos = [];
    List<double> entradas = [];
    List<double> salidas = [];
    for (ProductoModel prod in listaProductos) {
      String ent = controllerEnt[prod.id - 1].text;
      String sal = controllerSal[prod.id - 1].text;
      if (ent.isNotEmpty) {
        (ent.split('.').length < 2)
            ? entradas.add(double.parse('$ent.0'))
            : entradas.add(double.parse(ent));
        if (sal.isEmpty) {
          entradas.add(0.0);
        }
      }
      if (sal.isNotEmpty) {
        (sal.split('.').length < 2)
            ? salidas.add(double.parse('$sal.0'))
            : salidas.add(double.parse(sal));
        if (ent.isEmpty) {
          salidas.add(0.0);
        }
      }
      if (ent.isNotEmpty || sal.isNotEmpty) {
        idProductos.add(prod.id);
      }
    }
    String mensaje = await ProductoModel.guardarESCompleto(
      idProductos,
      entradas,
      salidas,
    );
    if (mensaje.split(':')[0] != 'Error') {
      LocalStorage.eliminar('entradas');
      LocalStorage.eliminar('salidas');
      for (ProductoModel prod in listaProductos) {
        controllerEnt[prod.id - 1].text = '';
        controllerSal[prod.id - 1].text = '';
      }
    }
    Textos.toast('Se envio el reporte correctamente', true);
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
              {
                ctx.read<Producto>().setProducto(producto),
                ctx.read<Producto>().producto(true),
              },
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
                await RecDrawer.getListas(context),
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
        /*Consumer<Carga>(
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
        ),*/
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Reiniciar movimientos',
              Icons.refresh_rounded,
              () => {
                Navigator.of(context).pop(),
                textoVentana = 2,
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
              () => RecDrawer.scanProducto(context),
              () => Textos.toast('Espera a que los datos carguen.', false),
              true,
              Carga.getValido(),
            );
          },
        ),
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
              true,
              Carga.getValido(),
            );
          },
        ),*/
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
                          [.075, .25, .075, .175, .15, .1, .1, .075],
                          [
                            'id',
                            'Nombre',
                            'Unidades',
                            'Área',
                            'Tipo',
                            'Entrada',
                            'Salida',
                            'Información',
                          ],
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
            Consumer<Producto>(
              builder: (context, producto, child) {
                return producto.productoInfo();
              },
            ),
            Consumer2<Ventanas, Carga>(
              builder: (context, ventanas, carga, child) {
                return Ventanas.ventanaEmergente(
                  [
                    '¿Seguro quieres establecer todas las entradas, salidas y perdidas en 0?',
                    '¿Seguro quieres guardar los movimientos? Una vez enviados, no se pueden modificar.',
                    '¿Seguro quieres comenzar de nuevo?',
                    producto.nombre,
                  ][textoVentana],
                  (textoVentana != 3) ? 'No, volver' : 'Cerrar',
                  (textoVentana != 3) ? 'Si, continuar' : '',
                  () => ventanas.emergente(false),
                  () => {
                    ventanas.emergente(false),
                    carga.cargaBool(true),
                    [
                      () async => {
                        Textos.toast(await ProductoModel.reiniciarESP(), true),
                        if (context.mounted)
                          context.read<Tablas>().datos(
                            await getProductos(
                              CampoTexto.filtroTexto(),
                              CampoTexto.busquedaTexto.text,
                            ),
                          ),
                      },
                      () async => enviarMovimientos(context),
                      () async => {
                        for (int i = 0; i < controllerEnt.length; i++)
                          {
                            controllerEnt[i].text = '',
                            controllerSal[i].text = '',
                          },
                      },
                      () => {},
                    ][textoVentana],
                    if (context.mounted) carga.cargaBool(false),
                  },
                  widget: (textoVentana == 3) ? Column(children: []) : null,
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
                  () => ventanas.scan(false),
                  (texto) => RecDrawer.rutaProducto(texto, context),
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
          Botones.btnRctMor(
            'Enviar',
            Icons.task_alt_rounded,
            false,
            () => {textoVentana = 1, context.read<Ventanas>().emergente(true)},
            size: 35,
          ),
          Container(
            width: MediaQuery.of(context).size.width * .775,
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
      ),
    );
  }

  ListView listaPrincipal(List lista, ScrollController controller) {
    if (controllerEnt.isEmpty || controllerSal.isEmpty) {
      int len = 0;
      for (var prod in lista) {
        if (prod.id > len) len = prod.id;
      }
      listas(len);
    }
    return ListView.separated(
      controller: controller,
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
        if (unidad.split('.').length > 1) {
          if (unidad.split('.')[1] == '0') unidad = unidad.split('.')[0];
        }
        if (entrada.split('.').length > 1) {
          if (entrada.split('.')[1] == '0') entrada = entrada.split('.')[0];
        }
        if (salida.split('.').length > 1) {
          if (salida.split('.')[1] == '0') salida = salida.split('.')[0];
        }
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.075, .25, .075, .175, .15, .1, .1, .075],
            [
              "${lista[index].id}",
              lista[index].nombre,
              unidad,
              lista[index].area,
              lista[index].tipo,
              Consumer<Textos>(
                builder: (context, textos, child) {
                  return CampoTexto.inputTexto(
                    MediaQuery.sizeOf(context).width * .1,
                    '',
                    entrada,
                    controllerEnt[lista[index].id - 1],
                    true,
                    false,
                    borderColor: Color(0xFF8A03A9),
                    formato: FilteringTextInputFormatter.allow(
                      RegExp(r'(^\d*\.?\d{0,3})'),
                    ),
                    inputType: TextInputType.numberWithOptions(decimal: true),
                    fontSize: 17.5,
                    align: TextAlign.center,
                  );
                },
              ),
              Consumer<Textos>(
                builder: (context, textos, child) {
                  return CampoTexto.inputTexto(
                    MediaQuery.sizeOf(context).width * .1,
                    '',
                    salida,
                    controllerSal[lista[index].id - 1],
                    true,
                    false,
                    borderColor: Color(0xFF8A03A9),
                    formato: FilteringTextInputFormatter.allow(
                      RegExp(r'(^\d*\.?\d{0,3})'),
                    ),
                    inputType: TextInputType.numberWithOptions(decimal: true),
                    fontSize: 17.5,
                    align: TextAlign.center,
                  );
                },
              ),
              Botones.btnRctMor(
                'Info. de ${lista[index].nombre}',
                Icons.info_rounded,
                false,
                () async => await getProductoInfo(context, lista[index].id),
              ),
            ],
            colores,
            2,
          ),
        );
      },
    );
  }
}
