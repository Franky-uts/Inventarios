import 'package:flutter/material.dart';
import 'package:inventarios/components/textos.dart';

import 'botones.dart';

class Ventanas with ChangeNotifier{
  static bool _emergente = false;
  static bool _tabla = false;

  static Widget ventanaEmergente(
    String texto,
    String no,
    String si,
    Function btnNo,
    Function btnSi,
  ) {
    return Visibility(
      visible: _emergente,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 90, vertical: 30),
        decoration: BoxDecoration(color: Colors.black38),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadiusGeometry.circular(25),
              border: BoxBorder.all(color: Color(0xFFFDC930), width: 2.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 5,
              children: [
                Textos.textoTilulo(texto, 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 15,
                  children: [
                    Botones.btnCirRos(no, () => btnNo()),
                    Botones.btnCirRos(si, () => btnSi()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget ventanaTabla(
    double alto,
    double ancho,
    List<String> tituloTexto,
    List<String> footerTexto,
    Widget tablaInfo,
    ListView tablaListView,
    List<Widget> botones,
  ) {
    List<Widget> titulos = [];
    List<Widget> footer = [];
    int tam;
    for (int i = 0; i < tituloTexto.length; i++) {
      titulos.add(Textos.textoTilulo(tituloTexto[i], 20));
    }
    if (footerTexto.length > 1) {
      tam = 168;
      for (int i = 0; i < footerTexto.length; i++) {
        footer.add(Textos.textoGeneral(footerTexto[i], 15, false, false));
      }
    } else {
      tam = 153;
      footer.add(Textos.textoGeneral(footerTexto[0], 20, true, false));
    }
    return Visibility(
      visible: _tabla,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
        decoration: BoxDecoration(color: Colors.black38),
        child: Center(
          child: Container(
            height: alto,
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadiusGeometry.circular(25),
              border: BoxBorder.all(color: Color(0xFFFDC930), width: 2.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 0,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: titulos,
                ),
                tablaInfo,
                Container(
                  width: ancho,
                  height: alto - tam,
                  margin: EdgeInsets.zero,
                  child: tablaListView,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: footer,
                    ),
                    Row(
                      spacing: 7.5,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: botones,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void tabla(bool booleano){
    _tabla = booleano;
    notifyListeners();
  }

  void emergente(bool booleano){
    _emergente = booleano;
    notifyListeners();
  }
}
