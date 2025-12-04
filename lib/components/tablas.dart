import 'package:flutter/material.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input_texto.dart';

class Tablas {
  static List<dynamic> datos = [];
  static late bool valido;

  static Container contenedorInfo(
    double grosor,
    List<double> grosores,
    List<String> textos,
  ) {
    List<Widget> lista = [];
    for (int i = 0; i < textos.length; i++) {
      if (grosores[i] > 0.075) {
        lista.add(_barraSuperior(grosor * grosores[i], textos[i]));
      } else {
        lista.add(_barraSuperiorS(grosor * grosores[i], textos[i]));
      }
      if (i != textos.length - 1) {
        lista.add(_divider());
      }
    }
    return Container(
      width: grosor,
      decoration: BoxDecoration(color: Color(0xFF8F01AF)),
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
    String errorTexto, {
    required Function modelo,
  }) {
    return FutureBuilder(
      future: modelo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            valido = true;
            datos = snapshot.data;
            if (datos.isNotEmpty) {
              if (datos[0].id == 0) {
                return Center(
                  child: Text(
                    datos[0].ultimaModificacion,
                    style: TextStyle(color: Color(0xFFF6AFCF), fontSize: 20),
                  ),
                );
              } else {
                return lista(datos);
              }
            } else {
              return textoError(textoListaVacia);
            }
          } else if (snapshot.hasError) {
            valido = false;
            return textoError("Error:\n${snapshot.error.toString()}");
          } else {
            if (CampoTexto.busquedaTexto.text.isNotEmpty) {
              return textoError(errorTexto);
            }
          }
        }
        return Carga.carga();
      },
    );
  }

  static SizedBox _barraSuperior(double grosor, String texto) {
    return SizedBox(
      width: grosor,
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  static SizedBox _barraSuperiorS(double grosor, String texto) {
    return SizedBox(
      width: grosor,
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  static Widget _barraDato(double grosor, String texto, Color color) {
    return Container(
      width: grosor,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: TextStyle(color: Color(0xFF8F01AF), fontSize: 20),
      ),
    );
  }

  static Widget barraDatos(
    double grosor,
    List<double> grosores,
    List<String> textos,
    List<Color> colores,
    bool boton,
    var extra,
  ) {
    List<Widget> lista = [];
    for (int i = 0; i < textos.length; i++) {
      if (textos[i].isEmpty) {
        lista.add(extra);
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
      return Container(
        width: grosor,
        height: 40,
        decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
        child: TextButton(
          onPressed: () => extra(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.all(0),
            shape: ContinuousRectangleBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: lista,
          ),
        ),
      );
    } else {
      return Container(
        width: grosor,
        height: 40,
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: lista,
        ),
      );
    }
  }

  static VerticalDivider _divider() {
    return VerticalDivider(
      thickness: 1,
      width: 0,
      color: Color(0xFFFDC930),
      indent: 5,
      endIndent: 5,
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
}
