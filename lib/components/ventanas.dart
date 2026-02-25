import 'package:flutter/material.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/articulos_model.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';
import 'botones.dart';
import 'carga.dart';

class Ventanas with ChangeNotifier {
  static FocusNode focus = FocusNode();
  static bool _emergente = false;
  static bool _tabla = false;
  static bool _cambio = false;
  static bool _scan = false;
  static String _inventario = LocalStorage.local('locación');

  static Widget ventanaEmergente(
    String texto,
    String no,
    String si,
    Function btnNo,
    Function btnSi, {
    Widget? widget,
  }) {
    return Visibility(
      visible: _emergente,
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
                      Botones.btnCirRos(no, () => btnNo()),
                      Botones.btnCirRos(si, () => btnSi()),
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
    double alto,
    double ancho,
    List<String> tituloTexto,
    List<String> footerTexto,
    Widget tablaInfo,
    Widget tablaListView,
    List<Widget> botones,
  ) {
    List<Widget> titulos = [];
    List<Widget> footer = [];
    for (String titulo in tituloTexto) {
      titulos.add(Textos.textoTilulo(titulo, 20));
    }
    if (footerTexto.isNotEmpty) {
      for (String texto in footerTexto) {
        footer.add(
          Textos.textoGeneral(
            texto,
            false,
            1,
            alignment: (footerTexto.length > 1)
                ? TextAlign.start
                : TextAlign.center,
            size: (footerTexto.length > 1) ? 15 : 20,
          ),
        );
      }
    }
    return Visibility(
      visible: _tabla,
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
                  Column(
                    children: [
                      tablaInfo,
                      (tablaListView.runtimeType == ListView)
                          ? Container(
                              width: ancho,
                              height:
                                  alto - ((footerTexto.length > 1) ? 168 : 153)-65,
                              margin: EdgeInsets.zero,
                              child: tablaListView,
                            )
                          : tablaListView,
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: footer,
                      ),
                      Row(
                        spacing: 7.5,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: botones,
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

  static Widget ventanaScan(BuildContext ctx, Function(String valor) accion) {
    return Visibility(
      visible: _scan,
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
                    children: [
                      Botones.btnCirRos(
                        'Volver',
                        () => ctx.read<Ventanas>().scan(false),
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
