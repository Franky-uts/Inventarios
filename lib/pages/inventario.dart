import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/orden_salida.dart';
import 'package:inventarios/pages/producto.dart';
import 'package:inventarios/pages/add_producto.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:inventarios/components/botones.dart';
import 'package:provider/provider.dart';

class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  List tipos = [];
  List areas = [];
  List<ProductoModel> productos = [];

  @override
  void initState() {
    getProductos();
    super.initState();
  }

  @override
  void dispose() {
    tipos.clear();
    areas.clear();
    super.dispose();
  }

  Future<void> getProductos() async =>
      productos = await ProductoModel.getProductos("id", "");

  Future<void> historialOrdenes(BuildContext ctx) async {
    if (productos.length < 2) {
      await getProductos();
    }
    if (ctx.mounted) {
      ctx.read<Carga>().cargaBool(true);
      Navigator.of(ctx).pop();
    }
    if (productos[0].nombre != "Error") {
      if (ctx.mounted) {
        Textos.crearLista(productos.length, 0xFFFDC930);
        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(
            builder: (context) => OrdenSalida(productosPorId: productos),
          ),
        );
        ctx.read<Carga>().cargaBool(false);
        ctx.read<Ventanas>().tabla(false);
        ctx.read<Tablas>().valido(false);
      }
    } else {
      Textos.toast(productos[0].tipo, false);
      if (ctx.mounted) {
        ctx.read<Carga>().cargaBool(false);
      }
    }
  }

  void scan(BuildContext ctx) async {
    String prod;
    ctx.read<Carga>().cargaBool(true);
    prod = await Textos.scan(context);
    bool flag = true;
    if (productos.length < 2) {
      await getProductos();
    }
    for (int i = 0; i < productos.length; i++) {
      print(productos[i].codigoBarras);
      if (productos[i].codigoBarras == prod) {
        flag = false;
        if (ctx.mounted) {
          Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(
              builder: (cxt) => Producto(productoInfo: productos[i]),
            ),
          );
          ctx.read<Carga>().cargaBool(false);
        }
      }
    }
    if (flag && ctx.mounted) {
      Textos.toast("No se reconocio el codigo.", false);
      ctx.read<Carga>().cargaBool(false);
    }
  }

  Future<void> _getListas(BuildContext ctx) async {
    context.read<Carga>().cargaBool(true);
    Navigator.of(context).pop();
    tipos = await ProductoModel.getTipos();
    areas = await ProductoModel.getAreas();
    if (tipos[0].toString().split(": ")[0] == "Error") {
      Textos.toast(tipos[0].toString().split(": ")[1], false);
      if (ctx.mounted) {
        ctx.read<Carga>().cargaBool(false);
      }
    } else if (areas[0].toString().split(": ")[0] == "Error") {
      Textos.toast(areas[0].toString().split(": ")[1], false);
      if (ctx.mounted) {
        ctx.read<Carga>().cargaBool(false);
      }
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
        ctx.read<Carga>().cargaBool(false);
      }
    }
  }

  Future<void> datosExcel(BuildContext context) async {
    if (productos.length < 2) {
      await getProductos();
    }
    if (context.mounted) {
      context.read<Carga>().cargaBool(true);
    }
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
        Textos.toast('Archivo guardado en: $path/$fecha.xlsx', true);
      }
    } else {
      Textos.toast('Se aborto el proceso', false);
    }
    if (context.mounted) {
      context.read<Carga>().cargaBool(false);
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
              builder: (context, ventanas, carga, child) {
                return Ventanas.ventanaEmergente(
                  "¿Seguro quieres establecer todas las entradas, salidas y perdidas en 0?",
                  "No, volver",
                  "Si, continuar",
                  () => ventanas.emergente(false),
                  () async => {
                    ventanas.emergente(false),
                    carga.cargaBool(true),
                    Textos.toast(await ProductoModel.reiniciarESP(), true),
                    if (context.mounted)
                      {context.read<Carga>().cargaBool(false)},
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
                    Textos.textoGeneral("Bienvenido, ", 15, true, false),
                    Botones.btnRctMor(
                      "Cerrar sesión",
                      0,
                      Icons.logout_rounded,
                      true,
                      () => {
                        context.read<Carga>().cargaBool(true),
                        LocalStorage.logout(context),
                        context.read<Carga>().cargaBool(false),
                      },
                    ),
                  ],
                ),
                Textos.textoGeneral(
                  LocalStorage.local('usuario'),
                  30,
                  true,
                  false,
                ),
                Textos.textoGeneral(
                  LocalStorage.local('puesto'),
                  15,
                  true,
                  false,
                ),
                Textos.textoGeneral(
                  "Mostrando: ${LocalStorage.local('locación')}",
                  20,
                  true,
                  false,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Botones.icoCirMor(
                    "Descargar reporte",
                    Icons.download_rounded,
                    false,
                    () => {
                      context.read<Carga>().cargaBool(true),
                      if (Tablas.getValido())
                        {datosExcel(context)}
                      else
                        {
                          Textos.toast(
                            "Espera a que los datos carguen.",
                            false,
                          ),
                        },
                      context.read<Carga>().cargaBool(false),
                    },
                  ),
                  Botones.icoCirMor(
                    "Reiniciar movimientos",
                    Icons.refresh_rounded,
                    false,
                    () => {
                      if (Tablas.getValido())
                        {
                          Navigator.of(context).pop(),
                          context.read<Ventanas>().emergente(true),
                        }
                      else
                        {
                          Textos.toast(
                            "Espera a que los datos carguen.",
                            false,
                          ),
                        },
                    },
                  ),
                  Botones.icoCirMor(
                    "Añadir un producto",
                    Icons.edit_note_rounded,
                    false,
                    () async => {
                      if (Tablas.getValido())
                        {
                          context.read<Carga>().cargaBool(true),
                          await _getListas(context),
                        }
                      else
                        {
                          Textos.toast(
                            "Espera a que los datos carguen.",
                            false,
                          ),
                        },
                    },
                  ),
                  Botones.icoCirMor(
                    "Escanear codigo",
                    Icons.barcode_reader,
                    false,
                    () => scan(context),
                  ),
                  Botones.icoCirMor(
                    "Nueva orden",
                    Icons.add_shopping_cart_rounded,
                    true,
                    () async => {
                      if (Tablas.getValido())
                        {
                          context.read<Carga>().cargaBool(true),
                          await historialOrdenes(context),
                        }
                      else
                        {
                          Textos.toast(
                            "Espera a que los datos carguen.",
                            false,
                          ),
                        },
                    },
                  ),
                ],
              ),
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
          35,
          Icons.menu_rounded,
          false,
          () => Scaffold.of(context).openDrawer(),
        ),
        Container(
          width: MediaQuery.of(context).size.width * .875,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Consumer2<Tablas, CampoTexto>(
            builder: (context, tablas, campoTexto, child) {
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
                      builder: (context) =>
                          Producto(productoInfo: lista[index]),
                    ),
                  ),
                },
            },
          ),
        );
      },
    );
  }
}
