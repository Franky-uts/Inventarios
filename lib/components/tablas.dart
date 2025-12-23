import 'package:flutter/material.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';

class Tablas with ChangeNotifier {
  static List<dynamic> _datos = [];
  static bool _valido = false;

  static Container contenedorInfo(
    double grosor,
    List<double> grosores,
    List<String> textos,
  ) {
    List<Widget> lista = [];
    for (int i = 0; i < textos.length; i++) {
      if (grosores[i] > 0.075) {
        lista.add(_barraSuperior(grosor * grosores[i], textos[i], true));
      } else {
        lista.add(_barraSuperior(grosor * grosores[i], textos[i], false));
      }
      if (i != textos.length - 1) {
        lista.add(_divider());
      }
    }
    return Container(
      width: grosor,
      decoration: BoxDecoration(color: Color(0xFF8A03A9)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: lista,
      ),
    );
  }

  static FutureBuilder listaFutura(
    ListView Function(List<dynamic>) lista,
    String textoListaVacia,
    String errorTexto,
    Function modelo, {
    Function? accionRefresh,
  }) {
    return FutureBuilder(
      future: modelo(),
      builder: (context, snapshot) {
        Widget wid = Carga.carga();
        _valido = false;
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            _datos = snapshot.data;
            wid = Textos.textoError(textoListaVacia);
            if (_datos.isNotEmpty) {
              wid = Textos.textoError(_datos[0].mensaje);
              if (CampoTexto.busquedaTexto.text.isNotEmpty) {
                wid = Textos.textoError(errorTexto);
              }
              if (_datos[0].mensaje=="") {
                _valido = true;
                wid = lista(_datos);
              }
            }
          } else if (snapshot.hasError) {
            wid = Textos.textoError("Error:\n${snapshot.error.toString()}");
          }
        }
        return RefreshIndicator(
          child: wid,
          onRefresh: () async => accionRefresh!(),
        );
      },
    );
  }

  static SizedBox _barraSuperior(double grosor, String texto, bool grande) {
    double size;
    if (grande) {
      size = 15;
    } else {
      size = 12;
    }
    return SizedBox(width: grosor, child: Textos.textoBlanco(texto, size));
  }

  static Widget _barraDato(double grosor, String texto, Color color) {
    return Container(
      width: grosor,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Textos.textoGeneral(texto, 20, true, true),
    );
  }

  static Widget barraDatos(
    double grosor,
    List<double> grosores,
    List<String> textos,
    List<Color> colores,
    bool boton, {
    Function? extra,
    Widget? extraWid,
  }) {
    List<Widget> lista = [];
    for (int i = 0; i < textos.length; i++) {
      if (textos[i].isEmpty) {
        lista.add(extraWid!);
      } else {
        if (colores.isEmpty) {
          lista.add(
            _barraDato(grosor * grosores[i], textos[i], Colors.transparent),
          );
        } else {
          lista.add(_barraDato(grosor * grosores[i], textos[i], colores[i]));
        }
      }
      if (i != textos.length - 1) {
        lista.add(_divider());
      }
    }
    if (boton) {
      return TextButton(
        onPressed: () => extra!(),
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(0),
          shape: ContinuousRectangleBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: lista,
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: lista,
      );
    }
  }

  static VerticalDivider _divider() {
    return VerticalDivider(
      thickness: 2,
      width: 0,
      color: Color(0xFFFDC930),
      indent: 5,
      endIndent: 5,
    );
  }

  void datos(List<dynamic> lista) {
    _datos = lista;
    notifyListeners();
  }

  void valido(bool boolean) {
    boolean = _valido;
    notifyListeners();
  }

  static bool getValido() {
    return _valido;
  }
}
