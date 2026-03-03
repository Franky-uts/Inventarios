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
  List<TextEditingController> controllerPie = [];
  List<Color> colorUni = [];
  List<Color> colorPie = [];

  Future<List<ProductoModel>> getProductos(
    String filtro,
    String busqueda,
  ) async => await ProductoModel.getProductos(filtro, busqueda);

  void listas(int length) {
    for (int i = 0; i < length; i++) {
      colorUni.add(Color(0xFF8A03A9));
      colorPie.add(Color(0xFF8A03A9));
      controllerUni.add(TextEditingController(text: '0'));
      controllerPie.add(TextEditingController(text: '0'));
    }
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
                      [.1, .275, .175, .17, .135, .135],
                      [
                        'id',
                        'Nombre',
                        //'Unidades',
                        'Área',
                        'Tipo',
                        //'Entrada',
                        //'Salida',
                        //'Perdida',
                        'Unidades/Kilos',
                        'Piezas/Gramos',
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
          'Registrar',
          Icons.task_alt_rounded,
          false,
          () => Scaffold.of(context).openDrawer(),
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
            [.1, .275, .175, .17, .27],
            [
              "${lista[index].id}",
              lista[index].nombre,
              lista[index].area,
              lista[index].tipo,
              '',
            ],
            [],
            2,
            extraWid: Consumer<Textos>(
              builder: (context, textos, child) {
                return Row(
                  children: [
                    CampoTexto.inputTexto(
                      MediaQuery.sizeOf(context).width * .135,
                      '',
                      controllerUni[lista[index].id - 1],
                      true,
                      false,
                      () => {},
                      borderColor: colorUni[lista[index].id],
                      formato: FilteringTextInputFormatter.allow(
                        RegExp(r'(^\d*\.?\d{0,3})'),
                      ),
                      inputType: TextInputType.numberWithOptions(decimal: true),
                      fontSize: 17.5,
                      align: TextAlign.center,
                    ),
                    CampoTexto.inputTexto(
                      MediaQuery.sizeOf(context).width * .135,
                      '',
                      controllerPie[lista[index].id - 1],
                      !(lista[index].tipo == 'Pieza' ||
                          lista[index].tipo == 'Litro' ||
                          lista[index].tipo == 'Galón'),
                      false,
                      () => {},
                      borderColor: colorPie[lista[index].id],
                      formato: FilteringTextInputFormatter.allow(
                        RegExp(r'(^\d*\.?\d{0,3})'),
                      ),
                      inputType: TextInputType.numberWithOptions(decimal: true),
                      fontSize: 17.5,
                      align: TextAlign.center,
                      disabledColor: Color(0xFF8A58A5),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
