import 'package:flutter/material.dart';
import 'package:inventarios/components/textos.dart';

class Botones {
  static IconButton btnRctMor(
    String tip,
    double size,
    IconData icono,
    bool borde,
    Function accion,
  ) {
    Icon icon;
    ButtonStyle estilo;
    Color color;
    if (borde) {
      estilo = FilledButton.styleFrom(
        padding: EdgeInsets.all(10),
        backgroundColor: Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xFF8A03A9), width: 3),
        ),
      );
      color = Color(0xFF8A03A9);
    } else {
      estilo = IconButton.styleFrom(
        backgroundColor: Color(0xFF8A03A9),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      );
      color = Color(0xFFFFFFFF);
    }

    if (size > 0) {
      icon = Icon(icono, color: color, size: size);
    } else {
      icon = Icon(icono, color: color);
    }

    return IconButton.filled(
      onPressed: () => accion(),
      tooltip: tip,
      icon: icon,
      style: estilo,
    );
  }

  static TextButton icoCirMor(
    String texto,
    IconData icono,
    bool borde,
    Function accion,
  ) {
    ButtonStyle estilo;
    Color colorLetra;
    if (borde) {
      colorLetra = Color(0xFF8A03A9);
      estilo = FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(color: Color(0xFF8A03A9), width: 5),
        ),
      );
    } else {
      colorLetra = Color(0xFFFFFFFF);
      estilo = TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        backgroundColor: Color(0xFF8A03A9),
      );
    }
    return TextButton.icon(
      onPressed: () => accion(),
      style: estilo,
      icon: Icon(icono, color: colorLetra, size: 25),
      label: Text(texto, style: TextStyle(fontSize: 20, color: colorLetra)),
    );
  }

  static TextButton icoRctBor(
    String texto,
    IconData icono,
    Color colorBorde,
    Function accion,
  ) {
    return TextButton.icon(
      onPressed: () => accion(),
      label: Textos.textoGeneral(texto, 0, true, true),
      icon: Icon(icono, size: 25, color: Color(0xFF8A03A9)),
      style: IconButton.styleFrom(
        side: BorderSide(color: colorBorde, width: 2),
        backgroundColor: Colors.white,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(27.5),
        ),
      ),
    );
  }

  static OutlinedButton btnCirRos(String texto, Function accion) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Color(0xFF8A03A9),
        side: BorderSide(color: Color(0xFFF6AFCF), width: 2),
      ),
      onPressed: () => accion(),
      child: Textos.textoBlanco(texto, 20),
    );
  }

  static IconButton btnSimple(String tip, IconData icono, Color color, Function accion) {
    return IconButton(
      tooltip: tip,
      onPressed: () => accion(),
      icon: Icon(icono, color: color, size: 25),
    );
  }

  static TextButton iconoTexto(String texto, IconData icono, Function accion) {
    return TextButton.icon(
      onPressed: () => accion(),
      style: IconButton.styleFrom(
        padding: EdgeInsets.all(15),
        backgroundColor: Color(0xFF8A03A9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: Icon(icono, color: Colors.white),
      label: Textos.textoBlanco(texto, 0),
    );
  }

  static Widget botonesSumaResta(
    String nombre,
    int textoValor,
    Color colorBorde,
    Function resta,
    Function suma,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Botones.btnRctMor(
          "Restar $nombre",
          0,
          Icons.remove,
          false,
          () => resta(),
        ),
        Textos.recuadroCantidad(textoValor.toString(), colorBorde, 20),
        Botones.btnRctMor("Sumar $nombre", 0, Icons.add, false, () => suma()),
      ],
    );
  }

  static Container layerButton(Function accion) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Botones.btnRctMor(
        "Volver",
        35,
        Icons.arrow_back_rounded,
        false,
        () => accion(),
      ),
    );
  }
}
