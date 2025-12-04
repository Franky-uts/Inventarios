import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input_texto.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/toast_text.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/inicio.dart';
import 'package:inventarios/pages/orden_salida.dart';
import 'package:inventarios/pages/producto.dart';
import 'package:inventarios/pages/add_producto.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:inventarios/components/botones.dart';

class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  List<ProductoModel> productos = [];
  List tipos = [];
  List areas = [];
  late bool carga;
  late bool ventanaConf;

  @override
  void initState() {
    Tablas.valido = false;
    carga = false;
    ventanaConf = false;
    CampoTexto.busquedaTexto.text = LocalStorage.local('busqueda');
    super.initState();
  }

  @override
  void dispose() {
    productos.clear();
    tipos.clear();
    areas.clear();
    super.dispose();
  }

  Future<void> _getProductos() async {
    productos = await ProductoModel.getProductos(
      CampoTexto.filtroTexto(),
      CampoTexto.busquedaTexto.text,
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
        await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text);
        if (ctx.mounted) {
          Navigator.pushReplacement(
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
        ToastText.toast(listaPorid[0].tipo, false);
        setState(() {
          carga = false;
        });
      }
    } catch (e) {
      ToastText.toast("Error: ${e.toString()}", false);
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
    await LocalStorage.eliminar('usuario');
    await LocalStorage.eliminar('puesto');
    await LocalStorage.eliminar('locación');
    await LocalStorage.eliminar('busqueda');
    await LocalStorage.eliminar('conexion');
    if (ctx.mounted) {
      Navigator.pushReplacement(
        ctx,
        MaterialPageRoute(builder: (context) => Inicio()),
      );
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
      ToastText.toast(tipos[0].toString().split(": ")[1], false);
      setState(() {
        carga = false;
      });
    } else if (areas[0].toString().split(": ")[0] == "Error") {
      ToastText.toast(areas[0].toString().split(": ")[1], false);
      setState(() {
        carga = false;
      });
    } else {
      await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text);
      if (ctx.mounted) {
        Navigator.pushReplacement(
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
        ToastText.toast('Archivo guardado en: $path/$fecha.xlsx', true);
      }
    } else {
      ToastText.toast('Se aborto el proceso', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(),
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
                    barraSuperior(context),
                    Tablas.contenedorInfo(
                      MediaQuery.sizeOf(context).width,
                      [.05, 0.25, 0.175, 0.08, 0.175, 0.075, 0.075, 0.075],
                      [
                        "id",
                        "Nombre",
                        "Tipo",
                        "Unidades",
                        "Área",
                        "Entrada",
                        "Salida",
                        "Perdida",
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - 97,
                      child: Tablas.listaFutura(
                        listaPrincipal,
                        "No hay productos registrados.",
                        "No hay coincidencias.",
                        () => ProductoModel.getProductos(
                          CampoTexto.filtroTexto(),
                          CampoTexto.busquedaTexto.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: ventanaConf,
              child: Container(
                padding: EdgeInsets.all(100),
                decoration: BoxDecoration(color: Colors.black38),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadiusGeometry.circular(25),
                      border: BoxBorder.all(color: Color(0xFFFDC930), width: 3),
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
                            color: Color(0xFF8F01AF),
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color(0xFF8F01AF),
                                side: BorderSide(
                                  color: Color(0xFFF6AFCF),
                                  width: 2,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  ventanaConf = false;
                                });
                              },
                              child: Text(
                                "No",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color(0xFF8F01AF),
                                side: BorderSide(
                                  color: Color(0xFFF6AFCF),
                                  width: 2,
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  ventanaConf = false;
                                });
                                String texto = "";
                                try {
                                  final res = await http.put(
                                    Uri.parse(
                                      "${LocalStorage.local('conexion')}/inventario/${LocalStorage.local('locación')}/reiniciarMovimientos",
                                    ),
                                    headers: {
                                      "Accept": "application/json",
                                      "content-type":
                                          "application/json; charset=UTF-8",
                                    },
                                  );
                                  if (res.statusCode == 200) {
                                    texto = "Reinicio exitoso.";
                                  } else {
                                    texto = "${res.reasonPhrase}";
                                  }
                                } on TimeoutException catch (e) {
                                  texto = "Error: ${e.message.toString()}";
                                } on SocketException catch (e) {
                                  texto = "Error: ${e.message.toString()}";
                                } on Error catch (e) {
                                  texto = "Error: ${e.toString()}";
                                }
                                ToastText.toast(texto, true);
                              },
                              child: Text(
                                "Si",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
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
            Carga.ventanaCarga(carga),
          ],
        ),
      ),
    );
  }

  Drawer drawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFFFDC930)),
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
                    Text(
                      "Bienvenido, ",
                      style: TextStyle(fontSize: 15, color: Color(0xFF8F01AF)),
                    ),
                    IconButton(
                      onPressed: () {
                        logout(context);
                      },
                      tooltip: "Cerrar sesión",
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        backgroundColor: Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Color(0xFF8F01AF), width: 3),
                        ),
                      ),
                      icon: Icon(
                        Icons.logout_rounded,
                        color: Color(0xFF8F01AF),
                        size: 25,
                      ),
                    ),
                  ],
                ),
                Text(
                  LocalStorage.local('usuario'),
                  style: TextStyle(fontSize: 30, color: Color(0xFF8F01AF)),
                  maxLines: 1,
                ),
                Text(
                  LocalStorage.local('puesto'),
                  style: TextStyle(fontSize: 15, color: Color(0xFF8F01AF)),
                  maxLines: 1,
                ),
                Text(
                  "Mostrando: ${LocalStorage.local('locación')}",
                  style: TextStyle(fontSize: 20, color: Color(0xFF8F01AF)),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * .585,
            decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                TextButton.icon(
                  onPressed: () {
                    if (Tablas.valido) {
                      datosExcel(context);
                    } else {
                      ToastText.toast("Espera a que los datos carguen.", false);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    backgroundColor: Color(0xFF8F01AF),
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
                    if (Tablas.valido) {
                      setState(() {
                        ventanaConf = true;
                      });
                      Navigator.of(context).pop();
                    } else {
                      ToastText.toast("Espera a que los datos carguen.", false);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    backgroundColor: Color(0xFF8F01AF),
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
                    if (Tablas.valido) {
                      await _getListas(context);
                    } else {
                      ToastText.toast("Espera a que los datos carguen.", false);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    backgroundColor: Color(0xFF8F01AF),
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
                  onPressed: () async {
                    if (Tablas.valido)  {
                      await historialOrdenes(context);
                    } else {
                      ToastText.toast("Espera a que los datos carguen.", false);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(color: Color(0xFF8F01AF), width: 5),
                    ),
                  ),
                  icon: Icon(
                    Icons.add_shopping_cart_rounded,
                    color: Color(0xFF8F01AF),
                    size: 25,
                  ),
                  label: Text(
                    "Nueva orden",
                    style: TextStyle(fontSize: 20, color: Color(0xFF8F01AF)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget barraSuperior(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Botones.btnRctMor(
          "Abrir menú",
          Icon(Icons.menu_rounded, size: 35, color: Color(0xFFFFFFFF)),
          accion: () => Scaffold.of(context).openDrawer(),
        ),
        CampoTexto.barraBusqueda(
          MediaQuery.of(context).size.width * .875,
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
        return Tablas.barraDatos(
          MediaQuery.sizeOf(context).width,
          [.05, .25, .175, .08, .175, .075, .075, .075],
          [
            lista[index].id.toString(),
            lista[index].nombre,
            lista[index].tipo,
            lista[index].unidades.toString(),
            lista[index].area,
            lista[index].entrada.toString(),
            lista[index].salida.toString(),
            lista[index].perdida.toString(),
          ],
          [],
          true,
          () async => {
            await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text),
            if (context.mounted)
              {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Producto(productoInfo: lista[index]),
                  ),
                ),
              },
          },
        );
      },
    );
  }
}
