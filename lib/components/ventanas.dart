import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/orden_model.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';

class Ventanas with ChangeNotifier {
  static FocusNode focus = FocusNode();
  static bool _emergente = false,
      _tabla = false,
      _cambio = false,
      _scan = false,
      _ordenFiltro = false;
  static String _inventario = LocalStorage.local('locación');

  //Este es un componente que devuelve una ventana emergente simple, la cual
  //puede alternar si está visible o no con la variable "_emergente" de esta
  //clase, requiere un texto, 2 textos relacionados con los botones de no y si,
  //respectivamente; además de 2 funciones, relacionadas con ambos botones de no
  //y sí; también se puede declarar un widget extra el cual se ubicara entre el
  //texto principal y los botones de sí y no, hablando de los botones si y no,
  //se pueden añadir botones extra que estarán antes de los botones antes
  //mencionados, además se puede declara un booleano con el cual se puede ver,
  //si es que no se quiere usar la variable "_emergente".
  static Widget ventanaEmergente(
    String texto,
    String no,
    String si,
    Function btnNo,
    Function btnSi, {
    Widget? widget,
    Widget? extraButton,
    bool? visible,
  }) {
    return Visibility(
      visible: visible ?? _emergente,
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Textos.textoTilulo(texto, 25),
                  ?widget,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 15,
                    children: [
                      ?extraButton,
                      if (no.isNotEmpty) Botones.btnCirRos(no, () => btnNo()),
                      if (si.isNotEmpty) Botones.btnCirRos(si, () => btnSi()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Este es un componente que devuelve una ventana con una tabla e información
  //relacionada, la cual puede alternar si está visible o no con la variable
  //"_tabla" de esta clase, requiere el tamaño del alto y ancho que tendrá la
  //ventana, una lista con los títulos que tendrá la ventana (todos los títulos
  //estarán en la parte superior de la ventana), un widget que se mostrara en él
  //arriba de la tabla con información de que representan los datos de la tabla,
  //un widget tipo SizedBox el cual se espera que contenga una tabla (es el
  //propósito principal de esta ventana), y una lista con botones con funciones
  //relacionadas con la información de la tabla; por último, se puede declara un
  //booleano con el cual se puede ver, si es que no se quiere usar la variable
  //"_tabla".
  static Widget ventanaTabla(
    double? alto,
    double ancho,
    List<String> tituloTexto,
    Widget tablaInfo,
    SizedBox tablaListView,
    Widget botones, {
    bool? visible,
  }) {
    List<Widget> titulos = [];
    List<Widget> footer = [];
    for (String titulo in tituloTexto) {
      titulos.add(Textos.textoTilulo(titulo, 20));
    }
    return Visibility(
      visible: visible ?? _tabla,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 0,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: titulos,
                  ),
                  Column(children: [tablaInfo, tablaListView]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: footer,
                      ),
                    ],
                  ),
                  botones,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Este es un componente que devuelve una ventana simple, la cual puede
  //alternar si está visible o no con la variable "_cambio" de esta clase,
  //tiene el texto "Cambio de tienda:" como título, una lista que se puede
  //colapsar con una lista de las tiendas almacenadas en la base de datos y,
  //por último, se cuentan con 2 botones en la parte inferior de la ventana, uno
  //para cancelar el proceso de cambio de tienda ocultando la ventana y otro
  //para proseguir con el cambio de la tienda mientras también se oculta la
  //ventana; además del contexto, lo único de se debe declara es la acción que
  //se realizara al momento de presionar el botón con texto "Cambiar".
  static Widget cambioDeTienda(BuildContext context, Function accion) {
    return Visibility(
      visible: _cambio,
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Textos.textoTilulo('Cambio de tienda:', 20),
                  CampoTexto.inputDropdown(
                    MediaQuery.sizeOf(context).width,
                    Icons.change_circle_rounded,
                    _inventario,
                    [
                      'Árbol Grande',
                      'Bicentenario',
                      'Café',
                      'Cedis',
                      'Faja de Oro',
                      'Portales',
                      'Yogulive Jardín',
                      'Yogulive Árbol Grande',
                    ],
                    Color(0x00000000),
                    (value) => context.read<Ventanas>().setInventario(value),
                  ),
                  Row(
                    spacing: 7.5,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Botones.btnCirRos(
                        'Cancelar',
                        () => {
                          _inventario = LocalStorage.local('locación'),
                          context.read<Ventanas>().cambio(false),
                        },
                      ),
                      Botones.btnCirRos(
                        'Cambiar',
                        () => cambioDeTiendaAccion(context, () => accion()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Este es un componente que devuelve una ventana con un campo de texto
  //editable el cual tiene que estar relacionado con el código de barras de un
  //artículo, la cual puede alternar si está visible o no con la variable
  //"_scan" de esta clase, requiere el contexto del proyecto, una acción al
  //momento de presionar el botón cancelar y una función que requiera un
  //parámetro de texto que este realizara al momento de presionar enter,
  //usualmente se usan métodos que redirigen a productos con relación a un
  //código de barras; por último, se puede declara un booleano con el cual se
  //puede ver, si es que no se quiere usar la variable "_scan", cabe aclarar
  //que esta ventana solo se usa en la versión web de la aplicación.
  static Widget ventanaScan(
    BuildContext ctx,
    Function btnAccion,
    Function(String valor) accion, {
    bool? visible,
  }) {
    return Visibility(
      visible: visible ?? _scan,
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Textos.textoTilulo("Escanea un producto", 25),
                  SizedBox(
                    width: MediaQuery.of(ctx).size.width * .75,
                    child: TextField(
                      focusNode: focus,
                      onSubmitted: (texto) => {
                        accion(texto),
                        ctx.read<Ventanas>().scan(false),
                      },
                      cursorColor: Color(0xFF8A03A9),
                      style: TextStyle(color: Color(0xFF8A03A9)),
                      decoration: InputDecoration(
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Color(0xFFFDC930),
                            width: 3.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Color(0xFFFDC930),
                            width: 3.5,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Color(0xFFFDC930),
                            width: 2.5,
                          ),
                        ),
                        prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                        prefixIconColor: Color(0xFF8A03A9),
                        fillColor: Colors.white,
                        label: Text(
                          'Código de barras',
                          style: TextStyle(color: Color(0xFF8A03A9)),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 15,
                    children: [Botones.btnCirRos('Volver', () => btnAccion())],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Este es un componente que devuelve una ventana con una lista simple, la cual
  //puede alternar si está visible o no con la variable "_ordenFiltro" de esta
  //clase, tiene el texto "Filtro de estados:" como título, una lista con los
  //estados que puede tener una orden y un botón de selección por cada elemento
  //de la lista, la intención de esta ventana es alternar entre que órdenes con
  //cierto estado se puede ver, requiere el contexto de la aplicación la lista de
  //booleanos, con relación a que órdenes se quieren ver y la acción que se
  //ejecutara al momento de cambiar un filtro.
  Widget ventanaFiltroOrden(
    BuildContext ctx,
    List<bool> lista,
    Function accion,
  ) {
    return Visibility(
      visible: _ordenFiltro,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 90),
        decoration: BoxDecoration(color: Colors.black38),
        child: Center(
          child: Container(
            width: 315,
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadiusGeometry.circular(25),
              border: BoxBorder.all(color: Color(0xFFFDC930), width: 2.5),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Textos.textoTilulo('Filtro de estados', 20),
                  SizedBox(
                    width: 315,
                    height: MediaQuery.of(ctx).size.height * .35 < 250
                        ? MediaQuery.of(ctx).size.height * .35
                        : 250,
                    child: ListView.separated(
                      itemCount: OrdenModel.listaEstados().length,
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) => Container(
                        height: 2,
                        decoration: BoxDecoration(color: Color(0xFFFDC930)),
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          width: 315,
                          height: 40,
                          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                          child: Tablas.barraDatos(
                            315,
                            [0.75, 0.15],
                            [
                              OrdenModel.listaEstados()[index],
                              Botones.btnRctMor(
                                'Ver ${OrdenModel.listaEstados()[index]}',
                                lista[index]
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                false,
                                () async => {
                                  lista[index] = !lista[index],
                                  lista.contains(true)
                                      ? accion()
                                      : {
                                          lista[index] = !lista[index],
                                          Textos.toast(
                                            'Debe de haber al menos 1 filtro seleccionado.',
                                          ),
                                        },
                                },
                                size: 20,
                              ),
                            ],
                            maxLines: 2,
                            colores: [
                              Textos.colorEstado(
                                OrdenModel.listaEstados()[index],
                              ),
                              Colors.transparent,
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Botones.btnCirRos(
                      'Cerrar',
                      () => ctx.read<Ventanas>().ordenFiltro(false),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Método que cambia el valor del booleano "_tabla", esta variable se encarga
  //de la visibilidad del componente "ventanaTabla".
  void tabla(bool booleano) {
    _tabla = booleano;
    notifyListeners();
  }

  //Método que cambia el valor del booleano "_emergente", esta variable se encarga
  //de la visibilidad del componente "ventanaEmergente".
  void emergente(bool booleano) {
    _emergente = booleano;
    notifyListeners();
  }

  //Método que cambia el valor del booleano "_cambio", esta variable se encarga
  //de la visibilidad del componente "cambioDeTienda".
  void cambio(bool booleano) {
    _cambio = booleano;
    notifyListeners();
  }

  //Método que cambia el valor del booleano "_scan", esta variable se encarga
  //de la visibilidad del componente "ventanaScan".
  void scan(bool booleano) {
    _scan = booleano;
    focus.requestFocus();
    notifyListeners();
  }

  //Método que cambia el valor del booleano "_ordenFiltro", esta variable se
  //encarga de la visibilidad del componente "ventanaFiltroOrden".
  void ordenFiltro(bool booleano) {
    _ordenFiltro = booleano;
    notifyListeners();
  }

  //Método que cambia el valor de todos los booleanos de esta clase a falso,
  //con el fin de cerrar todas las ventanas usualmente se usa al momento de
  //cambiar de página.
  void cerrarVentanas() {
    _emergente = false;
    _tabla = false;
    _cambio = false;
    _scan = false;
    _ordenFiltro = false;
    notifyListeners();
  }

  //Método get que retorna el nombre de la locación que tiene el usuario.
  static String getInventario() {
    return _inventario;
  }

  //Método set que establece el valor de la variable _inventario, este método se
  //usa cuando un administrador cambia de tienda, a pesar de que el cambio se
  //hace a nivel servidor este no se actualiza al instante a nivel aplicación,
  //así que para eliminar inconsistencia y mantener la el sentido en el usuario
  //se guarda.
  void setInventario(String locacion) {
    _inventario = locacion;
    notifyListeners();
  }

  //Método que se ejecuta al momento de seleccionar una tienda en la ventana
  //relacionada al cambio de tienda, habilita la pantalla de carga, verifica si
  //la tienda seleccionada si es la misma que ya estaba o si es diferente, si es
  //la misma tienda mostrara un mensaje recordando el error que se comentó, en
  //caso de ser una tienda diferente entonces se hace la petición para cambiar
  //de tienda, si esta petición da error entonces se muestra el mensaje de
  //error, pero si por otro lado todo sale bien se cambiara el almacén en el
  //servido y en la aplicación, por último se cerrara la ventana de cambio de
  //tienda.
  static void cambioDeTiendaAccion(BuildContext ctx, Function accion) async {
    ctx.read<Carga>().cargaBool(true);
    String mensaje;
    if (_inventario != LocalStorage.local('locación')) {
      mensaje = await UsuarioModel.cambiarInfo('Locacion', _inventario);
    } else {
      mensaje = 'Error: No hay cambios';
    }
    mensaje.split(': ')[0] != 'Error'
        ? {
            LocalStorage.set('locación', _inventario),
            if (ctx.mounted) ctx.read<Ventanas>().cambio(false),
            accion(),
          }
        : mensaje = mensaje.split(':')[1];
    Textos.toast(mensaje);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }
}
