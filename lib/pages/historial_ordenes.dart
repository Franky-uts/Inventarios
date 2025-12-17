import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/orden_model.dart';
import 'package:inventarios/pages/orden_salida.dart';
import 'package:provider/provider.dart';
import '../services/local_storage.dart';

class HistorialOrdenes extends StatefulWidget {
  const HistorialOrdenes({super.key});

  @override
  State<HistorialOrdenes> createState() => _HistorialOrdenesState();
}

class _HistorialOrdenesState extends State<HistorialOrdenes> {
  String filtro = "id";
  List<Color> colores = [
    Color(0xFF8A03A9),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<OrdenModel>> getOrdenes() async =>
      await OrdenModel.getOrdenes(filtro, LocalStorage.local('locación'));

  Future<void> filtroTexto(int valor) async {
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
    }
    context.read<Tablas>().datos(await getOrdenes());
  }

  void cambiarEstado() {
    String mensaje;
    mensaje = "La orden no se puede cancelar.";
    if (context.read<VenDatos>().estVen() == "En proceso") {
      mensaje = "";
      context.read<Ventanas>().emergente(true);
    } else if (context.read<VenDatos>().estVen() == "Cancelado" ||
        context.read<VenDatos>().estVen() == "Denegado") {
      mensaje = "La orden ya esta cencelada.";
    }
    if (mensaje.isNotEmpty) {
      Textos.toast(mensaje, false);
    }
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
                          () => getOrdenes(),
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
                    [.25, .125, .175, .125, .125],
                    [
                      "Nombre del articulo",
                      "Tipo",
                      "Área",
                      "Cant. ordenada",
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
                          [.25, .125, .175, .125, .125],
                          [
                            venDatos.artVen(index),
                            venDatos.tipVen(index),
                            venDatos.areVen(index),
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
                    Botones.btnCirRos("Cancelar", () => cambiarEstado()),
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
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }

  Widget opciones(BuildContext ctx) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Consumer2<Tablas, Carga>(
        builder: (ctx, tablas, carga, child) {
          List<Widget> filtroList = [];
          filtroList.add(
            Botones.btnRctMor(
              "Regresar",
              35,
              Icons.arrow_back_rounded,
              false,
              () => {
                carga.cargaBool(true),
                Navigator.pushReplacement(
                  ctx,
                  MaterialPageRoute(builder: (context) => OrdenSalida()),
                ),
                carga.cargaBool(false),
              },
            ),
          );
          List<String> txt = ["id", "Estado", "Remitente"];
          List<IconData> icono = [
            Icons.numbers_rounded,
            Icons.query_builder_rounded,
            Icons.perm_identity_rounded,
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
        for (int i = 0; i < 5; i++) {
          coloresLista.add(Colors.transparent);
        }
        coloresLista[2] = Textos.colorEstado(lista[index].estado);
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
            coloresLista,
            true,
            () => {
              context.read<VenDatos>().setDatos(
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
              context.read<Ventanas>().tabla(true),
            },
          ),
        );
      },
    );
  }
}
