import 'package:flutter/material.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/pages/articulos.dart';
import 'package:inventarios/pages/ordenes_inventario.dart';
import 'package:provider/provider.dart';
import '../models/orden_model.dart';

class Ordenes extends StatefulWidget {
  const Ordenes({super.key});

  @override
  State<Ordenes> createState() => _OrdenesState();
}

class _OrdenesState extends State<Ordenes> {
  List<Color> colores = [
    Color(0xFF8A03A9),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
  ];
  List canCubVenOrg = [];
  String cerrarGuardar = "";
  String filtro = "id";
  String accion = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    colores.clear();
    super.dispose();
  }

  Future<List<OrdenModel>> getOrdenes() async =>
      await OrdenModel.getAllOrdenes(filtro);

  void cambiarEstado(String accion, String estado) {
    String mensaje = "La orden esta finalizada.";
    if (estado == "En proceso") {
      this.accion = accion;
      mensaje = "";
      context.read<Ventanas>().emergente(true);
    } else if (estado == "Cancelado" || estado == "Denegado") {
      mensaje = "La orden ya esta cencelada.";
    }
    if (mensaje.isNotEmpty) {
      Textos.toast(mensaje, false);
    }
  }

  void _cerrarGuardar(List lista) {
    cerrarGuardar = "Cerrar";
    for (int i = 0; i < canCubVenOrg.length; i++) {
      if (lista[i] != canCubVenOrg[i]) {
        cerrarGuardar = "Guardar";
      }
    }
  }

  Future<String> guardarDatos(BuildContext ctx) async {
    String columna = "Estado";
    String datos = accion;
    if (accion == "guardar") {
      columna = "CantidadesCubiertas";
      datos = context
          .read<VenDatos>()
          .canCubVenLista()
          .toString()
          .replaceAll("[", "{")
          .replaceAll("]", "}");
    }
    datos = await OrdenModel.editarOrden(
      context.read<VenDatos>().idVen(),
      columna,
      datos,
    );
    if (accion == "guardar" && datos.split(": ")[0] != "Error") {
      canCubVenOrg.clear();
      if (ctx.mounted) {
        for (int i = 0; i < ctx.read<VenDatos>().canCubVenLista().length; i++) {
          canCubVenOrg.add(ctx.read<VenDatos>().canCubVen(i));
        }
        _cerrarGuardar(ctx.read<VenDatos>().canCubVenLista());
      }
    }
    if (datos.split(": ")[0] == "Error") {
      datos = datos.split(": ")[1];
    }
    return datos;
  }

  void filtroTexto(int valor) async {
    for (int i = 0; i < colores.length; i++) {
      colores[i] = Color(0xFFFFFFFF);
      if (i == valor) {
        colores[i] = Color(0xFF8A03A9);
      }
    }
    switch (valor) {
      case (0):
        filtro = "id";
        break;
      case (1):
        filtro = "Estado";
        break;
      case (2):
        filtro = "Remitente";
        break;
      case (3):
        filtro = "Destino";
        break;
    }
    context.read<Tablas>().datos(await getOrdenes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: RecDrawer.drawer(context, [
        Botones.icoCirMor(
          "Ver artículos",
          Icons.list,
          false,
              () => {
            context.read<Carga>().cargaBool(true),
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Articulos()),
            ),
            context.read<Carga>().cargaBool(false),
          },
        ),
        Botones.icoCirMor(
          "Ver almacen",
          Icons.inventory_rounded,
          true,
          () => {
            context.read<Carga>().cargaBool(true),
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrdenesInventario()),
            ),
            context.read<Carga>().cargaBool(false),
          },
        ),
      ]),
      backgroundColor: Color(0xFFFF5600),
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  opciones(context),
                  Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.05, .125, .15, .2, .2, .25],
                    [
                      "id",
                      "Art. ordenados",
                      "Estado",
                      "Remitente",
                      "Destino",
                      "Última modificación",
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 82,
                    child: Consumer<Tablas>(
                      builder: (context, tablas, child) {
                        return Tablas.listaFutura(
                          listaPrincipal,
                          "Todo está en orden, no hay órdenes entrantes.",
                          "No se recuperaron órdenes.",
                          () => getOrdenes(),
                          accionRefresh: () async =>
                              tablas.datos(await getOrdenes()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Consumer2<Ventanas, VenDatos>(
              builder: (context, ventana, venDatos, child) {
                return Ventanas.ventanaTabla(
                  MediaQuery.of(context).size.height,
                  MediaQuery.of(context).size.width,
                  [
                    "Id de la orden: ${venDatos.idVen()}",
                    "Estado: ${venDatos.estVen()}",
                  ],
                  [
                    "Destino: ${venDatos.desVen()}",
                    "Remitente: ${venDatos.remVen()}",
                    "Última modificación: ${venDatos.modVen()}",
                  ],
                  Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.25, .1, .125, .1, .2],
                    [
                      "Nombre del articulo",
                      "Tipo",
                      "Área",
                      "Cant. orden",
                      "Cant. cubierta",
                    ],
                  ),
                  ListView.separated(
                    itemCount: venDatos.length(),
                    scrollDirection: Axis.vertical,
                    separatorBuilder: (context, index) => Container(
                      height: 2,
                      decoration: BoxDecoration(color: Color(0xFFFDC930)),
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 40,
                        decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                        child: Tablas.barraDatos(
                          MediaQuery.sizeOf(context).width,
                          [.25, .1, .125, .1, .2],
                          [
                            venDatos.artVen(index).toString(),
                            venDatos.tipVen(index),
                            venDatos.areVen(index),
                            venDatos.canVen(index).toString(),
                            "",
                          ],
                          [],
                          false,
                          extraWid: SizedBox(
                            width: MediaQuery.sizeOf(context).width * .2,
                            child: Consumer<Textos>(
                              builder: (context, textos, child) {
                                return Botones.botonesSumaResta(
                                  venDatos.artVen(index),
                                  venDatos.canCubVen(index),
                                  Textos.getColor(index),
                                  () => {
                                    if (venDatos.estVen() == "En proceso")
                                      {
                                        if (venDatos.canCubVen(index) > 0)
                                          {
                                            context
                                                .read<VenDatos>()
                                                .canCubVenSub(index),
                                            _cerrarGuardar(
                                              context
                                                  .read<VenDatos>()
                                                  .canCubVenLista(),
                                            ),
                                          }
                                        else
                                          {
                                            textos.setColor(
                                              index,
                                              Color(0xFFFF0000),
                                            ),
                                          },
                                      },
                                  },
                                  () => {
                                    if (venDatos.canCubVen(index) <
                                            venDatos.canVen(index) &&
                                        venDatos.estVen() == "En proceso")
                                      {
                                        textos.setColor(
                                          index,
                                          Color(0xFF8A03A9),
                                        ),
                                        venDatos.canCubVenAdd(index),
                                        _cerrarGuardar(
                                          venDatos.canCubVenLista(),
                                        ),
                                      },
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  [
                    Botones.btnCirRos(
                      cerrarGuardar,
                      () => {
                        context.read<Ventanas>().tabla(
                          cerrarGuardar != "Cerrar",
                        ),
                        if (cerrarGuardar != "Cerrar")
                          {cambiarEstado("guardar", venDatos.estVen())},
                      },
                    ),
                    Botones.btnCirRos(
                      "Denegar",
                      () => {cambiarEstado("denegar", venDatos.estVen())},
                    ),
                    Botones.btnCirRos(
                      "Finalizar",
                      () => {cambiarEstado("finalizar", venDatos.estVen())},
                    ),
                  ],
                );
              },
            ),
            Consumer4<Ventanas, Carga, VenDatos, Tablas>(
              builder: (context, ventana, carga, venDatos, tablas, child) {
                return Ventanas.ventanaEmergente(
                  "¿Segur@ que quieres $accion la orden?",
                  "No, volver",
                  "Si, $accion",
                  () => ventana.emergente(false),
                  () async => {
                    carga.cargaBool(true),
                    ventana.emergente(false),
                    Textos.toast(await guardarDatos(context), false),
                    carga.cargaBool(false),
                    tablas.datos(await OrdenModel.getAllOrdenes(filtro)),
                    ventana.tabla(accion == "guardar"),
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

  Widget opciones(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Consumer2<Tablas, Carga>(
        builder: (context, tablas, carga, child) {
          List<Widget> filtroList = [];
          filtroList.add(
            Botones.btnRctMor(
              "Abrir menú",
              35,
              Icons.menu_rounded,
              false,
              () => Scaffold.of(context).openDrawer(),
            ),
          );
          List<String> txt = ["id", "Estado", "Remitente", "Destino"];
          List<IconData> icono = [
            Icons.numbers_rounded,
            Icons.query_builder_rounded,
            Icons.perm_identity_rounded,
            Icons.place_rounded,
          ];
          for (int i = 0; i < txt.length; i++) {
            filtroList.add(
              Botones.icoRctBor(
                txt[i],
                icono[i],
                colores[i],
                () async => {
                  if (filtro != txt[i]) {filtroTexto(i)},
                },
              ),
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: filtroList,
          );
        },
      ),
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
        List<Color> coloresLista = [];
        for (int i = 0; i < 6; i++) {
          coloresLista.add(Colors.transparent);
        }
        coloresLista[2] = Textos.colorEstado(lista[index].estado);
        return Consumer3<Textos, VenDatos, Ventanas>(
          builder: (context, textos, venDatos, ventanas, child) {
            return Container(
              width: MediaQuery.sizeOf(context).width,
              height: 40,
              decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
              child: Tablas.barraDatos(
                MediaQuery.sizeOf(context).width,
                [.05, .125, .175, .2, .2, .25],
                [
                  lista[index].id.toString(),
                  lista[index].articulos.length.toString(),
                  lista[index].estado,
                  lista[index].remitente,
                  lista[index].destino,
                  lista[index].ultimaModificacion,
                ],
                coloresLista,
                true,
                extra: () => {
                  Textos.limpiarLista(),
                  canCubVenOrg.clear(),
                  venDatos.setDatos(
                    lista[index].articulos,
                    lista[index].cantidades,
                    lista[index].areas,
                    lista[index].tipos,
                    lista[index].cantidadesCubiertas,
                    lista[index].id.toString(),
                    lista[index].remitente,
                    lista[index].estado,
                    lista[index].ultimaModificacion,
                    lista[index].destino,
                  ),
                  Textos.crearLista(
                    lista[index].articulos.length,
                    Color(0xFF8A03A9),
                  ),
                  for (int i = 0; i < lista[index].articulos.length; i++)
                    {canCubVenOrg.add(venDatos.canCubVen(i))},
                  _cerrarGuardar(venDatos.canCubVenLista()),
                  ventanas.tabla(true),
                },
              ),
            );
          },
        );
      },
    );
  }
}
