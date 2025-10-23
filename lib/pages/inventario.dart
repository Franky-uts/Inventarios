import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/pages/inicio.dart';
import 'package:inventarios/pages/producto.dart';
import 'package:inventarios/pages/add_producto.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum Filtros { id, nombre, tipo, area }

class Inventario extends StatefulWidget {
  final UsuarioModel usuario;
  final String busqueda;

  const Inventario({super.key, required this.usuario, required this.busqueda});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  static Filtros? seleccionFiltro;
  final busquedaTexto = TextEditingController();
  static List<ProductoModel> productos = [];
  static List tipos = [];
  static List areas = [];
  final focusBusqueda = FocusNode();
  late bool valido;
  late bool carga;

  @override
  void initState() {
    valido = false;
    carga = false;
    busquedaTexto.text = widget.busqueda;
    super.initState();
  }

  @override
  void dispose() {
    //_getProductos();
    super.dispose();
  }

  Future<void> _getProductos() async {
    productos = await ProductoModel.getProductos(url());
  }

  Future<void> _getListas() async {
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Addproducto(
            listaArea: areas,
            listaTipo: tipos,
            usuario: widget.usuario,
            busqueda: busquedaTexto.text,
          ),
        ),
      );
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
        //print('File saved at $path/$fecha.xlsx');
        toast('Archivo guardado en: $path/$fecha.xlsx');
      }
    } else {
      toast('Se aborto el proceso');
    }
  }

  String url() {
    if (busquedaTexto.text.isEmpty) {
      return "http://192.168.1.93:4000/almacen/${filtroTexto()}";
    } else {
      return "http://192.168.1.93:4000/almacen/${filtroTexto()}/${busquedaTexto.text}";
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Bienvenido, ", style: TextStyle(fontSize: 15)),
                    Text(
                      widget.usuario.nombre,
                      style: TextStyle(fontSize: 30),
                      maxLines: 1,
                    ),
                  ],
                ),
                Text(widget.usuario.puesto, style: TextStyle(fontSize: 20)),
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
                TextButton(
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
                  child: Text(
                    "Descargar reporte",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await _getListas();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    "Añadir un producto",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await LocalStorage.preferencias.remove('usuario');
                    await LocalStorage.preferencias.remove('puesto');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Inicio()),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(color: Colors.black, width: 5),
                    ),
                  ),
                  child: Text(
                    "Cerrar sesión",
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
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Producto(
                    productoInfo: lista[index],
                    usuario: widget.usuario,
                    busqueda: busquedaTexto.text,
                  ),
                ),
              ),
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
      future: ProductoModel.getProductos(url()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            valido = true;
            productos = snapshot.data;
            if (productos.isNotEmpty) {
              return listaPrincipal(productos);
            } else {
              return Center(child: Text("No hay coincidencias."));
            }
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
