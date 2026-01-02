import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/historial_model.dart';
import 'package:inventarios/pages/historial_info.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';

class Historial extends StatefulWidget {
  final StatefulWidget ruta;

  const Historial({super.key, required this.ruta});

  @override
  State<Historial> createState() => _HistorialState();
}

Future<List<HistorialModel>> getHistorial(String fecha, String filtro) async =>
    await HistorialModel.getHistorial(fecha, filtro);

class _HistorialState extends State<Historial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: RecDrawer.drawer(context, [
        Consumer<Carga>(
          builder: (ctx, carga, child) {
            return Botones.icoCirMor(
              "Nueva orden",
              Icons.add_shopping_cart_rounded,
              false,
              () async => {
                carga.cargaBool(true),
                if (CampoTexto.seleccionFiltro == Filtros.fecha)
                  {CampoTexto.seleccionFiltro = Filtros.id},
                await RecDrawer.salidaOrdenes(context),
              },
              () => Textos.toast("Espera a que los datos carguen.", false),
              Carga.getValido(),
            );
          },
        ),
        Consumer<Carga>(
          builder: (context, carga, child) {
            return Botones.icoCirMor(
              "Ver almacen",
              Icons.inventory_rounded,
              true,
              () => {
                carga.cargaBool(true),
                if (CampoTexto.seleccionFiltro == Filtros.fecha)
                  {CampoTexto.seleccionFiltro = Filtros.id},
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => widget.ruta),
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
                          [.2, .1, .25, .175, .125],
                          ["Fecha", "id", "Nombre", "Area", "Movimientos"],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 97,
                          child: Consumer<Tablas>(
                            builder: (context, tablas, child) {
                              return Tablas.listaFutura(
                                listaPrincipal,
                                "No hay movimientos registrados.",
                                "No hay coincidencias.",
                                () => getHistorial(
                                  CampoTexto.busquedaTexto.text,
                                  CampoTexto.filtroTexto(false),
                                ),
                                accionRefresh: () async => tablas.datos(
                                  await getHistorial(
                                    CampoTexto.busquedaTexto.text,
                                    CampoTexto.filtroTexto(false),
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
                () async => tablas.datos(
                  await getHistorial(
                    CampoTexto.busquedaTexto.text,
                    CampoTexto.filtroTexto(false),
                  ),
                ),
                false,
                true,
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
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.2, .1, .25, .175, .125],
            [
              lista[index].fecha,
              lista[index].id,
              lista[index].nombre,
              lista[index].area,
              "${lista[index].entradas.length}",
            ],
            [],
            1,
            true,
            extra: () async => {
              await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text),
              if (context.mounted)
                {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistorialInfo(
                        historialInfo: lista[index],
                        ruta: widget.ruta,
                      ),
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
