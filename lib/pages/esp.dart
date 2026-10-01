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

//Esta es una página principal encargada de mostrar todos los productos
//registrados en la base de datos con base a al almacén en que se encuentra
//registrado el usuario, los productos que se muestran se pueden filtrar por
//búsquedas y se pueden ordenar por id, nombre, área o tipo, se puede presionar
//sobre un producto y ver su información más a detalle con la posibilidad de
//editar ciertos campos y añadir las entradas, salidas y perdidas de ese día.
class ESP extends StatefulWidget {
  const ESP({super.key});

  @override
  State<ESP> createState() => _ESPState();
}

class _ESPState extends State<ESP> {
  List<TextEditingController> contrEntCont = [];
  List<TextEditingController> contrEntPaq = [];
  List<TextEditingController> contrEnt = [];
  int textoVentana = 0;
  bool valido = false;
  ProductoModel producto = ProductoModel.dummy('');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Método que se encarga de llenar la lista de controladores, la lista tendrá
  //el mismo tamaño que el último id en el almacén, una lista se dedica para
  //registrar las entradas y otro para las salidas.
  void listas(int length) {
    if (contrEnt.isEmpty) {
      for (int i = 0; i < length; i++) {
        contrEnt.add(TextEditingController(text: ''));
      }
    }
    if (contrEntPaq.isEmpty) {
      for (int i = 0; i < length; i++) {
        contrEntPaq.add(TextEditingController(text: ''));
      }
    }
    if (contrEntCont.isEmpty) {
      for (int i = 0; i < length; i++) {
        contrEntCont.add(TextEditingController(text: ''));
      }
    }
  }

  //Método encargado de enviar las entradas y salidas de diferentes productos al
  //servidor para que se actualicen en la base de datos, espera la respuesta de
  //la petición y la muestra al usuario en forma de toast.
  void enviarMovimientos(BuildContext ctx) async {
    List<ProductoModel> listaProductos = await getProductos('id', '');
    List<int> idProductos = [];
    List<double> entradasUni = [];
    List<double> entradasPaq = [];
    List<double> entradasCont = [];
    for (ProductoModel prod in listaProductos) {
      String entU = contrEnt[prod.id - 1].text;
      String entP = contrEntPaq[prod.id - 1].text;
      String entC = contrEntCont[prod.id - 1].text;
      if (entU.isNotEmpty) {
        (entU.split('.').length < 2)
            ? entradasUni.add(double.parse('$entU.0'))
            : entradasUni.add(double.parse(entU));
        if (entradasUni.last < 0) entradasUni.last = 0;
      }
      if (entP.isNotEmpty) {
        (entP.split('.').length < 2)
            ? entradasPaq.add(double.parse('$entP.0'))
            : entradasPaq.add(double.parse(entP));
        if (entradasPaq.last < 0) entradasPaq.last = 0;
      }
      if (entC.isNotEmpty) {
        (entC.split('.').length < 2)
            ? entradasCont.add(double.parse('$entC.0'))
            : entradasCont.add(double.parse(entC));
        if (entradasCont.last < 0) entradasCont.last = 0;
      }
      if (entU.isNotEmpty || entP.isNotEmpty || entC.isNotEmpty) {
        if (entU.isEmpty) entradasUni.add(0.0);
        if (entP.isEmpty) entradasPaq.add(0.0);
        if (entC.isEmpty) entradasCont.add(0.0);
        if (entradasUni.last == 0 &&
            entradasPaq.last == 0 &&
            entradasCont.last == 0) {
          entradasUni.removeLast();
          entradasPaq.removeLast();
          entradasCont.removeLast();
        } else {
          idProductos.add(prod.id);
        }
      }
    }
    String mensaje = 'Error: Los valores no son válidos.';
    if (idProductos.isNotEmpty) {
      mensaje = await ProductoModel.guardarESCompleto(
        idProductos,
        entradasUni,
        entradasPaq,
        entradasCont,
      );
      valido = false;
    }
    if (mensaje.split(':')[0] != 'Error') {
      for (ProductoModel prod in listaProductos) {
        contrEnt[prod.id - 1].text = '';
        contrEntPaq[prod.id - 1].text = '';
        contrEntCont[prod.id - 1].text = '';
      }
      mensaje = 'Se envio el reporte correctamente';
      if (ctx.mounted) {
        ctx.read<Tablas>().datos(
          await getProductos(
            CampoTexto.filtroTexto(),
            CampoTexto.busquedaTexto.text,
          ),
        );
      }
    } else {
      mensaje = mensaje.split(':')[1];
    }
    Textos.toast(mensaje);
  }

  Future<List<ProductoModel>> getProductos(
    String filtro,
    String busqueda,
  ) async => await ProductoModel.getProductos(filtro, busqueda);

