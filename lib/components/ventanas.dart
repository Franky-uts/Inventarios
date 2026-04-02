import 'package:flutter/material.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/articulos_model.dart';
import 'package:inventarios/models/orden_model.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';
import 'botones.dart';
import 'carga.dart';

class Ventanas with ChangeNotifier {
  static FocusNode focus = FocusNode();
  static bool _emergente = false,
      _tabla = false,
      _cambio = false,
      _scan = false,
      _ordenFiltro = false;
  static String _inventario = LocalStorage.local('locación');

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
                    ArticulosModel.getInventarios(),
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

  Widget ventanaFiltroOrden(
    BuildContext ctx,
    List<bool> lista,
    Function accion,
  ) {
    return Visibility(
      visible: _ordenFiltro,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 90, vertical: 30),
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
                    height: MediaQuery.of(ctx).size.height * .45 < 250
                        ? MediaQuery.of(ctx).size.height * .45
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
                                            true,
                                          ),
                                        },
                                },
                                size: 20,
                              ),
                            ],
                            [
                              Textos.colorEstado(
                                OrdenModel.listaEstados()[index],
                              ),
                              Colors.transparent,
                            ],
                            2,
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

  void tabla(bool booleano) {
    _tabla = booleano;
    notifyListeners();
  }

  void emergente(bool booleano) {
    _emergente = booleano;
    notifyListeners();
  }

  void cambio(bool booleano) {
    _cambio = booleano;
    notifyListeners();
  }

  void scan(bool booleano) {
    _scan = booleano;
    focus.requestFocus();
    notifyListeners();
  }

  void ordenFiltro(bool booleano) {
    _ordenFiltro = booleano;
    notifyListeners();
  }

  void cerrarVentanas() {
    _emergente = false;
    _tabla = false;
    _cambio = false;
    _scan = false;
    _ordenFiltro = false;
    notifyListeners();
  }

  static String getInventario() {
    return _inventario;
  }

  void setInventario(String locacion) {
    _inventario = locacion;
    notifyListeners();
  }

  static void cambioDeTiendaAccion(BuildContext ctx, Function accion) async {
    ctx.read<Carga>().cargaBool(true);
    String mensaje;
    _inventario != LocalStorage.local('locación')
        ? mensaje = await UsuarioModel.cambiarInfo('Locacion', _inventario)
        : mensaje = 'Error: No hay cambios';
    mensaje.split(': ')[0] != 'Error'
        ? {
            LocalStorage.set('locación', _inventario),
            if (ctx.mounted) ctx.read<Ventanas>().cambio(false),
            accion(),
          }
        : mensaje = mensaje.split(':')[1];

    Textos.toast(mensaje, true);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }
}
