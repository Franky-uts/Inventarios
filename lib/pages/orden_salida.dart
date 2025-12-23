import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/orden_model.dart';
import 'package:inventarios/pages/historial_ordenes.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:provider/provider.dart';
import '../models/producto_model.dart';
import '../services/local_storage.dart';

class OrdenSalida extends StatefulWidget {
  const OrdenSalida({super.key});

  @override
  State<OrdenSalida> createState() => _OrdenSalidaState();
}

class _OrdenSalidaState extends State<OrdenSalida> {
  List<int> cantidad = [];
  List<ProductoModel> listaProd = [];
  late bool lista;

  @override
  initState() {
    lista = true;
    super.initState();
  }

  @override
  void dispose() {
    listaProd.clear();
    cantidad.clear();
    super.dispose();
  }

  Future<List<ProductoModel>> getProductos(
    String filtro,
    String busqueda,
  ) async => await ProductoModel.getProductos(filtro, busqueda);

  Future<void> addOrden() async {
    List<String> articulos = [];
    List<int> cantidades = [];
    List<String> tipos = [];
    List<String> areas = [];
    for (int i = 0; i < listaProd.length; i++) {
      articulos.add(listaProd[i].nombre);
      cantidades.add(
        cantidad[int.parse(
              listaProd[i].id.substring(0, listaProd[i].id.length - 3),
            ) -
            1],
      );
      tipos.add(listaProd[i].tipo);
      areas.add(listaProd[i].area);
    }
    String respuesta = await OrdenModel.postOrden(
      articulos,
      cantidades,
      tipos,
      areas,
      "En proceso",
      LocalStorage.local('usuario'),
      LocalStorage.local('locación'),
    );
    if (respuesta.split(": ")[0] != "Error") {
      respuesta =
          "Se guardo la orden $respuesta correctamente con ${articulos.length} artículos.";
      for (int i = 0; i < cantidad.length; i++) {
        cantidad[i] = 0;
      }
      listaProd.clear();
    }
    Textos.toast(respuesta, respuesta.split(": ")[0] != "Error");
  }

  void listas(int length) {
    if (lista) {
      for (int i = 0; i < length; i++) {
        cantidad.add(0);
      }
      lista = false;
    }
  }

