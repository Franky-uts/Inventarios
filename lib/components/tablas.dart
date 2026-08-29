import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:provider/provider.dart';

class Tablas with ChangeNotifier {
  static List<dynamic> _datos = [];

  //Este componente es el contenedor de información en la parte superior de una
  //lista, es de color morado con letras blancas para contrastar con las listas
  //de fondo blanco con letras moradas.
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
      lista.add(_divider(color: Color(0xFF8A03A9)));
    }
    lista.removeLast();
    return Container(
      width: grosor,
      height: 17.5,
      decoration: BoxDecoration(color: Color(0xFF8A03A9)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: lista,
      ),
    );
  }

  //Este componente es una lista que trabaja con una lista la cual puede o no
  //tener información y puede tener una acción al recargar, usualmente volver a
  //consultar la información.
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
                  thickness: 10,
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

  //Esta componente es el que utiliza "contenedorInfo" para poder separar los
  //datos, se hizo con el fin de hacer más fácil de leer el código y consumir
  //menos líneas de código.
  static SizedBox _barraSuperior(double grosor, String texto, bool grande) {
    return SizedBox(
      width: grosor,
      child: Textos.textoBlanco(texto, size: grande ? 15 : 12),
    );
  }

  //Esta componente es el que utiliza "barraDatos" para poder separar los datos,
  //solo se utiliza cuando el dato es de tipo texto, de otra forma se utilizara
  //el widget que se declaró (en caso de ser un widget) se hizo con el mismo fin
  //que el elemento anterior.
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

  //Este componente es el contenedor de información donde se muestra toda la
  //información de las páginas principales, se puede editar su ancho, el ancho
  //de cada uno de los contenedores de información, el texto que tendrá cada
  //contenedor, la cantidad de líneas que tenga cada contenedor de texto, y el
  //color del fondo, la lista que almacena los textos se llama "info", pero no
  //solo almacena textos, sino que también puede almacenar otro tipo de datos,
  //preferentemente botones o cajas de texto, por último también se puede añadir
  //una acción, si este es caso el widget se transformara en un botón y
  //ejecutara la acción declarada al momento de presionar la sección, en caso de
  //que se decida hacer esto se recomienda que la variable "info" sean
  //únicamente textos.
  static Widget barraDatos(
    double grosor,
    List<double> grosores,
    List info, {
    int maxLines = 1,
    List<Color>? colores,
    Function? extra,
  }) {
    List<Widget> lista = [];
    for (int i = 0; i < info.length; i++) {
      lista.add(
        info[i].runtimeType == String
            ? _barraDato(
                grosor * grosores[i],
                info[i],
                (colores != null) ? colores[i] : Colors.transparent,
                maxLines,
              )
            : SizedBox(width: grosor * grosores[i], child: info[i]),
      );
      lista.add(_divider());
    }
    lista.removeLast();
    Widget wid = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: lista,
    );
    if (extra != null) {
      wid = TextButton(
        onPressed: () => extra(),
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(0),
          shape: ContinuousRectangleBorder(),
        ),
        child: wid,
      );
    }
    return wid;
  }

  //Este es un componente tipo divisor vertical, el cual solo se encuentra en
  //las barras de datos y la barra de información, como es un elemento que
  //siempre se encuentra y tiene la misma información no requiere parámetros,
  //pero en caso de que se le quiera cambiar el color se puede hacer declarando
  //la variable color, además, el propósito de crear este componente es tener
  //mejor lectura del código.
  static VerticalDivider _divider({Color? color}) {
    return VerticalDivider(
      thickness: 2,
      width: 0,
      color: color ?? Color(0xFFFDC930),
      indent: 5,
      endIndent: 5,
    );
  }

  //Esta es una función la cual actualiza la información de las listas, de
  //forma dinámica, funciona únicamente en las páginas principales (ya que son
  //las únicas con tablas, como claramente ya conoces, mi camarada lector).
  void datos(List<dynamic> lista) {
    _datos = lista;
    notifyListeners();
  }
}
