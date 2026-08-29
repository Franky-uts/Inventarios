import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/textos.dart';
import 'package:provider/provider.dart';

class Botones {
  //Botón rectangular morado que muestra un icono blanco.
  //Cuando el valor borde es verdadero el botón tiene un borde y el icono es
  //morado, el fondo cambia a ser de color blanco.
  //El valor de alert es opcional, si es verdadero entonces se mostrara un
  //punto rojo en la esquina superior izquierda, como el nombre de la variable
  //lo indica se utiliza para mostrar una alerta relacionada con el botón.
  static IconButton btnRctMor(
    String tip,
    IconData icono,
    bool borde,
    Function accion, {
    double? size,
    bool? alert = false,
  }) {
    return IconButton.filled(
      onPressed: () => accion(),
      tooltip: tip,
      icon: Badge(
        offset: (kIsWeb) ? Offset(10, -5) : null,
        label: Text(''),
        backgroundColor: alert! ? Color(0xFFFF0000) : Color(0x00000000),
        child: Icon(
          icono,
          color: borde ? Color(0xFF8A03A9) : Color(0xFFFFFFFF),
          size: size,
        ),
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

  //Botón rectangular con bordes circulares texto y un borde visible.
  //Cuando el valor borde y enabled es verdadero el texto y el borde son de
  //color morado además de tener un fondo de color blanco, si solo borde es
  //verdadero y enabled es falso el color del borde y el texto serán de color
  //morado, pero con menos saturación, esto es para resaltar el hecho de que el
  //botón no tiene función al presionarse.
  //En caso de que el valor de borde sea falso, entonces el fondo será de color
  //morado y el borde junto con el texto serán blancos, aquí el valor de
  //enabled no afecta la apariencia, pero seguirá ejecutando la acción
  //alternativa
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

  static OutlinedButton icoRctBor(
    String texto,
    IconData icono,
    Color colorBorde,
    Function accion,
  ) {
    return OutlinedButton.icon(
      onPressed: () => accion(),
      label: Textos.textoGeneral(texto, true, 1, alignment: TextAlign.center),
      icon: Icon(icono, size: 25, color: Color(0xFF8A03A9)),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(12.5),
        side: BorderSide(color: colorBorde, width: 2),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(27.5),
        ),
      ),
    );
  }

  //Botón rectangular con borde circular fondo morado, borde grueso rosa
  //y letras blancas.
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

  //Botón rectangular simple y pequeño con fondo transparente y un icono de
  //color variable.
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

  //Botón rectangular transparente y un icono morado le cuál cambia a blanco
  //cuando se selecciona, este botón es utilizado en las barras de navegación
  //inferiores para navegar entre las diferentes páginas de la app.
  static Widget botonBarNav(String titulo, IconData icono) {
    return Consumer<Carga>(
      builder: (ctx, carga, child) {
        return NavigationDestination(
          icon: Icon(icono, color: Color(0xFF8A03A9)),
          selectedIcon: Icon(icono, color: Colors.white),
          label: titulo,
        );
      },
    );
  }

  //Capa la cual posee de 1 a 2 botones, el primero tiene el icono de una
  //flecha apuntando a la izquierda, con el fin de representar la acción de
  //regresar a la página anterior, la acción que tiene el botón se debe de
  //asignar, el otro botón es opcional y se activa cuando se le asigna un valor
  //de tipo Function a la variable recarga, este tiene el símbolo de una flecha
  //en círculo.
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
