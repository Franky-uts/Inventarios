import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/models/registro_model.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';

//Esta es una página principal encargada de mostrar todos los productos
//registrados en la base de datos con base a al almacén en que se encuentra
//registrado el usuario, los productos que se muestran se pueden filtrar por
//búsquedas y se pueden ordenar por id, nombre, área o tipo.
class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  List<TextEditingController> controllerUni = [];
  List<TextEditingController> controllerCon = [];
  bool valido = false;
  int textoVentana = 0;

  Future<List<ProductoModel>> getProductos(
    String filtro,
    String busqueda,
  ) async => await ProductoModel.getProductos(filtro, busqueda);

  //Método que se encarga de llenar la lista de controladores, la lista tendrá
  //el mismo tamaño que el último id en el almacén, una lista se dedica para
  //registrar las unidades y otro para los contenedores.
  void listas(int length) {
    if (controllerUni.isEmpty) {
      for (int i = 0; i < length; i++) {
        controllerUni.add(TextEditingController(text: ''));
      }
    }
    if (controllerCon.isEmpty) {
      for (int i = 0; i < length; i++) {
        controllerCon.add(TextEditingController(text: ''));
      }
    }
  }

  //Método encargado de guardar las unidades y contenedores de los diferentes
  //productos de forma local.
  void guardarregistro(BuildContext ctx) {
    List<String> unidades = [];
    for (TextEditingController controller in controllerUni) {
      unidades.add(controller.text);
    }
    LocalStorage.setLista('unidades', unidades);
    LocalStorage.setLista('cajas', unidades);
    Textos.toast('Se guardo el reporte correctamente');
  }

  //Método encargado de enviar las unidades y contenedores de diferentes
  //productos al servidor para crear un registro en la base de datos, espera la
  //respuesta de la petición y la muestra al usuario en forma de toast.
  void enviarRegistro(BuildContext ctx) async {
    List<ProductoModel> listaProductos = await getProductos('id', '');
    List<int> idProductos = [];
    List<double> unidades = [];
    List<double> cajas = [];
    for (ProductoModel prod in listaProductos) {
      String uni = controllerUni[prod.id - 1].text;
      String cont = controllerCon[prod.id - 1].text;
      if (uni.isNotEmpty) {
        (uni.split('.').length < 2)
            ? unidades.add(double.parse('$uni.0'))
            : unidades.add(double.parse(uni));
        if (cont.isEmpty) {
          cajas.add(0.0);
        }
      }
      if (cont.isNotEmpty) {
        (cont.split('.').length < 2)
            ? cajas.add(double.parse('$cont.0'))
            : cajas.add(double.parse(cont));
        if (uni.isEmpty) {
          unidades.add(0.0);
        }
      }
      if (uni.isNotEmpty || cont.isNotEmpty) {
        idProductos.add(prod.id);
      }
    }
    String mensaje = 'Error: Los valores no son válidos.';
    if (idProductos.isNotEmpty) {
      mensaje = await RegistroModel.registroCompleto(
        idProductos,
        unidades,
        cajas,
      );
      valido = false;
    }
    if (mensaje.split(':')[0] != 'Error') {
      LocalStorage.eliminar('unidades');
      LocalStorage.eliminar('cajas');
      for (ProductoModel prod in listaProductos) {
        controllerUni[prod.id - 1].text = '';
        controllerCon[prod.id - 1].text = '';
      }
    }
    Textos.toast(mensaje);
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
              'Reiniciar registro',
              Icons.refresh_rounded,
              () => {
                Navigator.of(context).pop(),
                textoVentana = 0,
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
              'Guardar información',
              Icons.save_rounded,
              () => guardarregistro(ctx),
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
                    Tablas.contenedorInfo(
                      MediaQuery.sizeOf(context).width,
                      //[.1, .3, .2, .2, .15],
                      [.075, .275, .2, .2, .1, .1],
                      ['id', 'Nombre', 'Área', 'Tipo', 'Und./Kg.', 'Cont.'],
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
              ),
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
                return Ventanas.ventanaEmergente(
                  [
                    '¿Seguro quieres comenzar de nuevo?',
                    '¿Seguro quieres enviar el reporte? Una vez enviado, no se puede modificar.',
                  ][textoVentana],
                  'No, volver',
                  'Si, continuar',
                  () => ventanas.emergente(false),
                  [
                    () async => {
                      ventanas.emergente(false),
                      carga.cargaBool(true),
                      for (int i = 0; i < controllerUni.length; i++)
                        {controllerUni[i].text = ''},
                      if (context.mounted) carga.cargaBool(false),
                    },
                    () async => {
                      ventanas.emergente(false),
                      carga.cargaBool(true),
                      enviarRegistro(context),
                      if (context.mounted) carga.cargaBool(false),
                    },
                  ][textoVentana],
                );
              },
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }

  //Componente encargado de separar componentes son relación a la tabla en ~que
  //listo eres~ una barra superior, se compone de un botón para la barra
  //lateral, un botón para enviar las múltiples entradas y salidas y una barra
  //de búsqueda con un botón para los filtros.
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
              for (int i = 0; i < controllerUni.length; i++)
                {
                  if (controllerUni[i].text.isNotEmpty)
                    {
                      if (int.parse(controllerUni[i].text) > 0) {valido = true},
                    },
                  if (controllerCon[i].text.isNotEmpty)
                    {
                      if (int.parse(controllerCon[i].text) > 0) {valido = true},
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

  //Componente que regresa una lista de productos con 2 campos de texto, uno
  //corresponde a las unidades y otra los contenedores.
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
            [.075, .275, .2, .2, .1, .1],
            [
              "${lista[index].id}",
              lista[index].nombre,
              lista[index].area,
              lista[index].tipo,
              Consumer<Textos>(
                builder: (context, textos, child) {
                  return CampoTexto.inputTexto(
                    MediaQuery.sizeOf(context).width * .13,
                    '',
                    '0',
                    controllerUni[lista[index].id - 1],
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
                    MediaQuery.sizeOf(context).width * .13,
                    '',
                    '0',
                    controllerCon[lista[index].id - 1],
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
            ],
            maxLines: 2,
          ),
        );
      },
    );
  }
}
