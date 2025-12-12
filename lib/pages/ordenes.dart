import 'package:flutter/material.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/botones.dart';
import 'package:provider/provider.dart';
import '../models/orden_model.dart';
import '../services/local_storage.dart';

class Ordenes extends StatefulWidget {
  const Ordenes({super.key});

  @override
  State<Ordenes> createState() => _OrdenesState();
}

class _OrdenesState extends State<Ordenes> {
  static List<OrdenModel> ordenes = [];
  List<int> colores = [0xFF8A03A9, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF];
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
    ordenes.clear();
    colores.clear();
    super.dispose();
  }

  void cambiarEstado(String accion, String estado) {
    if (estado == "En proceso") {
      this.accion = accion;
      context.read<Ventanas>().emergente(true);
    } else if (estado == "Cancelado" || estado == "Denegado") {
      Textos.toast("La orden ya esta cencelada.", false);
    } else {
      Textos.toast("La orden esta finalizada.", false);
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

  void filtroTexto(int valor) {
    colores[1] = 0xFFFFFFFF;
    colores[0] = 0xFFFFFFFF;
    colores[2] = 0xFFFFFFFF;
    colores[3] = 0xFFFFFFFF;
    switch (valor) {
      case (1):
        filtro = "id";
        colores[0] = 0xFF8A03A9;
        break;
      case (2):
        filtro = "Estado";
        colores[1] = 0xFF8A03A9;
        break;
      case (3):
        filtro = "Remitente";
        colores[2] = 0xFF8A03A9;
        break;
      case (4):
        filtro = "Destino";
        colores[3] = 0xFF8A03A9;
        break;
    }
  }

  Color colorEstado(String estado) {
    late Color color;
    switch (estado) {
      case ('En proceso'):
        color = Colors.blue.shade200;
        break;
      case ('Finalizado'):
        color = Colors.green.shade200;
        break;
      case ('Cancelado'):
        color = Colors.red.shade200;
        break;
      case ('Denegado'):
        color = Colors.red.shade300;
        break;
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          () => OrdenModel.getAllOrdenes(filtro),
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
                    [.35, .175, .2],
                    [
                      "Nombre del articulo",
                      "Cantidad ordenada",
                      "Cantidad cubierta",
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
                          [.35, .175, .2],
                          [
                            venDatos.artVen(index).toString(),
                            venDatos.canVen(index).toString(),
                            "",
                          ],
                          [],
                          false,
                          SizedBox(
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
                                          {textos.setColor(index, 0xFFFF0000)},
                                      },
                                  },
                                  () => {
                                    if (venDatos.canCubVen(index) <
                                            venDatos.canVen(index) &&
                                        venDatos.estVen() == "En proceso")
                                      {
                                        textos.setColor(index, 0xFF8A03A9),
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
                        if (cerrarGuardar == "Cerrar")
                          {context.read<Ventanas>().tabla(false)}
                        else
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
                    if (accion == "guardar")
                      {
                        Textos.toast(
                          await OrdenModel.editarOrden(
                            venDatos.idVen(),
                            "CantidadesCubiertas",
                            venDatos
                                .canCubVenLista()
                                .toString()
                                .replaceAll("[", "{")
                                .replaceAll("]", "}"),
                          ),
                          false,
                        ),
                      }
                    else
                      {
                        Textos.toast(
                          await OrdenModel.editarOrden(
                            venDatos.idVen(),
                            "Estado",
                            accion,
                          ),
                          false,
                        ),
                      },
                    if (context.mounted)
                      {
                        tablas.datos(await OrdenModel.getAllOrdenes(filtro)),
                        carga.cargaBool(false),
                        ventana.tabla(false),
                      },
                  },
                );
              },
            ),
            Consumer<Carga>(
              builder: (context, carga, child) {
                return Carga.ventanaCarga();
              },
            ),
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
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Botones.btnRctMor(
                "Cerrar sesión",
                35,
                Icons.logout_rounded,
                false,
                () => {
                  Textos.limpiarLista(),
                  carga.cargaBool(true),
                  LocalStorage.logout(context),
                  carga.cargaBool(false),
                },
              ),
              Botones.icoRctBor(
                "ID",
                Icons.numbers_rounded,
                Color(colores[0]),
                () async => {
                  if (filtro != "id")
                    {
                      filtroTexto(1),
                      tablas.datos(await OrdenModel.getAllOrdenes(filtro)),
                    },
                },
              ),
              Botones.icoRctBor(
                "Estado",
                Icons.query_builder_rounded,
                Color(colores[1]),
                () async => {
                  if (filtro != "Estado")
                    {
                      filtroTexto(2),
                      tablas.datos(await OrdenModel.getAllOrdenes(filtro)),
                    },
                },
              ),
              Botones.icoRctBor(
                "Remitente",
                Icons.perm_identity_outlined,
                Color(colores[2]),
                () async => {
                  if (filtro != "Remitente")
                    {
                      filtroTexto(3),
                      tablas.datos(await OrdenModel.getAllOrdenes(filtro)),
                    },
                },
              ),
              Botones.icoRctBor(
                "Destino",
                Icons.place_rounded,
                Color(colores[3]),
                () async => {
                  if (filtro != "Destino")
                    {
                      filtroTexto(4),
                      tablas.datos(await OrdenModel.getAllOrdenes(filtro)),
                    },
                },
              ),
            ],
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
                [
                  Colors.transparent,
                  Colors.transparent,
                  colorEstado(lista[index].estado),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                ],
                true,
                () => {
                  Textos.limpiarLista(),
                  canCubVenOrg.clear(),
                  venDatos.setDatos(
                    lista[index].articulos,
                    lista[index].cantidades,
                    lista[index].cantidadesCubiertas,
                    lista[index].id.toString(),
                    lista[index].remitente,
                    lista[index].estado,
                    lista[index].ultimaModificacion,
                    lista[index].destino,
                  ),
                  Textos.crearLista(lista[index].articulos.length, 0xFF8A03A9),
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
