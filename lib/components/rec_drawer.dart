import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/articulos_model.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/add_producto.dart';
import 'package:inventarios/pages/articulo_info.dart';
import 'package:inventarios/pages/orden_salida.dart';
import 'package:inventarios/pages/producto.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'botones.dart';
import 'carga.dart';

class RecDrawer {
  static Drawer drawer(BuildContext ctx, List<Widget> botones) {
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
                        ctx.read<Carga>().cargaBool(true),
                        Textos.limpiarLista(),
                        LocalStorage.logout(ctx),
                        ctx.read<Carga>().cargaBool(false),
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
                children: botones,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> datosExcel(BuildContext context) async {
    context.read<Carga>().cargaBool(true);
    Navigator.of(context).pop();
    List<ProductoModel> productos = await ProductoModel.getProductos("id", "");
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
      'PerdidaCantidad',
      'PerdidaRazones',
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
      String pCant = "No hay perdidas registradas";
      String pRaz = "No hay perdidas registradas";
      if (item.perdidaCantidad.isNotEmpty) {
        pCant = item.perdidaCantidad[0].toString();
        pRaz = item.perdidaRazones[0];
        if (item.perdidaCantidad.length > 1) {
          for (int i = 1; i < item.perdidaCantidad.length; i++) {
            pCant = "$pCant, ${item.perdidaCantidad[0].toString()}";
            pRaz = "$pRaz, ${item.perdidaRazones}";
          }
        }
      }
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(
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
          .value = DoubleCellValue(
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
          .value = TextCellValue(
        pCant,
      );
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1))
          .value = TextCellValue(
        pRaz,
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

  static void scanProducto(BuildContext ctx, StatefulWidget ruta) async {
    String prod;
    ctx.read<Carga>().cargaBool(true);
    Navigator.of(ctx).pop();
    prod = await Textos.scan(ctx);
    bool flag = true;
    List<ProductoModel> productos = await ProductoModel.getProductos("id", "");
    for (int i = 0; i < productos.length; i++) {
      if (productos[i].codigoBarras == prod) {
        flag = false;
        if (ctx.mounted) {
          Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(
              builder: (cxt) =>
                  Producto(productoInfo: productos[i], ruta: ruta),
            ),
          );
        }
      }
    }
    if (flag) {
      Textos.toast("No se reconocio el codigo.", false);
    }
    if (ctx.mounted) {
      ctx.read<Carga>().cargaBool(false);
    }
  }

  static void scanArticulo(BuildContext ctx) async {
    String prod;
    ctx.read<Carga>().cargaBool(true);
    Navigator.of(ctx).pop();
    prod = await Textos.scan(ctx);
    bool flag = true;
    List<ArticulosModel> articulos = await ArticulosModel.getArticulos("id", "");
    for (int i = 0; i < articulos.length; i++) {
      if (articulos[i].codigoBarras == prod) {
        flag = false;
        if (ctx.mounted) {
          Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(
              builder: (cxt) =>
                  ArticuloInfo(articulo: articulos[i]),
            ),
          );
        }
      }
    }
    if (flag) {
      Textos.toast("No se reconocio el codigo.", false);
    }
    if (ctx.mounted) {
      ctx.read<Carga>().cargaBool(false);
    }
  }

  static Future<void> getListas(BuildContext ctx, StatefulWidget ruta) async {
    String texto = "";
    ctx.read<Carga>().cargaBool(true);
    Navigator.of(ctx).pop();
    List<ArticulosModel> articulos = await ArticulosModel.getArticulos(
      "id",
      "",
    );
    List areas = await ProductoModel.getAreas();
    if (articulos[0].toString().split(": ")[0] == "Error") {
      texto = articulos[0].toString().split(": ")[1];
    }
    if (areas[0].toString().split(": ")[0] == 'Error') {
      texto = areas[0].toString().split(": ")[1];
    }
    if (texto.isNotEmpty) {
      Textos.toast(texto, false);
    } else {
      await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text);
      if (ctx.mounted) {
        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(
            builder: (context) => AddProducto(
              listaArticulos: articulos,
              areas: areas,
              ruta: ruta,
            ),
          ),
        );
      }
    }
    if (ctx.mounted) {
      ctx.read<Carga>().cargaBool(false);
    }
  }

  static Future<void> salidaOrdenes(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    Navigator.of(ctx).pop();
    List<ProductoModel> productos = await ProductoModel.getProductos("id", "");
    if (productos[0].nombre != "Error") {
      if (ctx.mounted) {
        Textos.crearLista(productos.length, Color(0xFFFDC930));
        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(builder: (context) => OrdenSalida()),
        );
      }
    } else {
      Textos.toast(productos[0].tipo, false);
    }
    if (ctx.mounted) {
      ctx.read<Carga>().cargaBool(false);
    }
  }
}
