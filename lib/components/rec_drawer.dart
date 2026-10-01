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
import 'package:inventarios/models/registro_model.dart';
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
    List<ProductoModel> productos = await ProductoModel.getProductos(
      'Area',
      '',
    );
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Inventario'];
    excel.delete('Sheet1');
    List<String> headers = [
      'id',
      'Nombre',
      'Tipo',
      'Área',
      'Cantidad por unidad',
      'Cantidad por paquete/pieza',
      'Mínimo de productos',
      'Contenedores que entraron',
      'Paquetes que entraron',
      'Entradas',
      'Contenedores que salieron',
      'Paquetes que salieron',
      'Salidas',
      'Perdidas',
      'Ultima Modificación',
    ];
    for (int i = 0; i < headers.length; i++) {
      establecerCelda(
        sheetObject,
        i,
        0,
        TextCellValue(headers[i]),
        i.isEven ? '#e5e5e5' : '#cccccc',
      );
    }
    for (int i = 0; i < productos.length; i++) {
      ProductoModel item = productos[i];
      String perdidas = 'No hay perdidas registradas';
      if (item.perdidaCantidad.isNotEmpty) {
        perdidas = '${item.perdidaCantidad[0]} ${item.perdidaRazones[0]}';
        if (item.perdidaCantidad.length > 1) {
          for (int j = 1; j < item.perdidaCantidad.length; j++) {
            perdidas =
                '$perdidas, ${item.perdidaCantidad[j]} ${item.perdidaRazones[j]}\n';
          }
        }
      }
      establecerCelda(sheetObject, 0, i + 1, IntCellValue(item.id), '#e5e5e5');
      establecerCelda(
        sheetObject,
        1,
        i + 1,
        TextCellValue(item.nombre),
        '#cccccc',
      );
      establecerCelda(
        sheetObject,
        2,
        i + 1,
        TextCellValue(item.tipo),
        '#e5e5e5',
      );
      establecerCelda(
        sheetObject,
        3,
        i + 1,
        TextCellValue(item.area),
        '#cccccc',
      );
      establecerCelda(
        sheetObject,
        4,
        i + 1,
        DoubleCellValue(item.cantidadPorUnidad),
        '#e5e5e5',
      );
      establecerCelda(
        sheetObject,
        5,
        i + 1,
        item.tipo == 'Caja (Paquetes)' || item.tipo == 'Caja (Piezas)'
            ? DoubleCellValue(item.cantidadPorPaquete)
            : TextCellValue('-'),
        '#cccccc',
      );
      establecerCelda(
        sheetObject,
        6,
        i + 1,
        IntCellValue(item.limiteProd),
        '#e5e5e5',
      );
      establecerCelda(
        sheetObject,
        7,
        i + 1,
        (!(item.tipo == 'Paquete' ||
                item.tipo == 'Galón' ||
                item.tipo == 'Litro' ||
                item.tipo == 'Pieza' ||
                item.tipo == 'Garrafa' ||
                item.tipo == 'Kilo(s)'))
            ? DoubleCellValue(item.entradaCont)
            : TextCellValue('-'),
        '#cccccc',
      );
      establecerCelda(
        sheetObject,
        8,
        i + 1,
        (item.tipo == 'Caja (Paquetes)' || item.tipo == 'Paquete')
            ? DoubleCellValue(item.entradaPaq)
            : TextCellValue('-'),
        '#e5e5e5',
      );
      establecerCelda(
        sheetObject,
        9,
        i + 1,
        DoubleCellValue(item.entradaUni),
        '#cccccc',
      );
      establecerCelda(
        sheetObject,
        10,
        i + 1,
        (!(item.tipo == 'Paquete' ||
                item.tipo == 'Galón' ||
                item.tipo == 'Litro' ||
                item.tipo == 'Pieza' ||
                item.tipo == 'Garrafa' ||
                item.tipo == 'Kilo(s)'))
            ? DoubleCellValue(item.salidaCont)
            : TextCellValue('-'),
        '#cccccc',
      );
      establecerCelda(
        sheetObject,
        11,
        i + 1,
        (item.tipo == 'Caja (Paquetes)' || item.tipo == 'Paquete')
            ? DoubleCellValue(item.salidaPaq)
            : TextCellValue('-'),
        '#e5e5e5',
      );
      establecerCelda(
        sheetObject,
        12,
        i + 1,
        DoubleCellValue(item.salidaUni),
        '#e5e5e5',
      );
      establecerCelda(
        sheetObject,
        13,
        i + 1,
        TextCellValue(perdidas),
        '#cccccc',
      );
      establecerCelda(
        sheetObject,
        14,
        i + 1,
        TextCellValue('${item.ultimaModificacion}: ${item.ultimaModificacion}'),
        '#e5e5e5',
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
    List<String> headers = [
      'id',
      'Nombre',
      'Tipo',
      'Área',
      'Código de barras',
      'Precio',
    ];
    for (int i = 0; i < headers.length; i++) {
      establecerCelda(
        sheetObject,
        i,
        0,
        TextCellValue(headers[i]),
        i.isEven ? '#e5e5e5' : '#cccccc',
      );
    }
    for (int i = 0; i < productos.length; i++) {
      ArticulosModel item = productos[i];
      establecerCelda(sheetObject, 0, i + 1, IntCellValue(item.id), '#e5e5e5');
      establecerCelda(
        sheetObject,
        1,
        i + 1,
        TextCellValue(item.nombre),
        '#cccccc',
      );
      establecerCelda(
        sheetObject,
        2,
        i + 1,
        TextCellValue(item.tipo),
        '#e5e5e5',
      );
      establecerCelda(
        sheetObject,
        3,
        i + 1,
        TextCellValue(item.area),
        '#cccccc',
      );
      establecerCelda(
        sheetObject,
        4,
        i + 1,
        TextCellValue(item.codigoBarras),
        '#e5e5e5',
      );
      establecerCelda(
        sheetObject,
        5,
        i + 1,
        DoubleCellValue(item.precio),
        '#cccccc',
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
  //una orden seleccionada por el usuario, solo los productores pueden imprimir
  //órdenes (id, Locación, Cant. Articulos, Fecha de orden).
  //Está en desuso, ya que registra todas la ordenes y las guarda en un Excel,
  //la opción de imprimir es mucho mejor para esto, ya que crea un archivo en
  //PDF que puede imprimirse de inmediato, con la función de añadir espacio
  //para firmar y tener una capa extra de orden en, valga la redundancia, las
  //órdenes.
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
      establecerCelda(
        sheetObject,
        i,
        0,
        TextCellValue(headers[i]),
        i.isEven ? '#e5e5e5' : '#cccccc',
      );
    }
    for (int i = 0; i < ordenes.length; i++) {
      OrdenModel item = ordenes[i];
      establecerCelda(sheetObject, 0, i + 1, IntCellValue(item.id), '#e5e5e5');
      establecerCelda(
        sheetObject,
        1,
        i + 1,
        TextCellValue(item.locacion),
        '#cccccc',
      );
      establecerCelda(
        sheetObject,
        2,
        i + 1,
        IntCellValue(item.cantArticulos),
        '#e5e5e5',
      );
      establecerCelda(
        sheetObject,
        3,
        i + 1,
        TextCellValue(item.fechaOrden),
        '#cccccc',
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
    String mensaje =
        'Error: No hay registros en esa fecha, o hubo un problema al conectarse.';
    if (historial.isNotEmpty || historial.last.mensaje.isEmpty) {
      var excel = Excel.createExcel();
      int contador = 0;
      Sheet sheetObject = excel['Historial'];
      excel.delete('Sheet1');
      List<String> headers = [
        'id',
        'Nombre',
        'Fecha',
        'Entradas contenedores',
        'Entradas paquetes',
        'Entradas',
        'Salidas contenedores',
        'Salidas paquetes',
        'Salidas',
        'Perdidas',
        'Detalle de perdidas',
        'Hora de modificación',
        'Usuario que modifico',
      ];
      for (int i = 0; i < headers.length; i++) {
        establecerCelda(
          sheetObject,
          i,
          0,
          TextCellValue(headers[i]),
          i.isEven ? '#e5e5e5' : '#cccccc',
        );
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
              perdidas =
                  '$perdidas, ${item.cantidades[j]}: ${item.razones[j]}\n';
            }
          }
        }
        establecerCelda(
          sheetObject,
          0,
          contador,
          IntCellValue(item.id),
          '#e5e5e5',
        );
        establecerCelda(
          sheetObject,
          1,
          contador,
          TextCellValue(item.nombre),
          '#cccccc',
        );
        establecerCelda(
          sheetObject,
          2,
          contador,
          TextCellValue(item.fecha),
          '#e5e5e5',
        );
        establecerCelda(
          sheetObject,
          10,
          contador,
          TextCellValue(perdidas),
          '#e5e5e5',
        );
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
          CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: contador),
          CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: cantidad),
        );
        for (int j = 0; j < item.movimientos; j++) {
          establecerCelda(
            sheetObject,
            3,
            j + contador,
            DoubleCellValue(item.entradasCont[j]),
            '#cccccc',
          );
          establecerCelda(
            sheetObject,
            4,
            j + contador,
            DoubleCellValue(item.entradasPaq[j]),
            '#e5e5e5',
          );
          establecerCelda(
            sheetObject,
            5,
            j + contador,
            DoubleCellValue(item.entradas[j]),
            '#cccccc',
          );
          establecerCelda(
            sheetObject,
            6,
            j + contador,
            DoubleCellValue(item.salidasCont[j]),
            '#e5e5e5',
          );
          establecerCelda(
            sheetObject,
            7,
            j + contador,
            DoubleCellValue(item.salidasPaq[j]),
            '#cccccc',
          );
          establecerCelda(
            sheetObject,
            8,
            j + contador,
            DoubleCellValue(item.salidas[j]),
            '#e5e5e5',
          );
          establecerCelda(
            sheetObject,
            9,
            j + contador,
            IntCellValue(item.perdidas[j]),
            '#cccccc',
          );
          establecerCelda(
            sheetObject,
            11,
            j + contador,
            TextCellValue(item.horasModificacion[j]),
            '#cccccc',
          );
          establecerCelda(
            sheetObject,
            12,
            j + contador,
            TextCellValue(item.usuarioModificacion[j]),
            '#e5e5e5',
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

  //Esta función genera un archivo en Excel con toda la información de los
  //registros, usualmente 2 que componen 2 semanas aunque fácilmente puede usar
  //1 o más de 2 registros en una semana, teniendo en cuenta que los registros
  //se deben hacer idealmente 1 vez a la semana.
  static Future<String> registroExcel(
    BuildContext context,
    String fechaInicial,
    String fechaFinal,
  ) async {
    List<ProductoModel> productos = await ProductoModel.getProductos('id', '');
    List<HistorialModel> historial = await HistorialModel.getAllHistorial(
      fechaInicial,
      fechaFinal,
    );
    List<RegistroModel> registro = await RegistroModel.getAllRegistros(
      fechaInicial,
      fechaFinal,
    );
    historial = historial.reversed.toList();
    registro = registro.reversed.toList();
    String mensaje =
        'Error: Hubo un problema al conectarse, verifique la conexión.';
    if (registro.isEmpty) mensaje = 'Error: No hay registros en esa fecha.';
    if ((productos.isNotEmpty || productos.last.mensaje.isEmpty) &&
        (registro.isNotEmpty || registro.last.mensaje.isEmpty)) {
      fechaInicial = registro.first.fecha;
      fechaFinal = registro.last.fecha;
      DateTime inicio = DateTime.parse(
        '${fechaInicial.split('-')[2]}-${fechaInicial.split('-')[1]}-${fechaInicial.split('-')[0]}',
      );
      DateTime fin = DateTime.parse(
        '${fechaFinal.split('-')[2]}-${fechaFinal.split('-')[1]}-${fechaFinal.split('-')[0]}',
      );
      var excel = Excel.createExcel();
      int regis = 0;
      int ttls = 0;
      Sheet sheetObject = excel['Historial'];
      excel.delete('Sheet1');
      List<String> h = ['id', 'Nombre', 'Area', 'Tipo'];
      List<String> fechas = [];
      List<String> fechasShort = [];
      for (var i = 0; i < h.length; i++) {
        establecerCelda(
          sheetObject,
          i,
          1,
          TextCellValue(h[i]),
          i.isEven ? '#e5e5e5' : '#cccccc',
        );
        sheetObject.merge(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1),
        );
      }
      for (int i = 0; i < fin.difference(inicio).inDays + 1; i++) {
        DateTime fec = inicio.add(Duration(days: i));
        String d = '${fec.day}'.length < 2 ? '0${fec.day}' : '${fec.day}';
        String m = '${fec.month}'.length < 2 ? '0${fec.month}' : '${fec.month}';
        String y = '${fec.year}';
        fechas.add('$d-$m-$y');
        fechasShort.add(
          (inicio.year == fin.year)
              ? (inicio.month == fin.month)
                    ? d
                    : '$d-$m'
              : '$d-$m-$y',
        );
      }
      for (int i = 0; i < fechas.length; i++) {
        int pos = (i * 7) + (regis * 4) + ttls;
        establecerCelda(
          sheetObject,
          pos + 4,
          0,
          TextCellValue('Movimientos del ${fechasShort[i]}'),
          i.isEven ? '#e5e5e5' : '#cccccc',
        );
        establecerCelda(
          sheetObject,
          pos + 4,
          1,
          TextCellValue('Entradas de cerrados'),
          (pos + 4).isEven ? '#e5e5e5' : '#cccccc',
        );
        establecerCelda(
          sheetObject,
          pos + 5,
          1,
          TextCellValue('Entradas de paquetes'),
          (pos + 5).isEven ? '#e5e5e5' : '#cccccc',
        );
        establecerCelda(
          sheetObject,
          pos + 6,
          1,
          TextCellValue('Entradas'),
          (pos + 6).isEven ? '#e5e5e5' : '#cccccc',
        );
        establecerCelda(
          sheetObject,
          pos + 7,
          1,
          TextCellValue('Salidas de cerrados'),
          (pos + 7).isEven ? '#e5e5e5' : '#cccccc',
        );
        establecerCelda(
          sheetObject,
          pos + 8,
          1,
          TextCellValue('Salidas de paquetes'),
          (pos + 8).isEven ? '#e5e5e5' : '#cccccc',
        );
        establecerCelda(
          sheetObject,
          pos + 9,
          1,
          TextCellValue('Salidas'),
          (pos + 9).isEven ? '#e5e5e5' : '#cccccc',
        );
        establecerCelda(
          sheetObject,
          pos + 9,
          1,
          TextCellValue('Perdidas'),
          (pos + 10).isEven ? '#e5e5e5' : '#cccccc',
        );
        sheetObject.merge(
          CellIndex.indexByColumnRow(columnIndex: pos + 4, rowIndex: 0),
          CellIndex.indexByColumnRow(columnIndex: pos + 10, rowIndex: 0),
        );
        if (fechas[i] == registro[regis].fecha) {
          establecerCelda(
            sheetObject,
            pos + ((regis > 0) ? 18 : 11),
            0,
            TextCellValue('Registros del ${registro[regis].fecha}'),
            i.isOdd ? '#e5e5e5' : '#cccccc',
          );
          establecerCelda(
            sheetObject,
            pos + ((regis > 0) ? 18 : 11),
            1,
            TextCellValue('Cerrados'),
            (pos + ((regis > 0) ? 18 : 11)).isEven ? '#e5e5e5' : '#cccccc',
          );
          establecerCelda(
            sheetObject,
            pos + ((regis > 0) ? 19 : 12),
            1,
            TextCellValue('Paquetes'),
            (pos + ((regis > 0) ? 19 : 12)).isEven ? '#e5e5e5' : '#cccccc',
          );
          establecerCelda(
            sheetObject,
            pos + ((regis > 0) ? 20 : 13),
            1,
            TextCellValue('Abiertos'),
            (pos + ((regis > 0) ? 20 : 13)).isEven ? '#e5e5e5' : '#cccccc',
          );
          establecerCelda(
            sheetObject,
            pos + ((regis > 0) ? 21 : 14),
            1,
            TextCellValue('Total del producto'),
            (pos + ((regis > 0) ? 21 : 14)).isEven ? '#e5e5e5' : '#cccccc',
          );
          sheetObject.merge(
            CellIndex.indexByColumnRow(
              columnIndex: pos + ((regis > 0) ? 18 : 11),
              rowIndex: 0,
            ),
            CellIndex.indexByColumnRow(
              columnIndex: pos + ((regis > 0) ? 21 : 14),
              rowIndex: 0,
            ),
          );
          if (regis > 0) {
            establecerCelda(
              sheetObject,
              pos + 11,
              0,
              TextCellValue(
                'Total de movimientos de ${registro[regis - 1].fecha}/${registro[regis].fecha}',
              ),
              (i + regis).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 11,
              1,
              TextCellValue('Entradas de cerrados'),
              (pos + 11).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 12,
              1,
              TextCellValue('Entradas de paquetes'),
              (pos + 12).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 13,
              1,
              TextCellValue('Entradas'),
              (pos + 13).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 14,
              1,
              TextCellValue('Salidas de cerrados'),
              (pos + 14).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 15,
              1,
              TextCellValue('Salidas de paquetes'),
              (pos + 15).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 16,
              1,
              TextCellValue('Salidas'),
              (pos + 16).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 17,
              1,
              TextCellValue('Perdidas'),
              (pos + 17).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 22,
              0,
              TextCellValue(
                'Diferencia con el registro del ${registro[regis - 1].fecha}',
              ),
              (i + regis).isOdd ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 22,
              1,
              TextCellValue('Cerrados'),
              (pos + 22).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 23,
              1,
              TextCellValue('Paquetes'),
              (pos + 23).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 24,
              1,
              TextCellValue('Abiertos'),
              (pos + 24).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 25,
              1,
              TextCellValue('Total'),
              (pos + 25).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + 26,
              0,
              TextCellValue(
                'Registro esperado del ${registro[regis].fecha}, contando movimientos',
              ),
              (i + regis).isOdd ? '#e5e5e5' : '#cccccc',
            );
            sheetObject.merge(
              CellIndex.indexByColumnRow(columnIndex: pos + 11, rowIndex: 0),
              CellIndex.indexByColumnRow(columnIndex: pos + 17, rowIndex: 0),
            );
            sheetObject.merge(
              CellIndex.indexByColumnRow(columnIndex: pos + 22, rowIndex: 0),
              CellIndex.indexByColumnRow(columnIndex: pos + 25, rowIndex: 0),
            );
            sheetObject.merge(
              CellIndex.indexByColumnRow(columnIndex: pos + 26, rowIndex: 0),
              CellIndex.indexByColumnRow(columnIndex: pos + 26, rowIndex: 1),
            );
            ttls++;
          }
          regis++;
        }
      }
      regis = 0;
      ttls = 0;
      for (int i = 0; i < productos.length; i++) {
        ProductoModel prod = productos[i];
        establecerCelda(
          sheetObject,
          0,
          2 + i,
          IntCellValue(prod.id),
          '#e5e5e5',
        );
        establecerCelda(
          sheetObject,
          1,
          2 + i,
          TextCellValue(prod.nombre),
          '#cccccc',
        );
        establecerCelda(
          sheetObject,
          2,
          2 + i,
          TextCellValue(prod.area),
          '#e5e5e5',
        );
        establecerCelda(
          sheetObject,
          3,
          2 + i,
          TextCellValue(prod.tipo),
          '#cccccc',
        );
        double totalEnt = 0,
            totalSal = 0,
            totalEntPac = 0,
            totalSalPac = 0,
            totalEntCont = 0,
            totalSalCont = 0,
            totalperd = 0,
            cer = 0,
            paq = 0,
            abi = 0,
            tot = 0;
        for (int j = 0; j < fechas.length; j++) {
          int pos = (j * 7) + (regis * 4) + ttls;
          HistorialModel hist = HistorialModel(
            id: 0,
            fecha: '',
            nombre: '',
            area: '',
            movimientos: 0,
            entradas: [0],
            entradasPaq: [0],
            entradasCont: [0],
            salidas: [0],
            salidasPaq: [0],
            salidasCont: [0],
            perdidas: [0],
            razones: [],
            cantidades: [],
            horasModificacion: [],
            usuarioModificacion: [],
            mensaje: '',
          );
          RegistroModel reg = registro[regis];
          RegistroModel? regPast;
          int? idNum;
          int? idNumPast;
          double total = 0, totalDif = 0, perdida = 0;
          for (int k = 0; k < historial.length; k++) {
            if (historial[k].id == prod.id && historial[k].fecha == fechas[j]) {
              hist = historial[k];
            }
          }
          for (int k = 0; k < reg.idProducto.length; k++) {
            if (reg.idProducto[k] == prod.id) idNum = k;
          }
          for (int i = 0; i < hist.cantidades.length; i++) {
            perdida += hist.cantidades[i];
          }
          //Esto debve de operar con el registro anterior, no con el actual,
          //como los esta haciendo... actualmente, al parecer ya se soluciono,
          //pero no confio en mi asi que dejare este comentario para recordar
          //donde esta ubicado mi error.
          if (regis > 0) {
            regPast = registro[regis - 1];
            for (int k = 0; k < regPast.idProducto.length; k++) {
              if (regPast.idProducto[k] == prod.id) idNumPast = k;
            }
          }
          if (idNum != null) {
            switch (prod.tipo) {
              case 'Caja (Paquetes)' || 'Caja (Piezas)':
                total =
                    (((reg.cerrados[idNum] * prod.cantidadPorUnidad +
                            reg.paquetes[idNum]) *
                        prod.cantidadPorPaquete) +
                    reg.abiertos[idNum]);

                break;
              case 'Paquete':
                total =
                    (((reg.paquetes[idNum]) * prod.cantidadPorUnidad) +
                    reg.abiertos[idNum]);

                break;
              default:
                total =
                    (reg.cerrados[idNum] * prod.cantidadPorUnidad +
                    reg.abiertos[idNum]);

                break;
            }
          }
          if (regPast != null) {
            double cerrado = 0;
            double paquete = 0;
            double abierto = 0;
            if (idNumPast != null) {
              cerrado = regPast.cerrados[idNumPast];
              paquete = regPast.paquetes[idNumPast];
              abierto = regPast.abiertos[idNumPast];
            }
            switch (prod.tipo) {
              case 'Caja (Paquetes)' || 'Caja (Piezas)':
                totalDif =
                    ((((cerrado + totalEntCont - totalSalCont) *
                                prod.cantidadPorUnidad +
                            (paquete + totalEntPac - totalSalPac)) *
                        prod.cantidadPorPaquete) +
                    abierto +
                    totalEnt -
                    totalSal -
                    totalperd);
                break;
              case 'Paquete':
                totalDif =
                    ((((paquete + totalEntPac - totalSalPac)) *
                        prod.cantidadPorUnidad) +
                    abierto +
                    totalEnt -
                    totalSal -
                    totalperd);
                break;
              default:
                totalDif =
                    ((cerrado + totalEntCont - totalSalCont) *
                        prod.cantidadPorUnidad +
                    abierto +
                    totalEnt -
                    totalSal -
                    totalperd);
                break;
            }
          }
          establecerCelda(
            sheetObject,
            pos + 4,
            2 + i,
            (!(prod.tipo == 'Paquete' ||
                    prod.tipo == 'Galón' ||
                    prod.tipo == 'Litro' ||
                    prod.tipo == 'Pieza' ||
                    prod.tipo == 'Garrafa' ||
                    prod.tipo == 'Kilo(s)'))
                ? DoubleCellValue(hist.entradasCont.last)
                : TextCellValue('-'),
            (pos + 4).isEven ? '#e5e5e5' : '#cccccc',
          );
          establecerCelda(
            sheetObject,
            pos + 5,
            2 + i,
            (prod.tipo == 'Caja (Paquetes)') || (prod.tipo == 'Paquete')
                ? DoubleCellValue(hist.entradasPaq.last)
                : TextCellValue('-'),
            (pos + 5).isEven ? '#e5e5e5' : '#cccccc',
          );
          establecerCelda(
            sheetObject,
            pos + 6,
            2 + i,
            DoubleCellValue(hist.entradas.last),
            (pos + 6).isEven ? '#e5e5e5' : '#cccccc',
          );
          establecerCelda(
            sheetObject,
            pos + 7,
            2 + i,
            (!(prod.tipo == 'Paquete' ||
                    prod.tipo == 'Galón' ||
                    prod.tipo == 'Litro' ||
                    prod.tipo == 'Pieza' ||
                    prod.tipo == 'Garrafa' ||
                    prod.tipo == 'Kilo(s)'))
                ? DoubleCellValue(hist.salidasCont.last)
                : TextCellValue('-'),
            (pos + 7).isEven ? '#e5e5e5' : '#cccccc',
          );
          establecerCelda(
            sheetObject,
            pos + 8,
            2 + i,
            (prod.tipo == 'Caja (Paquetes)') || (prod.tipo == 'Paquete')
                ? DoubleCellValue(hist.salidasPaq.last)
                : TextCellValue('-'),
            (pos + 8).isEven ? '#e5e5e5' : '#cccccc',
          );
          establecerCelda(
            sheetObject,
            pos + 9,
            2 + i,
            DoubleCellValue(hist.salidas.last),
            (pos + 9).isEven ? '#e5e5e5' : '#cccccc',
          );
          establecerCelda(
            sheetObject,
            pos + 10,
            2 + i,
            DoubleCellValue(perdida),
            (pos + 10).isEven ? '#e5e5e5' : '#cccccc',
          );
          totalEnt += hist.entradas.last;
          totalEntPac += hist.entradasPaq.last;
          totalEntCont += hist.entradasCont.last;
          totalSal += hist.salidas.last;
          totalSalPac = hist.salidasPaq.last;
          totalSalCont += hist.salidasCont.last;
          totalperd += perdida;
          if (fechas[j] == registro[regis].fecha) {
            establecerCelda(
              sheetObject,
              pos + ((regis > 0) ? 18 : 11),
              2 + i,
              (!(prod.tipo == 'Paquete' ||
                      prod.tipo == 'Galón' ||
                      prod.tipo == 'Litro' ||
                      prod.tipo == 'Pieza' ||
                      prod.tipo == 'Garrafa' ||
                      prod.tipo == 'Kilo(s)'))
                  ? idNum != null
                        ? DoubleCellValue(reg.cerrados[idNum])
                        : TextCellValue('s/r')
                  : TextCellValue('-'),
              (pos + ((regis > 0) ? 18 : 11)).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + ((regis > 0) ? 19 : 12),
              2 + i,
              (prod.tipo == 'Caja (Paquetes)') || (prod.tipo == 'Paquete')
                  ? idNum != null
                        ? DoubleCellValue(reg.paquetes[idNum])
                        : TextCellValue('s/r')
                  : TextCellValue('-'),
              (pos + ((regis > 0) ? 19 : 12)).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + ((regis > 0) ? 20 : 13),
              2 + i,
              idNum != null
                  ? DoubleCellValue(reg.abiertos[idNum])
                  : TextCellValue('s/r'),
              (pos + ((regis > 0) ? 20 : 13)).isEven ? '#e5e5e5' : '#cccccc',
            );
            establecerCelda(
              sheetObject,
              pos + ((regis > 0) ? 21 : 14),
              2 + i,
              DoubleCellValue(total),
              (pos + ((regis > 0) ? 21 : 14)).isEven ? '#e5e5e5' : '#cccccc',
            );
            if (regis > 0) {
              establecerCelda(
                sheetObject,
                pos + 11,
                2 + i,
                (!(prod.tipo == 'Paquete' ||
                        prod.tipo == 'Galón' ||
                        prod.tipo == 'Litro' ||
                        prod.tipo == 'Pieza' ||
                        prod.tipo == 'Garrafa' ||
                        prod.tipo == 'Kilo(s)'))
                    ? DoubleCellValue(totalEntCont)
                    : TextCellValue('-'),
                (pos + 11).isEven ? '#e5e5e5' : '#cccccc',
              );
              establecerCelda(
                sheetObject,
                pos + 12,
                2 + i,
                (prod.tipo == 'Caja (Paquetes)') || (prod.tipo == 'Paquete')
                    ? DoubleCellValue(totalEntPac)
                    : TextCellValue('-'),
                (pos + 12).isEven ? '#e5e5e5' : '#cccccc',
              );
              establecerCelda(
                sheetObject,
                pos + 13,
                2 + i,
                DoubleCellValue(totalEnt),
                (pos + 13).isEven ? '#e5e5e5' : '#cccccc',
              );
              establecerCelda(
                sheetObject,
                pos + 14,
                2 + i,
                (!(prod.tipo == 'Paquete' ||
                        prod.tipo == 'Galón' ||
                        prod.tipo == 'Litro' ||
                        prod.tipo == 'Pieza' ||
                        prod.tipo == 'Garrafa' ||
                        prod.tipo == 'Kilo(s)'))
                    ? DoubleCellValue(totalSalCont)
                    : TextCellValue('-'),
                (pos + 14).isEven ? '#e5e5e5' : '#cccccc',
              );
              establecerCelda(
                sheetObject,
                pos + 15,
                2 + i,
                (prod.tipo == 'Caja (Paquetes)') || (prod.tipo == 'Paquete')
                    ? DoubleCellValue(totalSalPac)
                    : TextCellValue('-'),
                (pos + 15).isEven ? '#e5e5e5' : '#cccccc',
              );
              establecerCelda(
                sheetObject,
                pos + 16,
                2 + i,
                DoubleCellValue(totalSal),
                (pos + 16).isEven ? '#e5e5e5' : '#cccccc',
              );
              establecerCelda(
                sheetObject,
                pos + 17,
                2 + i,
                DoubleCellValue(totalperd),
                (pos + 17).isEven ? '#e5e5e5' : '#cccccc',
              );
              establecerCelda(
                sheetObject,
                pos + 22,
                2 + i,
                DoubleCellValue(
                  cer - (idNum != null ? reg.cerrados[idNum] : 0),
                ),
                (pos + 22).isEven ? '#e5e5e5' : '#cccccc',
                colorLetra:
                    (cer - (idNum != null ? reg.cerrados[idNum] : 0)) >= 0
                    ? '#000000'
                    : '#ff0000',
              );
              establecerCelda(
                sheetObject,
                pos + 23,
                2 + i,
                (prod.tipo == 'Caja (Paquetes)') || (prod.tipo == 'Paquete')
                    ? DoubleCellValue(
                        paq - (idNum != null ? reg.paquetes[idNum] : 0),
                      )
                    : TextCellValue('-'),
                (pos + 23).isEven ? '#e5e5e5' : '#cccccc',
                colorLetra:
                    (paq - (idNum != null ? reg.paquetes[idNum] : 0)) >= 0
                    ? '#000000'
                    : '#ff0000',
              );
              establecerCelda(
                sheetObject,
                pos + 24,
                2 + i,
                DoubleCellValue(
                  abi - (idNum != null ? reg.abiertos[idNum] : 0),
                ),
                (pos + 24).isEven ? '#e5e5e5' : '#cccccc',
                colorLetra:
                    (abi - (idNum != null ? reg.abiertos[idNum] : 0)) >= 0
                    ? '#000000'
                    : '#ff0000',
              );
              establecerCelda(
                sheetObject,
                pos + 25,
                2 + i,
                DoubleCellValue(tot - total),
                (pos + 25).isEven ? '#e5e5e5' : '#cccccc',
                colorLetra: (tot - total) >= 0 ? '#000000' : '#ff0000',
              );
              establecerCelda(
                sheetObject,
                pos + 26,
                2 + i,
                DoubleCellValue(totalDif),
                (pos + 26).isEven ? '#e5e5e5' : '#cccccc',
                colorLetra: totalDif >= 0 ? '#000000' : '#ff0000',
              );
              ttls++;
            }
            totalEnt = 0;
            totalSal = 0;
            totalEntPac = 0;
            totalSalPac = 0;
            totalEntCont = 0;
            totalSalCont = 0;
            totalperd = 0;
            cer = idNum != null ? reg.cerrados[idNum] : 0;
            paq = idNum != null ? reg.paquetes[idNum] : 0;
            abi = idNum != null ? reg.abiertos[idNum] : 0;
            tot = total;
            regis++;
          }
        }
        regis = 0;
        ttls = 0;
      }
      mensaje = "Error: Se canceló el proceso";
      if (kIsWeb) {
        List<int>? fileBytes = excel.save(
          fileName: 'registro $fechaInicial $fechaFinal.xlsx',
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
            File('$path/registro $fechaInicial $fechaFinal.xlsx')
              ..createSync(recursive: true)
              ..writeAsBytesSync(fileBytes, flush: true);
            mensaje =
                'Archivo guardado en: $path/registro $fechaInicial $fechaFinal.xlsx';
          }
        }
      }
    }
    return mensaje;
  }

  //Este es un componente tipo celda de Excel usado por las funciones que
  //devuelven un archivo Excel.
  static void establecerCelda(
    Sheet hoja,
    int col,
    int row,
    CellValue valor,
    String color, {
    String colorLetra = '#000000',
  }) {
    hoja.updateCell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
      valor,
      cellStyle: CellStyle(
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString(color),
        fontColorHex: ExcelColor.fromHexString(colorLetra),
        textWrapping: TextWrapping.WrapText,
        //bottomBorder: BorderStyle.Thick
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
