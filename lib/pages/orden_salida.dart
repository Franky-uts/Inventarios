import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input_texto.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/toast_text.dart';
import 'package:inventarios/models/orden_model.dart';
import 'package:inventarios/pages/historial_ordenes.dart';
import 'package:inventarios/pages/inventario.dart';
import '../models/producto_model.dart';
import '../services/local_storage.dart';

enum Filtros { id, nombre, tipo, area }

class OrdenSalida extends StatefulWidget {
  final List<ProductoModel> productosPorId;

  const OrdenSalida({super.key, required this.productosPorId});

  @override
  State<OrdenSalida> createState() => _OrdenSalidaState();
}

class _OrdenSalidaState extends State<OrdenSalida> {
  static List<ProductoModel> productos = [];
  static List<ProductoModel> listaProd = [];
  late String respuesta;
  late bool carga;
  late bool ventanaCarga;
  late bool lista;
  late List<int> cantidad = [];
  late List<int> color = [];

  @override
  void initState() {
    CampoTexto.busquedaTexto.text = LocalStorage.local('busqueda');
    carga = false;
    ventanaCarga = false;
    Tablas.valido = false;
    lista = true;
    listas();
    super.initState();
  }

  @override
  void dispose() {
    listaProd.clear();
    productos.clear();
    cantidad.clear();
    color.clear();
    super.dispose();
  }

  Future<void> _getProductos() async {
    productos = await ProductoModel.getProductos(
      CampoTexto.filtroTexto(),
      CampoTexto.busquedaTexto.text,
    );
  }

