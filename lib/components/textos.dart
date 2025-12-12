import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class Textos with ChangeNotifier {
  static List<int> color = [];

  static void toast(String texto, bool longLength) {
    Toast length;
    if (longLength) {
      length = Toast.LENGTH_LONG;
    } else {
      length = Toast.LENGTH_SHORT;
    }
    Fluttertoast.showToast(
      msg: texto,
      toastLength: length,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color(0xBFFDC930),
      textColor: Colors.white,
      fontSize: 15,
    );
  }

  static Future<String> scan(BuildContext ctx)async{
    String? scan = await SimpleBarcodeScanner.scanBarcode(
      ctx,
      lineColor: "#8A03A9",
      cancelButtonText: "Regresar",
      isShowFlashIcon: true,
      delayMillis: 2000,
      cameraFace: CameraFace.back,
    );
    return scan!;
  }


  static Text textoGeneral(
    String texto,
    double size,
    bool principal,
    bool centro,
  ) {
    TextStyle estilo;
    Color color;
    TextAlign alineamiento;
    if (principal) {
      color = Color(0xFF8A03A9);
    } else {
      color = Color(0xFFF6AFCF);
    }
    if (size > 0) {
      estilo = TextStyle(fontSize: size, color: color);
    } else {
      estilo = TextStyle(color: color);
    }
    if (centro) {
      alineamiento = TextAlign.center;
    } else {
      alineamiento = TextAlign.start;
    }
    return Text(
      texto,
      textAlign: alineamiento,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: estilo,
    );
  }

  static Text textoBlanco(String texto, double size) {
    TextStyle estilo;
    if (size > 0) {
      estilo = TextStyle(fontSize: size, color: Color(0xFFFFFFFF));
    } else {
      estilo = TextStyle(color: Color(0xFFFFFFFF));
    }
    return Text(texto, textAlign: TextAlign.center, style: estilo);
  }

  static Text textoTilulo(String texto, double size) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF8A03A9),
        fontSize: size,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static Center textoError(String texto) {
    return Center(
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFFF6AFCF), fontSize: 20),
      ),
    );
  }

  static Container recuadroCantidad(
    String textoValor,
    Color colorBorde,
    double size,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: colorBorde, width: 2.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: textoGeneral(textoValor.toString(), size, true, true),
    );
  }

  static void crearLista(int length, int colorInt) {
    for (int i = 0; i < length; i++) {
      color.add(colorInt);
    }
  }

  static void limpiarLista() {
    color.clear();
  }

  static int getColor(int i) {
    return color[i];
  }

  void setColor(int i, int colorInt) {
    color[i] = colorInt;
    notifyListeners();
  }
}
