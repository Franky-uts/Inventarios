import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
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
  final List<ProductoModel> productosPorId;

  const OrdenSalida({super.key, required this.productosPorId});

  @override
  State<OrdenSalida> createState() => _OrdenSalidaState();
}

class _OrdenSalidaState extends State<OrdenSalida> {
  List<ProductoModel> listaProd = [];
  late String respuesta;
  late int cantArticulos;
  late bool lista;
  List<int> cantidad = [];

  @override
  void initState() {
    lista = true;
    listas();
    super.initState();
  }

  @override
  void dispose() {
    listaProd.clear();
    cantidad.clear();
    super.dispose();
  }

  Future<void> addOrden() async {
    List<String> articulos = [];
    List<int> cantidades = [];
    for (int i = 0; i < listaProd.length; i++) {
      articulos.add(listaProd[i].nombre);
      cantidades.add(cantidad[listaProd[i].id - 1]);
    }
    cantArticulos = articulos.length;
    respuesta = await OrdenModel.postOrden(
      articulos,
      cantidades,
      "En proceso",
      LocalStorage.local('usuario'),
      LocalStorage.local('locación'),
    );
  }

  void listas() {
    if (lista) {
      for (int i = 0; i < widget.productosPorId.length; i++) {
        cantidad.add(0);
      }
      lista = false;
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
            Builder(
              builder: (context) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    barraDeBusqueda(context),
                    Tablas.contenedorInfo(
                      MediaQuery.sizeOf(context).width,
                      [.05, .25, .175, .175, .08, .2],
                      ["id", "Nombre", "Tipo", "Área", "Unidades", "Acciones"],
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
                            () => ProductoModel.getProductos(
                              CampoTexto.filtroTexto(),
                              CampoTexto.busquedaTexto.text,
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
                    [.1, 0.25, 0.2, 0.075, 0.075, 0.075],
                    [
                      "id",
                      "Nombre",
                      "Área",
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
                          return Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                            child: Tablas.barraDatos(
                              MediaQuery.sizeOf(context).width,
                              [.1, .25, .2, .075, .075, .075],
                              [
                                listaProd[index].id.toString(),
                                listaProd[index].nombre,
                                listaProd[index].area,
                                cantidad[listaProd[index].id - 1].toString(),
                                listaProd[index].cantidadPorUnidad.toString(),
                                (cantidad[listaProd[index].id - 1] *
                                        listaProd[index].cantidadPorUnidad)
                                    .toString(),
                              ],
                              [],
                              false,
                              null,
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
                        if (respuesta.split(": ")[0] != "Error")
                          {
                            Textos.toast(
                              "Se guardo la orden $respuesta correctamente con $cantArticulos artículos.",
                              true,
                            ),
                            if (context.mounted)
                              {carga.cargaBool(false), ventana.tabla(false)},
                            for (int i = 0; i < listaProd.length; i++)
                              {cantidad[listaProd[i].id - 1] = 0},
                            listaProd.clear(),
                          }
                        else
                          {
                            if (context.mounted) {carga.cargaBool(false)},
                            Textos.toast(respuesta, false),
                          },
                      },
                    ),
                  ],
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

  Widget barraDeBusqueda(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Botones.btnRctMor(
          "Regresar",
          35,
          Icons.arrow_back_rounded,
          false,
          () => {
            Textos.limpiarLista(),
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Inventario()),
            ),
          },
        ),
        Botones.btnRctMor(
          "Regresar",
          35,
          Icons.task_rounded,
          false,
          () => {
            if (Tablas.getValido())
              {
                for (int i = 0; i < cantidad.length; i++)
                  {
                    if (cantidad[i] != 0)
                      {listaProd.add(widget.productosPorId[i])},
                  },
                if (listaProd.isEmpty)
                  {Textos.toast("No hay productos seleccionados.", false)}
                else
                  {context.read<Ventanas>().tabla(true)},
              }
            else
              {Textos.toast("Espera a que los datos carguen.", false)},
          },
        ),
        Botones.btnRctMor(
          "Historial de ordenes",
          35,
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
                        builder: (context) => HistorialOrdenes(
                          productosPorId: widget.productosPorId,
                        ),
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
        Container(
          width: MediaQuery.of(context).size.width * .7,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Consumer<Tablas>(
            builder: (context, tablas, child) {
              return CampoTexto.barraBusqueda(
                () async => tablas.datos(
                  await ProductoModel.getProductos(
                    CampoTexto.filtroTexto(),
                    CampoTexto.busquedaTexto.text,
                  ),
                ),
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
          height: 40,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.05, .25, .175, .175, .08, .2],
            [
              lista[index].id.toString(),
              lista[index].nombre,
              lista[index].tipo,
              lista[index].area,
              lista[index].unidades.toString(),
              "",
            ],
            [],
            false,
            SizedBox(
              width: MediaQuery.sizeOf(context).width * .2,
              child: Consumer<Textos>(
                builder: (context, textos, child) {
                  return Botones.botonesSumaResta(
                    lista[index].nombre,
                    cantidad[lista[index].id - 1],
                    Textos.getColor(lista[index].id - 1),
                    () => {
                      if ((cantidad[lista[index].id - 1] - 1) > -1)
                        {
                          textos.setColor(lista[index].id - 1, 0xFFFDC930),
                          cantidad[lista[index].id - 1] -= 1,
                        }
                      else
                        {textos.setColor(lista[index].id - 1, 0xFFFF0000)},
                    },
                    () => {
                      textos.setColor(lista[index].id - 1, 0xFFFDC930),
                      cantidad[lista[index].id - 1] += 1,
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