  void generarTabla(List<ProductoModel> lista) {
    String mensaje = "Espera a que los datos carguen.";
    if (Tablas.getValido()) {
      mensaje = "";
      for (int i = 0; i < cantidad.length; i++) {
        if (cantidad[i] > 0) {
          listaProd.add(lista[i]);
        }
      }
      if (listaProd.isEmpty) {
        mensaje = "No hay productos seleccionados.";
      }
    }
    context.read<Ventanas>().tabla(listaProd.isNotEmpty);
    if (mensaje.isNotEmpty) {
      Textos.toast(mensaje, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: RecDrawer.drawer(context, [
        Botones.icoCirMor(
          "Historial de ordenes",
          Icons.history_rounded,
          false,
          () async => {
            if (Tablas.getValido())
              {
                await LocalStorage.set(
                  'busqueda',
                  CampoTexto.busquedaTexto.text,
                ),
                if (context.mounted)
                  {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistorialOrdenes(),
                      ),
                    ),
                    context.read<Ventanas>().emergente(false),
                    context.read<Ventanas>().tabla(false),
                    context.read<Carga>().cargaBool(false),
                  },
              }
            else
              {Textos.toast("Espera a que los datos carguen.", false)},
          },
        ),
        Botones.icoCirMor(
          "Ver almacen",
          Icons.inventory_rounded,
          true,
          () => {
            Textos.limpiarLista(),
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Inventario()),
            ),
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
                  children: [
                    barraDeBusqueda(context),
                    Tablas.contenedorInfo(
                      MediaQuery.sizeOf(context).width,
                      [.1, .25, .175, .175, .08, .2],
                      ["id", "Nombre", "Área", "Tipo", "Unidades", "Acciones"],
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
                              CampoTexto.filtroTexto(false),
                              CampoTexto.busquedaTexto.text,
                            ),
                            accionRefresh: () async => tablas.datos(
                              await getProductos(
                                CampoTexto.filtroTexto(false),
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
            Consumer2<Ventanas, Carga>(
              builder: (context, ventana, carga, child) {
                return Ventanas.ventanaTabla(
                  MediaQuery.of(context).size.height,
                  MediaQuery.of(context).size.width,
                  ["Productos seleccionados:"],
                  ["Enviar orden:"],
                  Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.075, .225, .15, .125, .075, .075, .075],
                    [
                      "id",
                      "Nombre",
                      "Área",
                      "Tipo",
                      "Ordenar",
                      "Prod./Caja",
                      "Prod. Total",
                    ],
                  ),
                  ListView.separated(
                    itemCount: listaProd.length,
                    scrollDirection: Axis.vertical,
                    separatorBuilder: (context, index) => Container(
                      height: 2,
                      decoration: BoxDecoration(color: Color(0xFFFDC930)),
                    ),
                    itemBuilder: (context, index) {
                      return Consumer<Tablas>(
                        builder: (context, tablas, child) {
                          int id = int.parse(
                            listaProd[index].id.substring(
                              0,
                              listaProd[index].id.length - 3,
                            ),
                          );
                          return Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                            child: Tablas.barraDatos(
                              MediaQuery.sizeOf(context).width,
                              [.075, .225, .15, .125, .075, .075, .075],
                              [
                                listaProd[index].id.toString(),
                                listaProd[index].nombre,
                                listaProd[index].area,
                                listaProd[index].tipo,
                                cantidad[id - 1].toString(),
                                listaProd[index].cantidadPorUnidad.toString(),
                                (cantidad[id - 1] *
                                        listaProd[index].cantidadPorUnidad)
                                    .toString(),
                              ],
                              [],
                              false,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  [
                    Botones.btnCirRos(
                      "No",
                      () => {listaProd.clear(), ventana.tabla(false)},
                    ),
                    Botones.btnCirRos(
                      "Si",
                      () async => {
                        carga.cargaBool(true),
                        await addOrden(),
                        carga.cargaBool(false),
                        ventana.tabla(false),
                      },
                    ),
                  ],
                );
              },
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }

  Widget barraDeBusqueda(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Botones.btnRctMor(
          "Regresar",
          35,
          Icons.menu_rounded,
          false,
          () => Scaffold.of(context).openDrawer(),
        ),
        Botones.btnRctMor(
          "Revisar orden",
          35,
          Icons.task_rounded,
          false,
          () async => generarTabla(await getProductos("id", "")),
        ),
        Container(
          width: MediaQuery.of(context).size.width * .775,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Consumer<Tablas>(
            builder: (context, tablas, child) {
              return CampoTexto.barraBusqueda(
                () async => tablas.datos(
                  await getProductos(
                    CampoTexto.filtroTexto(false),
                    CampoTexto.busquedaTexto.text,
                  ),
                ),
                true,
              );
            },
          ),
        ),
      ],
    );
  }

  ListView listaPrincipal(List lista) {
    String length = lista.last.id.substring(0, lista.last.id.length - 3);
    listas(int.parse(length));
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        List<Color> colores = [];
        for (int i = 0; i < 6; i++) {
          colores.add(Colors.transparent);
        }
        colores[4] = Textos.colorLimite(
          lista[index].limiteProd,
          lista[index].unidades.floor(),
        );
        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: 40,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.1, .25, .175, .175, .08, .2],
            [
              lista[index].id.toString(),
              lista[index].nombre,
              lista[index].area,
              lista[index].tipo,
              lista[index].unidades.toString().split(".")[0],
              "",
            ],
            colores,
            false,
            extraWid: SizedBox(
              width: MediaQuery.sizeOf(context).width * .2,
              child: Consumer<Textos>(
                builder: (context, textos, child) {
                  int id = int.parse(
                    lista[index].id.substring(0, lista[index].id.length - 3),
                  );
                  return Botones.botonesSumaResta(
                    lista[index].nombre,
                    cantidad[id - 1],
                    Textos.getColor(id - 1),
                    () => {
                      textos.setColor(id - 1, Color(0xFFFF0000)),
                      if ((cantidad[id - 1] - 1) > -1)
                        {
                          textos.setColor(id - 1, Color(0xFFFDC930)),
                          cantidad[id - 1] -= 1,
                        },
                    },
                    () => {
                      textos.setColor(id - 1, Color(0xFFFDC930)),
                      cantidad[id - 1] += 1,
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