  //Esta es una función que se encarga de obtener el id del producto
  //seleccionado en la lista y con este se pida la información del producto en
  //la base de datos para mostrarlo a detalle en una ventana, en caso de que
  //suceda algún error por parte del servidor se abortara el proceso y se le
  //hará conocer al usuario por medio de toast.
  Future<void> getProductoInfo(BuildContext ctx, int id) async {
    ctx.read<Carga>().cargaBool(true);
    ProductoModel producto = await ProductoModel.getProducto(id);
    (producto.mensaje.isEmpty)
        ? {
            if (ctx.mounted)
              {
                ctx.read<Producto>().setProducto(producto),
                ctx.read<Producto>().producto(true),
              },
          }
        : Textos.toast(producto.mensaje);
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
                () => Textos.toast('Espera a que los datos carguen.'),
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
              () => Textos.toast('Espera a que los datos carguen.'),
              false,
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Descargar movimientos',
              Icons.download_rounded,
              () async => await RecDrawer.datosExcel(context),
              () => Textos.toast('Espera a que los datos carguen.'),
              false,
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              'Reiniciar listas',
              Icons.refresh_rounded,
              () => {
                Navigator.of(context).pop(),
                textoVentana = 2,
                context.read<Ventanas>().emergente(true),
              },
              () => Textos.toast('Espera a que los datos carguen.'),
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
              () => Textos.toast('Espera a que los datos carguen.'),
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
                          [.05, .25, .15, .15, .1, .1, .1, .075],
                          [
                            'id',
                            'Nombre',
                            'Área',
                            'Tipo',
                            'Ent. Cont.',
                            'Ent. Paq.',
                            'Ent. Piez.',
                            'Info.',
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
                  [
                    () async => {
                      ventanas.emergente(false),
                      carga.cargaBool(true),
                      Textos.toast(await ProductoModel.reiniciarESP()),
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
                    () async => {
                      ventanas.emergente(false),
                      carga.cargaBool(true),
                      enviarMovimientos(context),
                      if (context.mounted) carga.cargaBool(false),
                    },
                    () async => {
                      ventanas.emergente(false),
                      carga.cargaBool(true),
                      for (int i = 0; i < contrEnt.length; i++)
                        {
                          contrEnt[i].text = '',
                          contrEntPaq[i].text = '',
                          contrEntCont[i].text = '',
                        },
                      if (context.mounted) carga.cargaBool(false),
                    },
                    () {},
                  ][textoVentana],

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

  //Componente encargado de separar componentes son relación a la tabla en ~ya
  //lo sabes~ una barra superior, se compone de un botón para la barra lateral,
  //un botón para enviar las múltiples entradas y salidas y una barra de
  //búsqueda con un botón para los filtros.
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
            () => {
              for (int i = 0; i < contrEnt.length; i++)
                {
                  if (contrEnt[i].text.isNotEmpty)
                    if (double.parse(contrEnt[i].text) > 0) valido = true,
                  if (contrEntPaq[i].text.isNotEmpty)
                    if (double.parse(contrEntPaq[i].text) > 0) valido = true,
                  if (contrEntCont[i].text.isNotEmpty)
                    if (double.parse(contrEntCont[i].text) > 0) valido = true,
                },
              if (valido)
                {textoVentana = 1, context.read<Ventanas>().emergente(true)}
              else
                {Textos.toast('No hay cambios.')},
            },
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //Componente que regresa una lista de productos, al momento de presionar un
  //producto se abrirá una ventana con información más detallada del producto,
  //con la posibilidad de editar ciertos datos si así se requiere y de añadir
  //entradas, salidas o perdidas de ese producto individual.
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
        String entUni = '${lista[index].entradaUni}';
        String entPaq = '${lista[index].entradaPaq}';
        String entCont = '${lista[index].entradaCont}';
        if (!(lista[index].tipo == 'Paquete' ||
            lista[index].tipo == 'Galón' ||
            lista[index].tipo == 'Litro' ||
            lista[index].tipo == 'Pieza' ||
            lista[index].tipo == 'Garrafa' ||
            lista[index].tipo == 'Kilo(s)')) {
          if (entCont.split('.').length > 1) {
            if (entCont.split('.')[1] == '0') entCont = entCont.split('.')[0];
          }
        } else {
          entCont = '-';
        }
        if (lista[index].tipo == 'Caja (Paquetes)' ||
            lista[index].tipo == 'Paquete') {
          if (entPaq.split('.').length > 1) {
            if (entPaq.split('.')[1] == '0') entPaq = entPaq.split('.')[0];
          }
        } else {
          entPaq = '-';
        }
        if (entUni.split('.').length > 1) {
          if (entUni.split('.')[1] == '0') entUni = entUni.split('.')[0];
        }
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.05, .25, .15, .15, .1, .1, .1, .075],
            [
              "${lista[index].id}",
              lista[index].nombre,
              lista[index].area,
              lista[index].tipo,
              Consumer<Textos>(
                builder: (context, textos, child) {
                  return CampoTexto.inputTexto(
                    MediaQuery.sizeOf(context).width * .1,
                    '',
                    entCont,
                    contrEntCont[lista[index].id - 1],
                    enabled:
                        (!(lista[index].tipo == 'Paquete' ||
                            lista[index].tipo == 'Galón' ||
                            lista[index].tipo == 'Litro' ||
                            lista[index].tipo == 'Pieza' ||
                            lista[index].tipo == 'Garrafa' ||
                            lista[index].tipo == 'Kilo(s)')),
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
                    entPaq,
                    contrEntPaq[lista[index].id - 1],
                    enabled:
                        (lista[index].tipo == 'Caja (Paquetes)' ||
                        lista[index].tipo == 'Paquete'),
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
                    entUni,
                    contrEnt[lista[index].id - 1],
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
            maxLines: 2,
          ),
        );
      },
    );
  }
}
