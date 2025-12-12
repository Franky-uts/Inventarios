import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/orden_model.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/orden_salida.dart';
import 'package:provider/provider.dart';
import '../services/local_storage.dart';

class HistorialOrdenes extends StatefulWidget {
  final List<ProductoModel> productosPorId;

  const HistorialOrdenes({super.key, required this.productosPorId});

  @override
  State<HistorialOrdenes> createState() => _HistorialOrdenesState();
}

class _HistorialOrdenesState extends State<HistorialOrdenes> {
  List<int> colores = [0xFF8A03A9, 0xFFFFFFFF, 0xFFFFFFFF];
  String filtro = "id";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    colores.clear();
    colores.clear();
    super.dispose();
  }

  void filtroTexto(int valor) {
    colores[1] = 0xFFFFFFFF;
    colores[0] = 0xFFFFFFFF;
    colores[2] = 0xFFFFFFFF;
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
        color = Colors.red.shade400;
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
                    [.05, .2, .2, .3, .25],
                    [
                      "id",
                      "Art. ordenados",
                      "Estado",
                      "Remitente",
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
                          () => OrdenModel.getOrdenes(
                            filtro,
                            LocalStorage.local('locación'),
                          ),
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
                    "Id de la orden: ${venDatos.idVen().toString()}",
                    "Estado: ${venDatos.estVen()}",
                  ],
                  [
                    "Destino: ${venDatos.desVen()}",
                    "Remitente: ${venDatos.remVen()}",
                    "Última modificación: ${venDatos.modVen()}",
                  ],
                  Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.3, .17, .17],
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
                          [.3, .17, .17],
                          [
                            venDatos.artVen(index),
                            venDatos.canVen(index).toString(),
                            venDatos.canCubVen(index).toString(),
                          ],
                          [],
                          false,
                          null,
                        ),
                      );
                    },
                  ),
                  [
                    Botones.btnCirRos("Cerrar", () => ventana.tabla(false)),
                    Botones.btnCirRos(
                      "Cancelar",
                      () => {
                        if (venDatos.estVen() == "En proceso")
                          {ventana.emergente(true)}
                        else if (venDatos.estVen() == "Cancelado" ||
                            venDatos.estVen() == "Denegado")
                          {Textos.toast("La orden ya esta cencelada.", false)}
                        else
                          {
                            Textos.toast(
                              "La orden no se puede cancelar.",
                              false,
                            ),
                          },
                      },
                    ),
                  ],
                );
              },
            ),
            Consumer3<Ventanas, Carga, VenDatos>(
              builder: (context, ventana, carga, venDatos, child) {
                return Ventanas.ventanaEmergente(
                  "¿Segur@ que quieres cancelar la orden?",
                  "No, volver",
                  "Si, cancelalo",
                  () => ventana.emergente(false),
                  () async => {
                    carga.cargaBool(true),
                    ventana.tabla(false),
                    Textos.toast(
                      await OrdenModel.editarOrden(
                        venDatos.idVen(),
                        "Estado",
                        "Cancelado",
                      ),
                      false,
                    ),
                    carga.cargaBool(false),
                    ventana.emergente(false),
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
      child: Consumer3<Tablas, Carga, Ventanas>(
        builder: (context, tablas, carga, ventanas, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Botones.btnRctMor(
                "Regresar",
                35,
                Icons.arrow_back_rounded,
                false,
                () => {
                  carga.cargaBool(true),
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrdenSalida(productosPorId: widget.productosPorId),
                    ),
                  ),
                  ventanas.emergente(false),
                  ventanas.tabla(false),
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
                      tablas.datos(
                        await OrdenModel.getOrdenes(
                          filtro,
                          LocalStorage.local('locación'),
                        ),
                      ),
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
                      tablas.datos(
                        await OrdenModel.getOrdenes(
                          filtro,
                          LocalStorage.local('locación'),
                        ),
                      ),
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
                      tablas.datos(
                        await OrdenModel.getOrdenes(
                          filtro,
                          LocalStorage.local('locación'),
                        ),
                      ),
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
        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: 40,
          decoration: BoxDecoration(color: Colors.white),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.05, .2, .2, .3, .25],
            [
              lista[index].id.toString(),
              lista[index].articulos.length.toString(),
              lista[index].estado,
              lista[index].remitente,
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
              context.read<VenDatos>().setDatos(
                lista[index].articulos,
                lista[index].cantidades,
                lista[index].cantidadesCubiertas,
                lista[index].id.toString(),
                lista[index].remitente,
                lista[index].estado,
                lista[index].ultimaModificacion,
                lista[index].destino,
              ),
              context.read<Ventanas>().tabla(true),
            },
          ),
        );
      },
    );
  }
}
