import 'package:flutter/material.dart';

class Botones {
  static IconButton btnRctMor(
    String tip,
    Icon icono, {
    required Function accion,
  }) {
    var boton = IconButton.filled(
      onPressed: () => accion(),
      tooltip: tip,
      icon: icono,
      style: IconButton.styleFrom(
        backgroundColor: Color(0xFF8F01AF),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
    return boton;
  }
}
