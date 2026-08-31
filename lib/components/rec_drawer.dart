import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/articulos_model.dart';
import 'package:inventarios/models/historial_model.dart';
import 'package:inventarios/models/orden_model.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/add_producto.dart';
import 'package:inventarios/pages/articulo.dart';
import 'package:inventarios/pages/producto.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class RecDrawer {
  //Este es un componente Drawer usado en todas las páginas donde se abre una
  //ventana lateral la cual tiene información del usuario como su nombre, su
  //puesto y el almacén donde está operando, también cuenta con la posibilidad
  //de añadir botones extra por cada página diferente, y por último se cuenta
  //con un botón para cerrar la sesión, al presionarse se borraran los datos
  //de usuario en el dispositivo y te devolverá al inicio de sesión y podrás
  //seguir usando el programa cunado ingreses un usuario y contraseña válidos.
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
                    Textos.textoGeneral('Bienvenido, ', true, 1, size: 15),
                    Botones.btnRctMor(
                      'Cerrar sesión',
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
                  true,
                  1,
                  size: 30,
                ),
                Textos.textoGeneral(
                  LocalStorage.local('puesto'),
                  true,
                  1,
                  size: 15,
                ),
                Consumer<Ventanas>(
                  builder: (ctx, ventanas, child) {
                    return Textos.textoGeneral(
                      'Mostrando: ${Ventanas.getInventario()}',
                      true,
                      1,
                      size: 20,
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

  //Esta función genera un archivo en Excel con toda la información actual del
  //almacén (id, Nombre, Tipo, Área, Cantidad por unidad, Mínimo de productos,
  //Entrada, Salida, Perdidas y Ultima Modificación por cada producto).
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
      'Tipo',
      'Área',
      'Cantidad por unidad',
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
      establecerCelda(
        sheetObject,
        4,
        i + 1,
        DoubleCellValue(item.cantidadPorUnidad),
      );
      establecerCelda(sheetObject, 5, i + 1, IntCellValue(item.limiteProd));
      establecerCelda(sheetObject, 6, i + 1, DoubleCellValue(item.entrada));
      establecerCelda(sheetObject, 7, i + 1, DoubleCellValue(item.salida));
      establecerCelda(sheetObject, 8, i + 1, TextCellValue(perdidas));
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
    Textos.toast(mensaje);
    if (context.mounted) context.read<Carga>().cargaBool(false);
  }

  //Esta función genera un archivo en Excel con toda la información actual de
  //todos los articulos disponibles (id, Nombre, Tipo, Área, Código de barras).
  static Future<void> articulosExcel(BuildContext context) async {
    context.read<Carga>().cargaBool(true);
    Navigator.of(context).pop();
    List<ArticulosModel> productos = await ArticulosModel.getArticulos(
      'id',
      '',
    );
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Inventario'];
    excel.delete('Sheet1');
    List<String> headers = ['id', 'Nombre', 'Tipo', 'Área', 'Código de barras'];
    for (int i = 0; i < headers.length; i++) {
      establecerCelda(sheetObject, i, 0, TextCellValue(headers[i]));
    }
    for (int i = 0; i < productos.length; i++) {
      ArticulosModel item = productos[i];
      establecerCelda(sheetObject, 0, i + 1, IntCellValue(item.id));
      establecerCelda(sheetObject, 1, i + 1, TextCellValue(item.nombre));
      establecerCelda(sheetObject, 2, i + 1, TextCellValue(item.tipo));
      establecerCelda(sheetObject, 3, i + 1, TextCellValue(item.area));
      establecerCelda(sheetObject, 4, i + 1, TextCellValue(item.codigoBarras));
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
    Textos.toast(mensaje);
    if (context.mounted) context.read<Carga>().cargaBool(false);
  }

  //Esta función genera un archivo en Excel con toda la información actual de
  //una orden seleccionada por el usuario, solo los productores pueden imprimir
  //órdenes (id, Locación, Cant. Articulos, Fecha de orden).
  static Future<void> orden(BuildContext context, List<bool> estados) async {
    context.read<Carga>().cargaBool(true);
    Navigator.of(context).pop();
    List<OrdenModel> ordenes = await OrdenModel.getAllOrdenes('id', estados);
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Inventario'];
    excel.delete('Sheet1');
    List<String> headers = [
      'id',
      'Locación',
      'Cant. Articulos',
      'Fecha de orden',
    ];
    for (int i = 0; i < headers.length; i++) {
      establecerCelda(sheetObject, i, 0, TextCellValue(headers[i]));
    }
    for (int i = 0; i < ordenes.length; i++) {
      OrdenModel item = ordenes[i];
      establecerCelda(sheetObject, 0, i + 1, IntCellValue(item.id));
      establecerCelda(sheetObject, 1, i + 1, TextCellValue(item.locacion));
      establecerCelda(sheetObject, 2, i + 1, IntCellValue(item.cantArticulos));
      establecerCelda(sheetObject, 3, i + 1, TextCellValue(item.fechaOrden));
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
    Textos.toast(mensaje);
    if (context.mounted) context.read<Carga>().cargaBool(false);
  }

  //Esta función genera un archivo en Excel con toda la información actual de
  //un producto en una fecha específica (id, Nombre, Fecha, Entradas, Salidas,
  //Perdidas, Hora de modificación, Usuario que modifico, Detalle de perdidas).
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
        int cantidad = contador + historial[i].movimientos - 1;
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
        establecerCelda(sheetObject, 0, contador, IntCellValue(item.id));
        establecerCelda(sheetObject, 1, contador, TextCellValue(item.nombre));
        establecerCelda(sheetObject, 2, contador, TextCellValue(item.fecha));
        establecerCelda(sheetObject, 6, contador, TextCellValue(perdidas));
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
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: contador),
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: cantidad),
        );
        for (int j = 0; j < item.movimientos; j++) {
          establecerCelda(
            sheetObject,
            3,
            j + contador,
            DoubleCellValue(item.entradas[j]),
          );
          establecerCelda(
            sheetObject,
            4,
            j + contador,
            DoubleCellValue(item.salidas[j]),
          );
          establecerCelda(
            sheetObject,
            5,
            j + contador,
            IntCellValue(item.perdidas[j]),
          );
          establecerCelda(
            sheetObject,
            7,
            j + contador,
            TextCellValue(item.horasModificacion[j]),
          );
          establecerCelda(
            sheetObject,
            8,
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

  //Este es un componente tipo celda de Excel usado por las funciones que
  //devuelven un archivo Excel.
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

  //Este es un método usado para poder escanear un código de barras y darte la
  //información de dicho producto relacionado, pero su uso cambiará dependiendo
  //del sistema operativo donde se ejecute el programa, si se usa en web
  //entonces se podrá escribir en el campo de texto o conectar un escáner
  //físico, en el caso de que se use un dispositivo móvil entonces se abrirá la
  //cámara y se usara como escáner.
  static void scanProducto(BuildContext ctx) async {
    Navigator.of(ctx).pop();
    if (kIsWeb) {
      ctx.read<Ventanas>().scan(true);
    } else {
      ctx.read<Carga>().cargaBool(true);
      String producto = await Textos.scan(ctx);
      if (ctx.mounted) rutaProducto(producto, ctx);
    }
  }

  static void rutaProducto(String prod, BuildContext ctx) async {
    bool flag = true;
    List<ProductoModel> productos = await ProductoModel.getProductos('id', '');
    for (int i = 0; i < productos.length; i++) {
      if (productos[i].codigoBarras == prod) {
        flag = false;
        if (ctx.mounted) {
          ctx.read<Ventanas>().scan(false);
          ctx.read<Producto>().setProducto(productos[i]);
          ctx.read<Producto>().producto(true);
          ctx.read<Carga>().cargaBool(false);
        }
      }
    }
    if (flag) Textos.toast('No se reconocio el codigo.');
  }

  //Este es un método usado para poder escanear un código de barras y darte la
  //información de dicho articulo relacionado, pero su uso cambiará dependiendo
  //del sistema operativo donde se ejecute el programa, si se usa en web
  //entonces se podrá escribir en el campo de texto o conectar un escáner
  //físico, en el caso de que se use un dispositivo móvil entonces se abrirá la
  //cámara y se usara como escáner.
  static void scanArticulo(BuildContext ctx) async {
    Navigator.of(ctx).pop();
    if (kIsWeb) {
      ctx.read<Ventanas>().scan(true);
    } else {
      ctx.read<Carga>().cargaBool(true);
      String articulo = await Textos.scan(ctx);
      if (ctx.mounted) rutaArticulo(articulo, ctx);
    }
  }

  static void rutaArticulo(String prod, BuildContext ctx) async {
    bool flag = true;
    List<ArticulosModel> articulos = await ArticulosModel.getArticulos(
      'id',
      '',
    );
    for (int i = 0; i < articulos.length; i++) {
      if (articulos[i].codigoBarras == prod) {
        flag = false;
        if (ctx.mounted) {
          ctx.read<Ventanas>().scan(false);
          ctx.read<Articulo>().articulo(articulos[i]);
          ctx.read<Articulo>().art(true);
          ctx.read<Carga>().cargaBool(false);
        }
      }
    }
    if (flag) Textos.toast('No se reconocio el codigo.');
  }

  //Este es un método usado para poder cargar la lista de artículos, (la
  //diferencia entre productos y artículos es que un producto tiene la
  //información de un artículo, una tienda establecida, entradas, salidas y
  //perdidas; así múltiples productos pueden tener la información de un
  //artículo sin necesidad de repetir la misma información por tienda, mientras
  //se conserva la consistencia y cada tienda no tienen un producto con un
  //nombre similar, pero con ciertas características diferentes que generen
  //confusión al proveedor).
  static Future<void> getListas(BuildContext ctx) async {
    String texto = '';
    ctx.read<Carga>().cargaBool(true);
    Navigator.of(ctx).pop();
    List<ArticulosModel> articulos = await ArticulosModel.getArticulos(
      'Nombre',
      '',
    );
    List areas = await ProductoModel.getAreas();
    if (articulos.last.mensaje != '') texto = articulos.last.mensaje;
    if (areas.last.split(': ')[0] == 'Error') texto = areas.last.split(': ')[1];
    (texto.isNotEmpty)
        ? Textos.toast(texto)
        : {
            if (ctx.mounted)
              Navigator.of(ctx).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AddProducto(listaArticulos: articulos, areas: areas),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.ease)),
                          ),
                          child: child,
                        );
                      },
                ),
              ),
          };
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  //Este es un método usado para poder mostrar una animación "bonita" al
  //momento de pasar de una "página principal" a una "página secundaria" y
  //viceversa (ténganse como entendido que las páginas principales son todas
  //aquellas que tienen listas y permiten la búsqueda y filtrado de las mismas,
  //mientras que las páginas secundarias son todas aquellas que permitan añadir,
  //editar o borrar un producto, orden, articulo, etc. o realizar cualquier
  //otra acción).
  static void pushAnim(StatefulWidget ruta, BuildContext ctx) {
    Navigator.of(ctx).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ruta,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.ease)),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
