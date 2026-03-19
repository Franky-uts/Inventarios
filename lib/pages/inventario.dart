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
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';

class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  List<TextEditingController> controllerUni = [];
  int textoVentana = 0;

  Future<List<ProductoModel>> getProductos(
    String filtro,
    String busqueda,
  ) async => await ProductoModel.getProductos(filtro, busqueda);

  void listas(int length) {
    List<String> unidades = (LocalStorage.localLista('unidades') != null)
        ? LocalStorage.localLista('unidades')!
        : List.filled(length, '', growable: true);
    for (String cantidad in unidades) {
      controllerUni.add(TextEditingController(text: cantidad));
    }
  }

  void guardarregistro(BuildContext ctx) {
    List<String> unidades = [];
    for (TextEditingController controller in controllerUni) {
      unidades.add(controller.text);
    }
    LocalStorage.setLista('unidades', unidades);
    Textos.toast('Se guardo el reporte correctamente', true);
  }

  void enviarRegistro(BuildContext ctx) async {
    List<ProductoModel> listaProductos = await getProductos('id', '');
    List<double> unidades = [];
    for (ProductoModel producto in listaProductos) {
      String uni = controllerUni[producto.id - 1].text;
      controllerUni[producto.id - 1].text = '';
      (uni.isNotEmpty)
          ? (uni.split('.').length < 2)
                ? unidades.add(double.parse('$uni.0'))
                : unidades.add(double.parse(uni))
          : unidades.add(0.0);
    }
    LocalStorage.eliminar('unidades');
    Textos.toast('Se envio el reporte correctamente', true);
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
              'Reiniciar registro',
              Icons.refresh_rounded,
              () => {
                Navigator.of(context).pop(),
                textoVentana = 0,
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
              'Guardar información',
              Icons.save_rounded,
              () => guardarregistro(ctx),
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
                    Tablas.contenedorInfo(
                      MediaQuery.sizeOf(context).width,
                      [.1, .3, .2, .2, .15],
                      ['id', 'Nombre', 'Área', 'Tipo', 'Unidades/Kilos'],
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
                  () async => {
                    ventanas.emergente(false),
                    carga.cargaBool(true),
                    [
                      () async => {
                        for (int i = 0; i < controllerUni.length; i++)
                          {controllerUni[i].text = ''},
                      },
                      () async => enviarRegistro(context),
                    ][textoVentana],
                    if (context.mounted) carga.cargaBool(false),
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
    );
  }

  ListView listaPrincipal(List lista, ScrollController controller) {
    if (controllerUni.isEmpty) {
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
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.1, .3, .2, .2, .15],
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
                    true,
                    false,
                    () => {},
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
            [],
            2,
          ),
        );
      },
    );
  }
}
