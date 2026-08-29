import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Carga with ChangeNotifier {
  static bool _cargaBool = false;
  static bool _valido = false;

  //Componente que muestra un símbolo de carga en el centro del componente
  //principal, usualmente usado en tablas al momento de recargar
  static Center carga() {
    return Center(child: CircularProgressIndicator(color: Color(0xFFF6AFCF)));
  }

  //Componente presente en cada pagina para representar que se envio información
  //al servidor y se podra reanudar el uso de la misma app despues cuando esta
  //tenga una respuesta del anteriormente mencionado, ademas previene al
  //usuario siga mandando peticiones y sobrecarge el servidor.
  static Consumer<Carga> ventanaCarga() {
    return Consumer<Carga>(
      builder: (context, carga, child) {
        return Visibility(
          visible: _cargaBool,
          child: Container(
            decoration: BoxDecoration(color: Colors.black45),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFF6AFCF)),
            ),
          ),
        );
      },
    );
  }

  //Este método set dicta si la pantalla de carga es visible o no, como el
  //componente 'ventanaCarga' depende de la variable '_cargaBool' para ser
  //visible con este método se puede cambiar el valor de este booleano.
  void cargaBool(bool boolean) {
    _cargaBool = boolean;
    notifyListeners();
  }

  //Este método set dicta el valor de la variable '_valido', esta variable
  //controla si se pueden usar ciertos botones, indicando si el estado de la
  //aplicación con relación a la orden que se está ejecutando es válida.
  void valido(bool boolean) {
    _valido = boolean;
    notifyListeners();
  }

  //Este método get regresa el valor de la variable '_valido' a los diferentes
  //componentes que dependen del estado uma transacción con la aplicación.
  static bool getValido() {
    return _valido;
  }
}
