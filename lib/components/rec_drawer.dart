import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/articulos_model.dart';
import 'package:inventarios/models/historial_model.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/add_producto.dart';
import 'package:inventarios/pages/articulo_info.dart';
import 'package:inventarios/pages/orden_salida.dart';
import 'package:inventarios/pages/orden_salida_prod.dart';
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
                    Textos.textoGeneral('Bienvenido, ', 15, true, false, 1),
                    Botones.btnRctMor(
                      'Cerrar sesión',
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
                  1,
                ),
                Textos.textoGeneral(
                  LocalStorage.local('puesto'),
                  15,
                  true,
                  false,
                  1,
                ),
                Consumer<Ventanas>(
                  builder: (ctx, ventanas, child) {
                    return Textos.textoGeneral(
                      'Mostrando: ${Ventanas.getInventario()}',
                      20,
                      true,
                      false,
                      1,
                    );
                  },
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
    List<ProductoModel> productos = await ProductoModel.getProductos('id', '');
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Inventario'];
    excel.delete('Sheet1');
    List<String> headers = [
      'id',
      'Nombre',
      'Area',
      'Tipo',
      'Unidades',
      'Cantidad por unidad',
      'Total',
      'Mínimo de productos',
      'Entrada',
      'Salida',
      'Perdidas',
      'Ultima Modificación',
    ];
    for (int i = 0; i < headers.length; i++) {
      establecerCelda(sheetObject, i, 0, TextCellValue(headers[i]));
    }
    for (int i = 0; i < productos.length; i++) {
      ProductoModel item = productos[i];
      String perdidas = 'No hay perdidas registradas';
      if (item.perdidaCantidad.isNotEmpty) {
        perdidas = '${item.perdidaCantidad[0]} ${item.perdidaRazones[0]}';
        if (item.perdidaCantidad.length > 1) {
          for (int j = 1; j < item.perdidaCantidad.length; j++) {
            perdidas =
                '$perdidas, ${item.perdidaCantidad[j]} ${item.perdidaRazones[j]}';
          }
        }
      }
      establecerCelda(sheetObject, 0, i + 1, IntCellValue(item.id));
      establecerCelda(sheetObject, 1, i + 1, TextCellValue(item.nombre));
      establecerCelda(sheetObject, 2, i + 1, TextCellValue(item.tipo));
      establecerCelda(sheetObject, 3, i + 1, TextCellValue(item.area));
      establecerCelda(sheetObject, 4, i + 1, DoubleCellValue(item.unidades));
      establecerCelda(
        sheetObject,
        5,
        i + 1,
        DoubleCellValue(item.cantidadPorUnidad),
      );
      establecerCelda(
        sheetObject,
        6,
        i + 1,
        DoubleCellValue((item.unidades * item.cantidadPorUnidad)),
      );
      establecerCelda(sheetObject, 7, i + 1, IntCellValue(item.limiteProd));
      establecerCelda(sheetObject, 8, i + 1, DoubleCellValue(item.entrada));
      establecerCelda(sheetObject, 9, i + 1, DoubleCellValue(item.salida));
      establecerCelda(sheetObject, 10, i + 1, TextCellValue(perdidas));
      establecerCelda(
        sheetObject,
        11,
        i + 1,
        TextCellValue('${item.ultimaModificacion}: ${item.ultimaModificacion}'),
      );
    }
    String mensaje = "Se canceló el proceso";
    String fecha =
        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}';
    if (kIsWeb) {
      List<int>? fileBytes = excel.save(fileName: '$fecha.xlsx');
      if (fileBytes != null) mensaje = 'Descargando el archivo';
    } else {
      var status = await Permission.manageExternalStorage.request();
      if (status.isDenied) await Permission.manageExternalStorage.request();
      if (status.isPermanentlyDenied) openAppSettings();
      if (status.isGranted) {
        final path = '/storage/emulated/0/Download/Inventarios';
        List<int>? fileBytes = excel.save();
        if (fileBytes != null) {
          File('$path/$fecha.xlsx')
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes, flush: true);
          mensaje = 'Archivo guardado en: $path/$fecha.xlsx';
        }
      }
    }
    Textos.toast(mensaje, true);
    if (context.mounted) context.read<Carga>().cargaBool(false);
  }

  static Future<String> historialExcel(
    BuildContext context,
    String fechaInicial,
    String fechaFinal,
  ) async {
    List<HistorialModel> historial = await HistorialModel.getAllHistorial(
      fechaInicial,
      fechaFinal,
    );
    String mensaje = 'Error: No hay registros en esa fecha.';
    if (historial.isNotEmpty || historial.last.mensaje.isEmpty) {
      var excel = Excel.createExcel();
      int contador = 0;
      Sheet sheetObject = excel['Historial'];
      excel.delete('Sheet1');
      List<String> headers = [
        'id',
        'Nombre',
        'Fecha',
        'Unidades',
        'Entradas',
        'Salidas',
        'Perdidas',
        'Hora de modificación',
        'Usuario que modifico',
        'Detalle de perdidas',
      ];
      for (int i = 0; i < headers.length; i++) {
        establecerCelda(sheetObject, i, 0, TextCellValue(headers[i]));
      }
      for (int i = 0; i < historial.length; i++) {
        contador += 1;
        int cantidad = contador + historial[i].unidades.length - 1;
        HistorialModel item = historial[i];
        String perdidas = 'No hay perdidas registradas';
        if (item.cantidades.isNotEmpty) {
          perdidas = '${item.cantidades[0]}: ${item.razones[0]}';
          if (item.cantidades.length > 1) {
            for (int j = 1; j < item.razones.length; j++) {
              perdidas = '$perdidas, ${item.cantidades[j]}: ${item.razones[j]}';
            }
          }
        }
        establecerCelda(
          sheetObject,
          0,
          contador,
          IntCellValue(item.idProducto),
        );
        establecerCelda(sheetObject, 1, contador, TextCellValue(item.nombre));
        establecerCelda(sheetObject, 2, contador, TextCellValue(item.fecha));
        establecerCelda(sheetObject, 7, contador, TextCellValue(perdidas));
        sheetObject.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: contador),
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: cantidad),
        );
        sheetObject.merge(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: contador),
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: cantidad),
        );
        sheetObject.merge(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: contador),
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: cantidad),
        );
        sheetObject.merge(
          CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: contador),
          CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: cantidad),
        );
        for (int j = 0; j < item.unidades.length; j++) {
          establecerCelda(
            sheetObject,
            3,
            j + contador,
            DoubleCellValue(item.unidades[j]),
          );
          establecerCelda(
            sheetObject,
            4,
            j + contador,
            DoubleCellValue(item.entradas[j]),
          );
          establecerCelda(
            sheetObject,
            5,
            j + contador,
            DoubleCellValue(item.salidas[j]),
          );
          establecerCelda(
            sheetObject,
            6,
            j + contador,
            IntCellValue(item.perdidas[j]),
          );
          establecerCelda(
            sheetObject,
            8,
            j + contador,
            TextCellValue(item.horasModificacion[j]),
          );
          establecerCelda(
            sheetObject,
            9,
            j + contador,
            TextCellValue(item.usuarioModificacion[j]),
          );
        }
        contador = cantidad;
      }
      mensaje = "Error: Se canceló el proceso";
      if (kIsWeb) {
        List<int>? fileBytes = excel.save(
          fileName: 'historial $fechaInicial $fechaFinal.xlsx',
        );
        if (fileBytes != null) mensaje = 'Descargando archivo';
      } else {
        var status = await Permission.manageExternalStorage.request();
        if (status.isDenied) await Permission.manageExternalStorage.request();
        if (status.isPermanentlyDenied) openAppSettings();
        mensaje = 'Error: Se aborto el proceso';
        if (status.isGranted) {
          final path = '/storage/emulated/0/Download/Inventarios';
          List<int>? fileBytes = excel.save();
          if (fileBytes != null) {
            File('$path/historial $fechaInicial $fechaFinal.xlsx')
              ..createSync(recursive: true)
              ..writeAsBytesSync(fileBytes, flush: true);
            mensaje =
                'Archivo guardado en: $path/historial $fechaInicial $fechaFinal.xlsx';
          }
        }
      }
    }
    return mensaje;
  }

  static void establecerCelda(Sheet hoja, int col, int row, CellValue valor) {
    hoja.updateCell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
      valor,
      cellStyle: CellStyle(
        verticalAlign: VerticalAlign.Top,
        horizontalAlign: HorizontalAlign.Center,
        textWrapping: TextWrapping.WrapText,
      ),
    );
  }

  static void scanProducto(BuildContext ctx, StatefulWidget ruta) async {
    String prod;
    ctx.read<Carga>().cargaBool(true);
    Navigator.of(ctx).pop();
    prod = await Textos.scan(ctx);
    bool flag = true;
    List<ProductoModel> productos = await ProductoModel.getProductos('id', '');
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
      Textos.toast('No se reconocio el codigo.', false);
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
    List<ArticulosModel> articulos = await ArticulosModel.getArticulos(
      'id',
      '',
    );
    for (int i = 0; i < articulos.length; i++) {
      if (articulos[i].codigoBarras == prod) {
        flag = false;
        if (ctx.mounted) {
          Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(
              builder: (cxt) => ArticuloInfo(articulo: articulos[i]),
            ),
          );
        }
      }
    }
    if (flag) {
      Textos.toast('No se reconocio el codigo.', false);
    }
    if (ctx.mounted) {
      ctx.read<Carga>().cargaBool(false);
    }
  }

  static Future<void> getListas(BuildContext ctx, StatefulWidget ruta) async {
    String texto = '';
    ctx.read<Carga>().cargaBool(true);
    Navigator.of(ctx).pop();
    List<ArticulosModel> articulos = await ArticulosModel.getArticulos(
      'id',
      '',
    );
    List areas = await ProductoModel.getAreas();
    if (articulos.last.nombre == 'Error') {
      texto = articulos.last.mensaje;
    }
    if (areas.last.split(': ')[0] == 'Error') {
      texto = areas.last.split(': ')[1];
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
    CampoTexto.seleccionFiltro = Filtros.id;
    List<ProductoModel> productos = await ProductoModel.getProductos('id', '');
    if (productos[0].nombre != 'Error') {
      if (ctx.mounted) {
        Textos.crearLista(productos.last.id, Color(0xFFFDC930));
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

  static Future<StatefulWidget> salidaOrdenesProd(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    CampoTexto.seleccionFiltro = Filtros.id;
    List<ProductoModel> productos = await ProductoModel.getProductosProd(
      'id',
      '',
    );
    if (productos[0].nombre != 'Error') {
      if (ctx.mounted) {
        Textos.crearLista(productos.last.id, Color(0xFFFDC930));
      }
    } else {
      Textos.toast(productos[0].tipo, false);
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
    return OrdenSalidaProd();
  }
}
