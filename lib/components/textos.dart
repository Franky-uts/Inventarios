import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class Textos with ChangeNotifier {
  static List<Color> color = [];

  static void toast(String texto, bool longLength) {
    Fluttertoast.showToast(
      msg: texto,
      toastLength: longLength ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color(0xBFFDC930),
      textColor: Colors.white,
      fontSize: 15,
    );
  }

  static Future<String> scan(BuildContext ctx) async {
    return (await SimpleBarcodeScanner.scanBarcode(
      ctx,
      lineColor: '#8A03A9',
      cancelButtonText: 'Regresar',
      isShowFlashIcon: true,
      delayMillis: 2000,
      cameraFace: CameraFace.back,
    ))!;
  }

  static Text textoGeneral(
    String texto,
    bool principal,
    int maxLines, {
    double? size,
    TextAlign? alignment,
  }) {
    return Text(
      texto,
      textAlign: alignment ?? TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: size,
          color: principal ? Color(0xFF8A03A9) : Color(0xFFF6AFCF),
      ),
    );
  }

  static Text textoBlanco(String texto, {double? size}) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: size, color: Color(0xFFFFFFFF)),
    );
  }

  static Text textoTilulo(String texto, double size) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      maxLines: 2,
      style: TextStyle(
        color: Color(0xFF8A03A9),
        fontSize: size,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static Center textoError(String texto) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color(0x808A03A9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFF6AFCF), fontSize: 20),
        ),
      ),
    );
  }

  static Container recuadroCantidad(
    String textoValor,
    Color colorBorde,
    int maxLines, {
    double? size,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: colorBorde, width: 2.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: textoGeneral(
        textoValor,
        true,
        maxLines,
        size: size,
        alignment: TextAlign.center,
      ),
    );
  }

  static Color colorLimite(int limite, int cantidad) {
    Color color = Color(0xff32c864);
    if (cantidad < limite) color = Color(0xFFFDC930);
    if (cantidad < limite / 2) color = Color(0xFFFF4B4B);
    return color;
  }

  static Color colorEstado(String estado) {
    switch (estado) {
      case ('En proceso'):
        return Colors.blue.shade200;
      case ('Entregado'):
        return Colors.green.shade100;
      case ('Incompleto'):
        return Colors.yellow.shade300;
      case ('Finalizado'):
        return Colors.green.shade300;
      case ('Cancelado'):
        return Colors.red.shade200;
      case ('Denegado'):
        return Colors.red.shade300;
      default:
        return Colors.white;
    }
  }

  static void crearLista(int length, Color color_) {
    color.addAll(List.filled(length, color_));
  }

  static void limpiarLista() {

    if (color.isNotEmpty) color = [];
  }

  static Color getColor(int i) {
    return color[i];
  }

  void setColor(int i, Color colorInt) {
    color[i] = colorInt;
    notifyListeners();
  }

  void setAllColor(Color color_) {
    for (int i = 0; i < color.length; i++) {
      color[i] = color_;
    }
    notifyListeners();
  }
}
