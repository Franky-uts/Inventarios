import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/inicio.dart';
import 'package:inventarios/pages/orden_salida.dart';
import 'package:inventarios/pages/producto.dart';
import 'package:inventarios/pages/add_producto.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum Filtros { id, nombre, tipo, area }

class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  static Filtros? seleccionFiltro;
  static List<ProductoModel> productos = [];
  static List tipos = [];
  static List areas = [];
  final focusBusqueda = FocusNode();
  final busquedaTexto = TextEditingController();
  late bool valido;
  late bool carga;
  late bool ventanaConf;

  @override
  void initState() {
    valido = false;
    carga = false;
    ventanaConf = false;
    busquedaTexto.text = local('busqueda');
    super.initState();
  }

  @override
  void dispose() {
    productos.clear();
    tipos.clear();
    areas.clear();
    busquedaTexto.dispose();
    focusBusqueda.dispose();
    valido;
    carga;
    ventanaConf;
    super.dispose();
  }

  Future<void> _getProductos() async {
    productos = await ProductoModel.getProductos(
      filtroTexto(),
      busquedaTexto.text,
    );
  }

  Future<void> historialOrdenes(BuildContext ctx) async {
    setState(() {
      carga = true;
    });
    Navigator.of(context).pop();
    List<ProductoModel> listaPorid = [];
    try {
      listaPorid = await ProductoModel.getProductos("id", "");
      if (listaPorid[0].nombre != "Error") {
        await LocalStorage.preferencias.setString(
          'busqueda',
          busquedaTexto.text,
        );
        if (ctx.mounted) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (context) => OrdenSalida(productosPorId: listaPorid),
            ),
          );
        } else {
          setState(() {
            carga = false;
          });
        }
      } else {
        toast(listaPorid[0].tipo);
      }
    } catch (e) {
      toast("Error: ${e.toString()}");
      setState(() {
        carga = false;
      });
    }
  }

  Future<void> logout(BuildContext ctx) async {
    setState(() {
      carga = true;
    });
    Navigator.of(context).pop();
    await LocalStorage.preferencias.remove('usuario');
    await LocalStorage.preferencias.remove('puesto');
    await LocalStorage.preferencias.remove('locación');
    await LocalStorage.preferencias.remove('busqueda');
    await LocalStorage.preferencias.remove('conexion');
    if (ctx.mounted) {
      Navigator.push(ctx, MaterialPageRoute(builder: (context) => Inicio()));
    } else {
      setState(() {
        carga = false;
      });
    }
  }

  Future<void> _getListas(BuildContext ctx) async {
    setState(() {
      carga = true;
    });
    Navigator.of(context).pop();
    tipos = await ProductoModel.getTipos();
    areas = await ProductoModel.getAreas();
    if (tipos[0].toString().split(": ")[0] == "Error") {
      toast(tipos[0].toString().split(": ")[1]);
      setState(() {
        carga = false;
      });
    } else if (areas[0].toString().split(": ")[0] == "Error") {
      toast(areas[0].toString().split(": ")[1]);
      setState(() {
        carga = false;
      });
    } else {
      await LocalStorage.preferencias.setString('busqueda', busquedaTexto.text);
      if (ctx.mounted) {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (context) =>
                Addproducto(listaArea: areas, listaTipo: tipos),
          ),
        );
      } else {
        setState(() {
          carga = false;
        });
      }
    }
  }

  Future<void> datosExcel(BuildContext context) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Inventario'];
    List<String> headers = [
      'id',
      'Nombre',
      'Tipo',
      'Unidades',
      'Area',
      'Entrada',
      'Salida',
      'Perdida',
      'UltimaModificación',
    ];
    for (int i = 0; i < headers.length; i++) {
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(
        headers[i],
      );
    }
    for (int i = 0; i < productos.length; i++) {
      ProductoModel item = productos[i];
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = IntCellValue(
        item.id,
      );
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(
        item.nombre,
      );
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue(
        item.tipo,
      );
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = IntCellValue(
        item.unidades,
      );
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = TextCellValue(
        item.area,
      );
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          .value = IntCellValue(
        item.entrada,
      );
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1))
          .value = IntCellValue(
        item.salida,
      );
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1))
          .value = IntCellValue(
        item.perdida,
      );
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1))
          .value = TextCellValue(
        item.ultimaModificacion,
      );
    }
    var status = await Permission.manageExternalStorage.request();
    if (status.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    if (status.isGranted) {
      final path = '/storage/emulated/0/Download/Inventarios';
      String fecha =
          '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}';
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        File('$path/$fecha.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes, flush: true);
        toast('Archivo guardado en: $path/$fecha.xlsx');
      }
    } else {
      toast('Se aborto el proceso');
    }
  }

  String local(String clave) {
    String res = LocalStorage.preferencias.getString(clave).toString();
    return res;
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

  void toast(String texto) {
    Fluttertoast.showToast(
      msg: texto,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Builder(
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
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
              visible: ventanaConf,
              child: Container(
                padding: EdgeInsets.all(90),
                decoration: BoxDecoration(color: Colors.black38),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadiusGeometry.circular(25),
                      border: BoxBorder.all(color: Colors.black54),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Text(
                          "¿Seguro quieres establecer todas las entradas, salidas y perdidas en 0?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  ventanaConf = false;
                                });
                              },
                              child: Text("No", style: TextStyle(fontSize: 20)),
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                setState(() {
                                  ventanaConf = false;
                                });
                                try {
                                  final res = await http.put(
                                    Uri.parse(
                                      "${local('conexion')}/inventario/${local('locación')}/reiniciarMovimientos",
                                    ),
                                    headers: {
                                      "Accept": "application/json",
                                      "content-type":
                                          "application/json; charset=UTF-8",
                                    },
                                  );
                                  if (res.statusCode == 200) {
                                    toast("Reinicio exitoso.");
                                  } else {
                                    toast("${res.reasonPhrase}");
                                  }
                                } on TimeoutException catch (e) {
                                  toast("Error: ${e.message.toString()}");
                                } on SocketException catch (e) {
                                  toast("Error: ${e.message.toString()}");
                                } on Error catch (e) {
                                  toast("Error: ${e.toString()}");
                                }
                              },
                              child: Text("Si", style: TextStyle(fontSize: 20)),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: carga,
              child: Container(
                decoration: BoxDecoration(color: Colors.black45),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer drawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey),
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(6.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Bienvenido, ", style: TextStyle(fontSize: 15)),
                    IconButton(
                      onPressed: () {
                        logout(context);
                      },
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.black, width: 3),
                        ),
                      ),
                      icon: Icon(
                        Icons.logout_rounded,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ],
                ),
                Text(
                  local('usuario'),
                  style: TextStyle(fontSize: 30),
                  maxLines: 1,
                ),
                Text(
                  local('puesto'),
                  style: TextStyle(fontSize: 15),
                  maxLines: 1,
                ),
                Text(
                  "Mostrando: ${local('locación')}",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * .585,
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                TextButton.icon(
                  onPressed: () {
                    if (valido) {
                      datosExcel(context);
                    } else {
                      toast("Espera a que los datos carguen.");
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    backgroundColor: Colors.black,
                  ),
                  icon: Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                  label: Text(
                    "Descargar reporte",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    if (valido) {
                      setState(() {
                        ventanaConf = true;
                      });
                      Navigator.of(context).pop();
                    } else {
                      toast("Espera a que los datos carguen.");
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    backgroundColor: Colors.black,
                  ),
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                  label: Text(
                    "Reiniciar movimientos",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    if (valido) {
                      await _getListas(context);
                    } else {
                      toast("Espera a que los datos carguen.");
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    backgroundColor: Colors.black,
                  ),
                  icon: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                  label: Text(
                    "Añadir un producto",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    if (valido) {
                      historialOrdenes(context);
                    } else {
                      toast("Espera a que los datos carguen.");
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(color: Colors.black, width: 5),
                    ),
                  ),
                  icon: Icon(
                    Icons.add_shopping_cart_rounded,
                    color: Colors.black,
                    size: 25,
                  ),
                  label: Text(
                    "Nueva orden",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        "Inventario",
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      leading: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.grey),
        child: Icon(Icons.menu_rounded, size: 30),
      ),
    );
  }

  Widget barraDeBusqueda(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: Icon(Icons.menu_rounded, size: 35),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * .875,
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
            decoration: InputDecoration(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
              fillColor: Colors.white,
              suffixIcon: Container(
                margin: EdgeInsets.only(right: 5),
                child: botonBusqueda(),
              ),
              prefixIcon: PopupMenuButton<Filtros>(
                icon: Icon(Icons.filter_list_rounded),
                initialValue: seleccionFiltro,
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
                        child: Text("id"),
                      ),
                      PopupMenuItem<Filtros>(
                        value: Filtros.nombre,
                        child: Text("Nombre"),
                      ),
                      PopupMenuItem<Filtros>(
                        value: Filtros.tipo,
                        child: Text("Tipo"),
                      ),
                      PopupMenuItem<Filtros>(
                        value: Filtros.area,
                        child: Text("Área"),
                      ),
                    ],
              ),
              hintText: "Buscar",
              hintStyle: TextStyle(color: Colors.grey),
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
        icon: Icon(Icons.search),
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
        icon: Icon(Icons.close_rounded),
      );
    }
  }

  Container contenedorInfo() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(color: Colors.grey),
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
          _barraSuperior(.175, "Área"),
          _divider(),
          _barraSuperior(.075, "Entrada"),
          _divider(),
          _barraSuperior(.075, "Salida"),
          _divider(),
          _barraSuperior(.075, "Perdida"),
        ],
      ),
    );
  }

  VerticalDivider _divider() {
    return VerticalDivider(
      thickness: 1,
      width: 0,
      color: Colors.grey,
      indent: 5,
      endIndent: 5,
    );
  }

  Widget _barraDato(
    double grosor,
    String texto,
    TextAlign alineamiento,
    double tamanoFuente,
  ) => Container(
    width: MediaQuery.sizeOf(context).width * grosor,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      texto,
      textAlign: alineamiento,
      maxLines: 1,
      style: TextStyle(color: Colors.black, fontSize: tamanoFuente),
    ),
  );

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

  ListView listaPrincipal(List lista) {
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) =>
          Container(height: 2, decoration: BoxDecoration(color: Colors.grey)),
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: 40,
          decoration: BoxDecoration(color: Colors.white54),
          child: TextButton(
            onPressed: () async => {
              await LocalStorage.preferencias.setString(
                'busqueda',
                busquedaTexto.text,
              ),
              if (context.mounted)
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Producto(productoInfo: lista[index]),
                    ),
                  ),
                },
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(0),
              shape: ContinuousRectangleBorder(),
            ),
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
                _barraDato(.175, lista[index].area, TextAlign.center, 20),
                _divider(),
                _barraDato(
                  .075,
                  lista[index].entrada.toString(),
                  TextAlign.center,
                  20,
                ),
                _divider(),
                _barraDato(
                  .075,
                  lista[index].salida.toString(),
                  TextAlign.center,
                  20,
                ),
                _divider(),
                _barraDato(
                  .075,
                  lista[index].perdida.toString(),
                  TextAlign.center,
                  20,
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
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
