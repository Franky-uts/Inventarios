import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  static Filtros? seleccionFiltro;
  static List<ProductoModel> productos = [];
  static List<ProductoModel> listaProd = [];
  late String respuesta;
  final busquedaTexto = TextEditingController();
  final focusBusqueda = FocusNode();
  late bool carga;
  late bool ventanaCarga;
  late bool valido;
  late bool lista;
  late List<int> cantidad = [];
  late List<int> color = [];

  @override
  void initState() {
    busquedaTexto.text = local('busqueda');
    carga = false;
    ventanaCarga = false;
    valido = false;
    lista = true;
    super.initState();
  }

  @override
  void dispose() {
    listaProd.clear();
    productos.clear();
    cantidad.clear();
    color.clear();
    busquedaTexto.dispose();
    focusBusqueda.dispose();
    super.dispose();
  }

  String local(String clave) {
    String res = LocalStorage.preferencias.getString(clave).toString();
    return res;
  }

  Future<void> _getProductos() async {
    productos = await ProductoModel.getProductos(
      filtroTexto(),
      busquedaTexto.text,
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

  void toast(String texto) {
    Fluttertoast.showToast(
      msg: texto,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color(0x80FDC930),
      textColor: Colors.white,
      fontSize: 15,
    );
  }

  String filtroTexto() {
    String filtro;
    switch (seleccionFiltro) {
      case (Filtros.id):
        filtro = "id";
        break;
      case (Filtros.nombre):
        filtro = "Nombre";
        break;
      case (Filtros.tipo):
        filtro = "Tipo";
        break;
      case (Filtros.area):
        filtro = "Area";
        break;
      default:
        filtro = "id";
        break;
    }
    return filtro;
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
                  contenedorInfo(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 97,
                    child: listaFutura(),
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
            Visibility(
              visible: carga,
              child: Container(
                decoration: BoxDecoration(color: Colors.black45),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFF6AFCF)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _barraSuperior(double grosor, String texto) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * grosor,
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  VerticalDivider _divider() {
    return VerticalDivider(
      thickness: 1,
      width: 0,
      color: Color(0xFFFDC930),
      indent: 5,
      endIndent: 5,
    );
  }

  Container contenedorInfo() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(color: Color(0xFF8F01AF)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _barraSuperior(.05, "id"),
          _divider(),
          _barraSuperior(0.25, "Nombre"),
          _divider(),
          _barraSuperior(.175, "Tipo"),
          _divider(),
          _barraSuperior(.08, "Unidades"),
          _divider(),
          _barraSuperior(.2, "Acciones"),
        ],
      ),
    );
  }

  Widget _barraDato(
    double grosor,
    String texto,
    TextAlign alineamiento,
    double tamanoFuente,
  ) {
    return Container(
      width: MediaQuery.sizeOf(context).width * grosor,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        texto,
        textAlign: alineamiento,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Color(0xFF8F01AF), fontSize: tamanoFuente),
      ),
    );
  }

  Widget _barraDatoProdCaja(
    double grosor,
    String texto,
    TextAlign alineamiento,
    double tamanoFuente,
  ) {
    if (texto == "1") {
      return Container(
        width: MediaQuery.sizeOf(context).width * grosor,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "-",
          textAlign: alineamiento,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Color(0xFF8F01AF), fontSize: tamanoFuente),
        ),
      );
    } else {
      return Container(
        width: MediaQuery.sizeOf(context).width * grosor,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          texto,
          textAlign: alineamiento,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Color(0xFF8F01AF), fontSize: tamanoFuente),
        ),
      );
    }
  }

  Widget barraDeBusqueda(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: () async {
            await LocalStorage.preferencias.setString(
              'busqueda',
              busquedaTexto.text,
            );
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Inventario()),
              );
            }
          },
          tooltip: "Regresar",
          icon: Icon(Icons.arrow_back_rounded, size: 35),
          style: IconButton.styleFrom(
            backgroundColor: Color(0xFF8F01AF),
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        IconButton.filled(
          onPressed: () {
            if (valido) {
              for (int i = 0; i < cantidad.length; i++) {
                if (cantidad[i] != 0) {
                  listaProd.add(widget.productosPorId[i]);
                }
              }
              if (listaProd.isEmpty) {
                toast("No hay productos seleccionados.");
              } else {
                setState(() {
                  ventanaCarga = true;
                });
              }
            } else {
              toast("Espera a que los datos carguen.");
            }
          },
          tooltip: "Realizar orden",
          icon: Icon(Icons.task_rounded, size: 35),
          style: IconButton.styleFrom(
            backgroundColor: Color(0xFF8F01AF),
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        IconButton.filled(
          onPressed: () async {
            if (valido) {
              await LocalStorage.preferencias.setString(
                'busqueda',
                busquedaTexto.text,
              );
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HistorialOrdenes(productosPorId: widget.productosPorId),
                  ),
                );
              }
            } else {
              toast("Espera a que los datos carguen.");
            }
          },
          tooltip: "Historial de ordenes",
          icon: Icon(Icons.history_rounded, size: 35),
          style: IconButton.styleFrom(
            backgroundColor: Color(0xFF8F01AF),
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * .7,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: TextField(
            controller: busquedaTexto,
            focusNode: focusBusqueda,
            onSubmitted: (event) {
              _getProductos();
            },
            onTapOutside: (event) {
              if (busquedaTexto.text.isNotEmpty) {
                _getProductos();
              }
              FocusManager.instance.primaryFocus?.unfocus();
            },
            cursorColor: Color(0xFF8F01AF),
            style: TextStyle(color: Color(0xFF8F01AF)),
            decoration: InputDecoration(
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Color(0xFFFDC930), width: 2.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Color(0xFFFDC930), width: 2.5),
              ),
              fillColor: Colors.white,
              suffixIcon: Container(
                margin: EdgeInsets.only(right: 5),
                child: botonBusqueda(),
              ),
              prefixIcon: PopupMenuButton<Filtros>(
                icon: Icon(Icons.filter_list_rounded, color: Color(0xFF8F01AF)),
                initialValue: seleccionFiltro,
                color: Colors.white,
                tooltip: "Filtros",
                onSelected: (Filtros filtro) {
                  setState(() {
                    seleccionFiltro = filtro;
                    _getProductos();
                  });
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<Filtros>>[
                      PopupMenuItem<Filtros>(
                        value: Filtros.id,
                        child: Text(
                          "id",
                          style: TextStyle(
                            fontSize: 17.5,
                            color: Color(0xFF8F01AF),
                          ),
                        ),
                      ),
                      PopupMenuItem<Filtros>(
                        value: Filtros.nombre,
                        child: Text(
                          "Nombre",
                          style: TextStyle(
                            fontSize: 17.5,
                            color: Color(0xFF8F01AF),
                          ),
                        ),
                      ),
                      PopupMenuItem<Filtros>(
                        value: Filtros.tipo,
                        child: Text(
                          "Tipo",
                          style: TextStyle(
                            fontSize: 17.5,
                            color: Color(0xFF8F01AF),
                          ),
                        ),
                      ),
                      PopupMenuItem<Filtros>(
                        value: Filtros.area,
                        child: Text(
                          "Área",
                          style: TextStyle(
                            fontSize: 17.5,
                            color: Color(0xFF8F01AF),
                          ),
                        ),
                      ),
                    ],
              ),
              hintText: "Buscar",
              hintStyle: TextStyle(color: Color(0xFFF6AFCF)),
            ),
          ),
        ),
      ],
    );
  }

  IconButton botonBusqueda() {
    if (busquedaTexto.text.isEmpty) {
      return IconButton(
        onPressed: () {
          if (busquedaTexto.text.isEmpty) {
            focusBusqueda.requestFocus();
          } else {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() {
              _getProductos();
            });
          }
        },
        icon: Icon(Icons.search, color: Color(0xFF8F01AF)),
      );
    } else {
      return IconButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            busquedaTexto.clear();
          });
          _getProductos();
        },
        icon: Icon(Icons.close_rounded, color: Color(0xFF8F01AF)),
      );
    }
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
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _barraDato(
                  .05,
                  lista[index].id.toString(),
                  TextAlign.center,
                  20,
                ),
                _divider(),
                _barraDato(.25, lista[index].nombre, TextAlign.center, 20),
                _divider(),
                _barraDato(.175, lista[index].tipo, TextAlign.center, 20),
                _divider(),
                _barraDato(
                  .08,
                  lista[index].unidades.toString(),
                  TextAlign.center,
                  20,
                ),
                _divider(),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * .2,
                  child: botones(
                    cantidad[lista[index].id - 1],
                    color[lista[index].id - 1],
                    lista[index].id,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  FutureBuilder listaFutura() {
    return FutureBuilder(
      future: ProductoModel.getProductos(filtroTexto(), busquedaTexto.text),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            listas();
            valido = true;
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
            valido = false;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Error:"), Text(snapshot.error.toString())],
              ),
            );
          } else {
            if (busquedaTexto.text.isNotEmpty) {
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
          Container(
            width: MediaQuery.sizeOf(context).width,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: Color(0xFF8F01AF)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _barraSuperior(.105, "id"),
                _divider(),
                _barraSuperior(0.3, "Nombre"),
                _divider(),
                _barraSuperior(.125, "Ordenar"),
                _divider(),
                _barraSuperior(.125, "Prod./Caja"),
                _divider(),
                _barraSuperior(.125, "Prod. Total"),
              ],
            ),
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
                return Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _barraDato(
                          .105,
                          listaProd[index].id.toString(),
                          TextAlign.center,
                          20,
                        ),
                        _divider(),
                        _barraDato(
                          .3,
                          listaProd[index].nombre,
                          TextAlign.center,
                          20,
                        ),
                        _divider(),
                        _barraDato(
                          .125,
                          cantidad[listaProd[index].id - 1].toString(),
                          TextAlign.center,
                          20,
                        ),
                        _divider(),
                        _barraDatoProdCaja(
                          .125,
                          listaProd[index].cantidadPorUnidad.toString(),
                          TextAlign.center,
                          20,
                        ),
                        _divider(),
                        _barraDato(
                          .125,
                          (cantidad[listaProd[index].id - 1] *
                                  listaProd[index].cantidadPorUnidad)
                              .toString(),
                          TextAlign.center,
                          20,
                        ),
                      ],
                    ),
                  ),
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
                        local('usuario'),
                        local('locación'),
                      );
                      if (respuesta.toString().split(": ")[0] != "Error") {
                        Fluttertoast.showToast(
                          msg:
                              "Se guardo la orden ${respuesta.toString()} correctamente con ${articulos.length} artículos.",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Color(0x80FDC930),
                          textColor: Colors.white,
                          fontSize: 15,
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
                        toast(respuesta.toString().split(": ")[1]);
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