  void listas() {
    if (lista) {
      for (int i = 0; i < widget.productosPorId.length; i++) {
        cantidad.add(0);
        color.add(0xFFFDC930);
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
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  barraDeBusqueda(context),
                  Tablas.contenedorInfo(
                    MediaQuery.sizeOf(context).width,
                    [.05, 0.25, 0.175, 0.175, 0.08, 0.2],
                    ["id", "Nombre", "Tipo", "Área", "Unidades", "Acciones"],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 97,
                    child: listaFutura(),
                    /*Tablas.listaFutura(
                      listaPrincipal,
                      "No hay productos registrados.",
                      "No hay coincidencias.",
                      modelo: () => {
                        ProductoModel.getProductos(
                          CampoTexto.filtroTexto(),
                          CampoTexto.busquedaTexto.text,
                        ),
                      },
                    )*/
                  ),
                ],
              ),
            ),
            Visibility(
              visible: ventanaCarga,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 89, vertical: 15),
                decoration: BoxDecoration(color: Colors.black38),
                child: Center(child: contenidoVentana()),
              ),
            ),
            Carga.ventanaCarga(carga),
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
          Icon(Icons.arrow_back_rounded, size: 35),
          accion: () async => {
            await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text),
            if (context.mounted)
              {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Inventario()),
                ),
              },
          },
        ),
        Botones.btnRctMor(
          "Regresar",
          Icon(Icons.task_rounded, size: 35),
          accion: () => {
            if (Tablas.valido)
              {
                for (int i = 0; i < cantidad.length; i++)
                  {
                    if (cantidad[i] != 0)
                      {listaProd.add(widget.productosPorId[i])},
                  },
                if (listaProd.isEmpty)
                  {ToastText.toast("No hay productos seleccionados.", false)}
                else
                  {
                    setState(() {
                      ventanaCarga = true;
                    }),
                  },
              }
            else
              {ToastText.toast("Espera a que los datos carguen.", false)},
          },
        ),
        Botones.btnRctMor(
          "Historial de ordenes",
          Icon(Icons.history_rounded, size: 35),
          accion: () async => {
            if (Tablas.valido)
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
                  },
              }
            else
              {ToastText.toast("Espera a que los datos carguen.", false)},
          },
        ),
        CampoTexto.barraBusqueda(
          MediaQuery.of(context).size.width * .7,
          accion: () => setState(() {
            _getProductos();
          }),
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
          decoration: BoxDecoration(color: Colors.white),
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
            botones(
              cantidad[lista[index].id - 1],
              color[lista[index].id - 1],
              lista[index].id,
            ),
          ),
        );
      },
    );
  }

  FutureBuilder listaFutura() {
    return FutureBuilder(
      future: ProductoModel.getProductos(
        CampoTexto.filtroTexto(),
        CampoTexto.busquedaTexto.text,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            Tablas.valido = true;
            productos = snapshot.data;
            if (productos.isNotEmpty) {
              if (productos[0].nombre == "Error") {
                return Center(child: Text(productos[0].tipo));
              } else {
                return listaPrincipal(productos);
              }
            } else {
              return Center(child: Text("No hay productos registrados."));
            }
          } else if (snapshot.hasError) {
            Tablas.valido = false;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Error:"), Text(snapshot.error.toString())],
              ),
            );
          } else {
            if (CampoTexto.busquedaTexto.text.isNotEmpty) {
              return Center(child: Text("No hay coincidencias."));
            }
          }
        }
        return Center(
          child: CircularProgressIndicator(color: Color(0xFFF6AFCF)),
        );
      },
    );
  }

  Row botones(int textoValor, int colorBorde, int id) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            if ((cantidad[id - 1] - 1) > -1) {
              setState(() {
                color[id - 1] = 0xFFFDC930;
                cantidad[id - 1] -= 1;
              });
            } else {
              setState(() {
                color[id - 1] = 0xFFFF0000;
              });
            }
          },
          icon: Icon(Icons.remove, color: Colors.white),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Color(0xFF8F01AF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Color(colorBorde), width: 2.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            textoValor.toString(),
            style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              color[id - 1] = 0xFFFDC930;
              cantidad[id - 1] += 1;
            });
          },
          icon: Icon(Icons.add, color: Colors.white),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Color(0xFF8F01AF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Container contenidoVentana() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadiusGeometry.circular(25),
        border: BoxBorder.all(color: Color(0xFFFDC930), width: 2.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 0,
        children: [
          Text(
            "Productos seleccionados:",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8F01AF),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          Tablas.contenedorInfo(
            MediaQuery.sizeOf(context).width,
            [.1, 0.25, 0.2, 0.075, 0.075, 0.075],
            ["id", "Nombre", "Área", "Ordenar", "Prod./Caja", "Prod. Total"],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 153,
            margin: EdgeInsets.zero,
            child: ListView.separated(
              itemCount: listaProd.length,
              scrollDirection: Axis.vertical,
              separatorBuilder: (context, index) => Container(
                height: 2,
                decoration: BoxDecoration(color: Color(0xFFFDC930)),
              ),
              itemBuilder: (context, index) {
                return Tablas.barraDatos(
                  MediaQuery.sizeOf(context).width,
                  [.1, .25, .2, .075, .075, .075],
                  [
                    listaProd[index].id.toString(),
                    listaProd[index].nombre,
                    listaProd[index].area,
                    cantidad[listaProd[index].id - 1].toString(),
                    listaProd[index].cantidadPorUnidad.toString(),
                    listaProd[index].cantidadPorUnidad.toString(),
                  ],
                  [],
                  false,
                  null,
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Enviar orden:",
                style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
              ),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        ventanaCarga = false;
                        listaProd.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xFF8F01AF),
                      side: BorderSide(color: Color(0xFFF6AFCF), width: 2),
                    ),
                    child: Text(
                      "No",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      setState(() {
                        carga = true;
                      });
                      List<String> articulos = [];
                      List<int> cantidades = [];
                      for (int i = 0; i < listaProd.length; i++) {
                        articulos.add(listaProd[i].nombre);
                        cantidades.add(cantidad[listaProd[i].id - 1]);
                      }
                      respuesta = await OrdenModel.postOrden(
                        articulos,
                        cantidades,
                        "En proceso",
                        LocalStorage.local('usuario'),
                        LocalStorage.local('locación'),
                      );
                      if (respuesta.toString().split(": ")[0] != "Error") {
                        ToastText.toast(
                          "Se guardo la orden ${respuesta.toString()} correctamente con ${articulos.length} artículos.",
                          true,
                        );
                        setState(() {
                          for (int i = 0; i < listaProd.length; i++) {
                            cantidad[listaProd[i].id - 1] = 0;
                          }
                          listaProd.clear();
                          ventanaCarga = false;
                          carga = false;
                        });
                      } else {
                        setState(() {
                          carga = !carga;
                        });
                        ToastText.toast(
                          respuesta.toString().split(": ")[1],
                          false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xFF8F01AF),
                      side: BorderSide(color: Color(0xFFF6AFCF), width: 2),
                    ),
                    child: Text(
                      "Si",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
