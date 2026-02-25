import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:provider/provider.dart';

class Tablas with ChangeNotifier {
  static List<dynamic> _datos = [];

  static Container contenedorInfo(
    double grosor,
    List<double> grosores,
    List<String> textos,
  ) {
    List<Widget> lista = [];
    for (int i = 0; i < textos.length; i++) {
      lista.add(
        _barraSuperior(grosor * grosores[i], textos[i], (grosores[i] > 0.075)),
      );
      lista.add(_divider());
    }
    lista.removeLast();
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
    ListView Function(List<dynamic>, ScrollController) lista,
    String textoListaVacia,
    String errorTexto,
    Function modelo, {
    Function? accionRefresh,
  }) {
    ScrollController controller = ScrollController();
    return FutureBuilder(
      future: modelo(),
      builder: (context, snapshot) {
        Widget wid = Carga.carga();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<Carga>().valido(false);
        });
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            _datos = snapshot.data;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<Carga>().valido(true);
            });
            wid = Center(child: Textos.textoError(textoListaVacia));
            if (_datos.isNotEmpty) {
              wid = Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Textos.textoError(_datos.last.mensaje),
                  Botones.icoCirMor(
                    'Volver a cargar',
                    Icons.refresh_rounded,
                    () async => await accionRefresh!(),
                    () => {},
                    false,
                    true,
                  ),
                ],
              );
              if (CampoTexto.busquedaTexto.text.isNotEmpty) {
                wid = Center(child: Textos.textoError(errorTexto));
              }
              if (_datos.last.mensaje == '') {
                wid = Scrollbar(
                  controller: controller,
                  thickness: 17.5,
                  thumbVisibility: true,
                  interactive: true,
                  trackVisibility: true,
                  child: lista(_datos, controller),
                );
              }
            }
          } else if (snapshot.hasError) {
            wid = Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Textos.textoError('Error:\n${snapshot.error}'),
                Botones.icoCirMor(
                  'Volver a cargar',
                  Icons.refresh_rounded,
                  () async => await accionRefresh!(),
                  () => {},
                  false,
                  true,
                ),
              ],
            );
          }
        }
        return RefreshIndicator(
          child: wid,
          onRefresh: () async => await accionRefresh!(),
        );
      },
    );
  }

  static SizedBox _barraSuperior(double grosor, String texto, bool grande) {
    return SizedBox(
      width: grosor,
      child: Textos.textoBlanco(texto, size: grande ? 15 : 12),
    );
  }

  static Widget _barraDato(
    double grosor,
    String texto,
    Color color,
    int maxLines,
  ) {
    return Container(
      width: grosor,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Textos.textoGeneral(
        texto,
        true,
        maxLines,
        size: 20,
        alignment: TextAlign.center,
      ),
    );
  }

  static Widget barraDatos(
    double grosor,
    List<double> grosores,
    List<String> textos,
    List<Color> colores,
    int maxLines,
    bool boton, {
    Function? extra,
    Widget? extraWid,
  }) {
    List<Widget> lista = [];
    for (int i = 0; i < textos.length; i++) {
      lista.add(
        textos[i].isEmpty
            ? SizedBox(width: grosor * grosores[i], child: extraWid!)
            : _barraDato(
                grosor * grosores[i],
                textos[i],
                colores.isNotEmpty ? colores[i] : Colors.transparent,
                maxLines,
              ),
      );
      lista.add(_divider());
    }
    lista.removeLast();
    Widget wid = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: lista,
    );
    if (boton) {
      wid = TextButton(
        onPressed: () => extra!(),
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(0),
          shape: ContinuousRectangleBorder(),
        ),
        child: wid,
      );
    }
    return wid;
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
}
