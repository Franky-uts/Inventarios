import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/perdidas_prov.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';

class InventarioProd extends StatefulWidget {
  const InventarioProd({super.key});

  @override
  State<InventarioProd> createState() => _InventarioProdState();
}

Future<List<ProductoModel>> getProductos(
  String filtro,
  String busqueda,
) async => await ProductoModel.getProductosProd(filtro, busqueda);

Future<void> ordenSalida(BuildContext ctx) async {
  StatefulWidget ruta = await RecDrawer.salidaOrdenesProd(ctx);
  if (ctx.mounted) {
    Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (ctx) => ruta));
  }
}

class _InventarioProdState extends State<InventarioProd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: RecDrawer.drawer(context, [
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              "Nueva orden",
              Icons.add_shopping_cart_rounded,
              true,
              () async => await ordenSalida(context),
              () => Textos.toast("Espera a que los datos carguen.", false),
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
                            "id",
                            "Nombre",
                            "Unidades",
                            "Área",
                            "Tipo",
                            "Entrada",
                            "Salida",
                            "Perdida",
                          ],
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
                                () => getProductos(
                                  CampoTexto.filtroTexto(true),
                                  CampoTexto.busquedaTexto.text,
                                ),
                                accionRefresh: () async => tablas.datos(
                                  await getProductos(
                                    CampoTexto.filtroTexto(true),
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
                  tablas.datos(
                    await getProductos(
                      CampoTexto.filtroTexto(true),
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
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.1, .25, .08, .175, .15, .075, .075, .075],
            [
              "${lista[index].id}",
              lista[index].nombre,
              "${lista[index].unidades}".split(".")[0],
              lista[index].area,
              lista[index].tipo,
              "${lista[index].entrada}".split(".")[0],
              "${lista[index].salida}".split(".")[0],
              "${lista[index].perdidaCantidad.length}",
            ],
            colores,
            2,
            true,
            extra: () async => {
              await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text),
              if (context.mounted)
                {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PerdidasProv(productoInfo: lista[index]),
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
