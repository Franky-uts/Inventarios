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
  List<TextEditingController> controllerSal = [];
  List<TextEditingController> controllerEnt = [];
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
    if (controllerEnt.isEmpty) {
      for (int i = 0; i < length; i++) {
        controllerEnt.add(TextEditingController(text: ''));
      }
    }
    if (controllerSal.isEmpty) {
      for (int i = 0; i < length; i++) {
        controllerSal.add(TextEditingController(text: ''));
      }
    }
  }

  //Método encargado de enviar las entradas y salidas de diferentes productos al
  //servidor para que se actualicen en la base de datos, espera la respuesta de
  //la petición y la muestra al usuario en forma de toast.
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
          salidas.add(0.0);
        }
      }
      if (sal.isNotEmpty) {
        (sal.split('.').length < 2)
            ? salidas.add(double.parse('$sal.0'))
            : salidas.add(double.parse(sal));
        if (ent.isEmpty) {
          entradas.add(0.0);
        }
      }
      if (ent.isNotEmpty || sal.isNotEmpty) {
        idProductos.add(prod.id);
      }
    }
    String mensaje = 'Error: Los valores no son válidos.';
    if (idProductos.isNotEmpty) {
      mensaje = await ProductoModel.guardarESCompleto(
        idProductos,
        entradas,
        salidas,
      );
      valido = false;
    }
    if (mensaje.split(':')[0] != 'Error') {
      for (ProductoModel prod in listaProductos) {
        controllerEnt[prod.id - 1].text = '';
        controllerSal[prod.id - 1].text = '';
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
              'Descargar reporte',
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
                          [.075, .25, .175, .15, .1, .1, .075],
                          [
                            'id',
                            'Nombre',
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
                      for (int i = 0; i < controllerEnt.length; i++)
                        {
                          controllerEnt[i].text = '',
                          controllerSal[i].text = '',
                        },
                      if (context.mounted) carga.cargaBool(false),
                    },
                    () => {},
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
              for (int i = 0; i < controllerEnt.length; i++)
                {
                  if (controllerEnt[i].text.isNotEmpty)
                    {
                      if (int.parse(controllerEnt[i].text) > 0) {valido = true},
                    },
                  if (controllerSal[i].text.isNotEmpty)
                    {
                      if (int.parse(controllerSal[i].text) > 0) {valido = true},
                    },
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
        String entrada = '${lista[index].entrada}';
        String salida = '${lista[index].salida}';
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
            [.075, .25, .175, .15, .1, .1, .075],
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
                    entrada,
                    controllerEnt[lista[index].id - 1],
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
