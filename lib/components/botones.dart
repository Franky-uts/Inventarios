import 'package:flutter/material.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/textos.dart';
import 'package:provider/provider.dart';

class Botones {
  static IconButton btnRctMor(
    String tip,
    IconData icono,
    bool borde,
    Function accion, {
    double? size,
  }) {
    return IconButton.filled(
      onPressed: () => accion(),
      tooltip: tip,
      icon: Icon(
        icono,
        color: borde ? Color(0xFF8A03A9) : Color(0xFFFFFFFF),
        size: size,
      ),
      style: borde
          ? FilledButton.styleFrom(
              padding: EdgeInsets.all(10),
              backgroundColor: Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Color(0xFF8A03A9), width: 3),
              ),
            )
          : IconButton.styleFrom(
              backgroundColor: Color(0xFF8A03A9),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
    );
  }

  static TextButton icoCirMor(
    String texto,
    IconData icono,
    Function accion,
    Function accionNull,
    bool borde,
    bool enabled,
  ) {
    Color colorLetra;
    borde
        ? colorLetra = enabled ? Color(0xFF8A03A9) : Color(0xFF8C78AA)
        : colorLetra = Color(0xFFFFFFFF);
    return TextButton.icon(
      onPressed: enabled ? () => accion() : () => accionNull(),
      style: borde
          ? FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  color: enabled ? Color(0xFF8A03A9) : Color(0xFF8C78AA),
                  width: 5,
                ),
              ),
            )
          : TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              backgroundColor: enabled ? Color(0xFF8A03A9) : Color(0xFF8C78AA),
            ),
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
      label: Textos.textoGeneral(texto, true, 1, alignment: TextAlign.center),
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
      child: Textos.textoBlanco(texto, size: 20),
    );
  }

  static IconButton btnSimple(
    String tip,
    IconData icono,
    Color color,
    Function accion,
  ) {
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
      label: Textos.textoBlanco(texto),
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
        Botones.btnRctMor('Restar $nombre', Icons.remove, false, () => resta()),
        Textos.recuadroCantidad('$textoValor', colorBorde, 1, size: 20),
        Botones.btnRctMor('Sumar $nombre', Icons.add, false, () => suma()),
      ],
    );
  }

  static Widget botonBarNav(String titulo, IconData icono, Function accion) {
    accion();
    return Consumer<Carga>(
      builder: (ctx, carga, child) {
        return NavigationDestination(
          icon: Icon(icono, color: Color(0xFF8A03A9)),
          label: titulo,
        );
      },
    );
  }

  static Container layerButton(Function accion, {Function? recarga}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        spacing: 15,
        children: [
          Botones.btnRctMor(
            'Volver',
            Icons.arrow_back_rounded,
            false,
            () => accion(),
            size: 35,
          ),
          if (recarga != null)
            Botones.btnRctMor(
              'Recargar',
              Icons.refresh_rounded,
              false,
              () => recarga(),
              size: 35,
            ),
        ],
      ),
    );
  }
}
