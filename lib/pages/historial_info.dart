import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/historial_model.dart';
import 'package:inventarios/models/registro_model.dart';
import 'package:provider/provider.dart';
import '../components/textos.dart';

class HistorialInfo extends ChangeNotifier {
  static HistorialModel _historialInfo = HistorialModel.dummy('');
  static RegistroModel _registroInfo = RegistroModel.dummy('');
  static bool _esp = false, _reg = false, _tabla = false;
  static double cantidadPerdida = 0;

  void setHisotrial(HistorialModel histo) {
    _historialInfo = histo;
    cantidadPerdida = calcularPerdidas(histo.cantidades);
    notifyListeners();
  }

  void setRegistro(RegistroModel regis) {
    _registroInfo = regis;
    notifyListeners();
  }

  void esp(bool boolean) {
    _esp = boolean;
    notifyListeners();
  }

  void reg(bool boolean) {
    _reg = boolean;
    notifyListeners();
  }

  void tabla(bool boolean) {
    _tabla = boolean;
    notifyListeners();
  }

  double calcularPerdidas(List<double> lista) {
    double perdida = 0;
    for (double obj in lista) {
      perdida += obj;
    }
    return perdida;
  }

  Widget espInfo(BuildContext context) {
    return Visibility(
      visible: _esp,
      child: Stack(
        children: [
          Consumer<Carga>(
            builder: (context, carga, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 30),
                decoration: BoxDecoration(color: Colors.black38),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadiusGeometry.circular(25),
                      border: BoxBorder.all(
                        color: Color(0xFFFDC930),
                        width: 2.5,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Textos.textoTilulo(
                                _historialInfo.nombre,
                                30,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Textos.textoTilulo(
                                  'Fecha: ${_historialInfo.fecha}',
                                  20,
                                ),
                                Textos.textoTilulo(
                                  'Area: ${_historialInfo.area}',
                                  20,
                                ),
                                Row(
                                  spacing: 10,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Textos.textoTilulo(
                                      ('$cantidadPerdida'.split('.').length > 1)
                                          ? ('$cantidadPerdida'.split('.')[1] ==
                                                    '0')
                                                ? 'Perdidas: $cantidadPerdida'
                                                      .split('.')[0]
                                                : 'Perdidas: $cantidadPerdida'
                                          : 'Perdidas: $cantidadPerdida',
                                      20,
                                    ),
                                    if (cantidadPerdida > 0)
                                      Botones.btnSimple(
                                        'Ver perdidas',
                                        Icons.cookie_rounded,
                                        Color(0xFF8A03A9),
                                        () => tabla(true),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Tablas.contenedorInfo(
                                  MediaQuery.sizeOf(context).width,
                                  [.2, .2, .1, .1, .1, .1],
                                  [
                                    'Hora',
                                    'Usuario',
                                    'Unidades',
                                    'Entradas',
                                    'Salidas',
                                    'Perdidas',
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      (_historialInfo.entradas.length * 34 <
                                          MediaQuery.of(context).size.height *
                                              .7)
                                      ? _historialInfo.entradas.length * 34
                                      : MediaQuery.of(context).size.height * .7,
                                  child: ListView.separated(
                                    itemCount: _historialInfo.movimientos,
                                    scrollDirection: Axis.vertical,
                                    separatorBuilder: (context, index) =>
                                        Container(
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFDC930),
                                          ),
                                        ),
                                    itemBuilder: (context, index) {
                                      String unidad =
                                          '${_historialInfo.unidades[index]}';
                                      String entrada =
                                          '${_historialInfo.entradas[index]}';
                                      String salida =
                                          '${_historialInfo.salidas[index]}';
                                      return Container(
                                        width: MediaQuery.sizeOf(context).width,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                        ),
                                        child: Tablas.barraDatos(
                                          MediaQuery.sizeOf(context).width,
                                          [.2, .2, .1, .1, .1, .1],
                                          [
                                            _historialInfo
                                                .horasModificacion[index],
                                            _historialInfo
                                                .usuarioModificacion[index],
                                            (unidad.split('.').length > 1)
                                                ? (unidad.split('.')[1] == '0')
                                                      ? unidad.split('.')[0]
                                                      : unidad
                                                : unidad,
                                            (entrada.split('.').length > 1)
                                                ? (entrada.split('.')[1] == '0')
                                                      ? entrada.split('.')[0]
                                                      : entrada
                                                : entrada,
                                            (salida.split('.').length > 1)
                                                ? (salida.split('.')[1] == '0')
                                                      ? salida.split('.')[0]
                                                      : salida
                                                : salida,
                                            '${_historialInfo.perdidas[index]}',
                                          ],
                                          [],
                                          1,
                                          extra: () => {},
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Row(
                                    spacing: 7.5,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Botones.btnCirRos(
                                        'Cerrar',
                                        () => esp(false),
                                      ),
                                    ],
                                  ),
                                ),
                                /*SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height - 150,
                                  child: Consumer<Tablas>(
                                    builder: (context, tablas, child) {
                                      return Tablas.listaFutura(
                                        listaPrincipal,
                                        'No hay datos registrados.',
                                        'No hay datos registrados.',
                                        () => getHistorialInfo(_historialInfo),
                                        accionRefresh: () async => tablas.datos(
                                          await getHistorialInfo(
                                            _historialInfo,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),*/
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Consumer2<Ventanas, VenDatos>(
            builder: (context, ventana, venDatos, child) {
              return Ventanas.ventanaTabla(
                (120 + _historialInfo.cantidades.length * 30 <
                        MediaQuery.of(context).size.height * .7)
                    ? 120 + _historialInfo.cantidades.length * 30
                    : MediaQuery.of(context).size.height * .7,
                MediaQuery.of(context).size.width,
                [
                  ('$cantidadPerdida'.split('.').length > 1)
                      ? ('$cantidadPerdida'.split('.')[1] == '0')
                            ? 'Perdidas: $cantidadPerdida'.split('.')[0]
                            : 'Perdidas: $cantidadPerdida'
                      : 'Perdidas: $cantidadPerdida',
                ],
                cantidadPerdida > 0
                    ? Tablas.contenedorInfo(
                        MediaQuery.sizeOf(context).width,
                        [.05, .15, .6],
                        ['#', 'Cantidad perdida', 'Razón de perdida'],
                      )
                    : Textos.textoTilulo('', 30),
                SizedBox(
                  height: 3 + _historialInfo.cantidades.length * 28,
                  child: cantidadPerdida > 0
                      ? ListView.separated(
                          itemCount: _historialInfo.cantidades.length,
                          scrollDirection: Axis.vertical,
                          separatorBuilder: (context, index) => Container(
                            height: 2,
                            decoration: BoxDecoration(color: Color(0xFFFDC930)),
                          ),
                          itemBuilder: (context, index) {
                            String cantidad =
                                '${_historialInfo.cantidades[index]}';
                            return Container(
                              width: MediaQuery.sizeOf(context).width,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                              ),
                              child: Tablas.barraDatos(
                                MediaQuery.sizeOf(context).width,
                                [.05, .15, .6],
                                [
                                  '${index + 1}',
                                  (cantidad.split('.').length > 1)
                                      ? (cantidad.split('.')[1] == '0')
                                            ? cantidad.split('.')[0]
                                            : cantidad
                                      : cantidad,
                                  _historialInfo.razones[index],
                                ],
                                [],
                                2,
                              ),
                            );
                          },
                        )
                      : Textos.textoTilulo('No hay perdidas registradas', 30),
                ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Row(
                    spacing: 7.5,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Botones.btnCirRos('Cerrar', () => tabla(false))],
                  ),
                ),
                visible: _tabla,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget regInfo(BuildContext context) {
    return Visibility(
      visible: _reg,
      child: Consumer<Carga>(
        builder: (context, carga, child) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 70, vertical: 30),
            decoration: BoxDecoration(color: Colors.black38),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadiusGeometry.circular(25),
                  border: BoxBorder.all(color: Color(0xFFFDC930), width: 2.5),
                ),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height:
                        /*(listaProd.length * 44 + 120 <
                        MediaQuery.sizeOf(context).height - 100)
                        ? listaProd.length * 44 + 120
                        : MediaQuery.sizeOf(context).height - 100,*/
                        (_registroInfo.articulos.length * 35 <
                            MediaQuery.of(context).size.height)
                        ? _registroInfo.articulos.length * 35
                        : MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 0,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Textos.textoTilulo(
                              'Fecha: ${_registroInfo.fecha}',
                              20,
                            ),
                            Textos.textoTilulo(
                              'Hora: ${_registroInfo.hora}',
                              20,
                            ),
                            Textos.textoTilulo(
                              'Usuario: ${_registroInfo.usuario}',
                              20,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Tablas.contenedorInfo(
                              MediaQuery.sizeOf(context).width,
                              [.1, .35, .1, .15, .1],
                              ['id', 'Nombre', 'Tipo', 'Área', 'Unidades'],
                            ),
                            SizedBox(
                              height:
                                  (_registroInfo.articulos.length * 35 <
                                      MediaQuery.of(context).size.height - 220)
                                  ? _registroInfo.articulos.length * 35
                                  : MediaQuery.of(context).size.height - 220,
                              child: ListView.separated(
                                itemCount: _registroInfo.articulos.length,
                                scrollDirection: Axis.vertical,
                                separatorBuilder: (context, index) => Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFDC930),
                                  ),
                                ),
                                itemBuilder: (context, index) {
                                  String unidad =
                                      '${_registroInfo.unidades[index]}';
                                  return Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    child: Tablas.barraDatos(
                                      MediaQuery.sizeOf(context).width,
                                      [.1, .35, .1, .15, .1],
                                      [
                                        '${_registroInfo.idProducto[index]}',
                                        _registroInfo.articulos[index],
                                        _registroInfo.tipos[index],
                                        _registroInfo.areas[index],
                                        (unidad.split('.').length > 1)
                                            ? (unidad.split('.')[1] == '0')
                                                  ? unidad.split('.')[0]
                                                  : unidad
                                            : unidad,
                                      ],
                                      [],
                                      1,
                                      extra: () => {},
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Row(
                                spacing: 7.5,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Botones.btnCirRos('Cerrar', () => reg(false)),
                                ],
                              ),
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
        },
      ),
    );
  }
}
