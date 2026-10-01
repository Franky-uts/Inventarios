import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/historial_model.dart';
import 'package:inventarios/models/registro_model.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';
import 'package:inventarios/components/textos.dart';

//Esta es una página ventana con información relacionada con un movimiento o
//registro seleccionado de la lista del historial.
class HistorialInfo extends ChangeNotifier {
  static HistorialModel _historialInfo = HistorialModel.dummy('');
  static RegistroModel _registroInfo = RegistroModel.dummy('');
  static bool _esp = false, _reg = false, _tabla = false;
  static double cantidadPerdida = 0;

  //Método que establece el movimiento que se mostrara.
  void setHisotrial(HistorialModel histo) {
    _historialInfo = histo;
    cantidadPerdida = calcularPerdidas(histo.cantidades);
    notifyListeners();
  }

  //Método que establece el registro que se mostrara.
  void setRegistro(RegistroModel regis) {
    _registroInfo = regis;
    notifyListeners();
  }

  //Método que controla el booleano "_esp", este se encarga de la visibilidad de
  //la ventana que muestra el movimiento.
  void esp(bool boolean) {
    _esp = boolean;
    notifyListeners();
  }

  //Método que controla el booleano "_reg", este se encarga de la visibilidad de
  //la ventana que muestra el registro.
  void reg(bool boolean) {
    _reg = boolean;
    notifyListeners();
  }

  //Método que controla el booleano "_tabla", este se encarga de la visibilidad
  //de la ventana tabla que se maneja en esta clase.
  void tabla(bool boolean) {
    _tabla = boolean;
    notifyListeners();
  }

  //Este es un método que se encarga de calcular cuantas perdidas hay
  //registradas en un movimiento.
  double calcularPerdidas(List<double> lista) {
    double perdida = 0;
    for (double obj in lista) {
      perdida += obj;
    }
    return perdida;
  }

  //Componente tipo ventana que muestra la información de un movimiento, la
  //información del movimiento es guardada en la variable "_historialInfo", su
  //visibilidad es controlada por la variable "_esp".
  Widget espInfo(BuildContext context) {
    return Visibility(
      visible: _esp,
      child: Stack(
        children: [
          Consumer<Carga>(
            builder: (context, carga, child) {
              String cantPer = 'Perdidas: $cantidadPerdida';
              if (cantPer.split('.').length > 1) {
                if (cantPer.split('.')[1] == '0') {
                  cantPer = 'Perdidas: $cantidadPerdida'.split('.')[0];
                }
              }
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
                                    Textos.textoTilulo(cantPer, 20),
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
                                  [
                                    .2,
                                    .2,
                                    .075,
                                    .075,
                                    .075,
                                    .075,
                                    .075,
                                    .075,
                                    .075,
                                  ],
                                  [
                                    'Hora',
                                    'Usuario',
                                    'Ent. Cont.',
                                    'Ent.Paq.',
                                    'Entradas',
                                    'Sal. Cont.',
                                    'Sal. Paq.',
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
                                      String entrada =
                                          '${_historialInfo.entradas[index]}';
                                      String entradaPaq =
                                          '${_historialInfo.entradasPaq[index]}';
                                      String entradaCont =
                                          '${_historialInfo.entradasCont[index]}';
                                      String salida =
                                          '${_historialInfo.salidas[index]}';
                                      String salidaPaq =
                                          '${_historialInfo.salidasPaq[index]}';
                                      String salidaCont =
                                          '${_historialInfo.salidasCont[index]}';
                                      if (entrada.split('.').length > 1) {
                                        if (entrada.split('.')[1] == '0') {
                                          entrada = entrada.split('.')[0];
                                        }
                                      }
                                      if (salida.split('.').length > 1) {
                                        if (salida.split('.')[1] == '0') {
                                          salida = salida.split('.')[0];
                                        }
                                      }
                                      if (entradaPaq.split('.').length > 1) {
                                        if (entradaPaq.split('.')[1] == '0') {
                                          entradaPaq = entradaPaq.split('.')[0];
                                        }
                                      }

                                      if (salidaPaq.split('.').length > 1) {
                                        if (salidaPaq.split('.')[1] == '0') {
                                          salidaPaq = salidaPaq.split('.')[0];
                                        }
                                      }
                                      if (entradaCont.split('.').length > 1) {
                                        if (entradaCont.split('.')[1] == '0') {
                                          entradaCont = entradaCont.split(
                                            '.',
                                          )[0];
                                        }
                                      }
                                      if (salidaCont.split('.').length > 1) {
                                        if (salidaCont.split('.')[1] == '0') {
                                          salidaCont = salidaCont.split('.')[0];
                                        }
                                      }
                                      return Container(
                                        width: MediaQuery.sizeOf(context).width,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                        ),
                                        child: Tablas.barraDatos(
                                          MediaQuery.sizeOf(context).width,
                                          [
                                            .2,
                                            .2,
                                            .075,
                                            .075,
                                            .075,
                                            .075,
                                            .075,
                                            .075,
                                            .075,
                                          ],
                                          [
                                            _historialInfo
                                                .horasModificacion[index],
                                            _historialInfo
                                                .usuarioModificacion[index],
                                            entradaCont,
                                            entradaPaq,
                                            entrada,
                                            salidaCont,
                                            salidaPaq,
                                            salida,
                                            '${_historialInfo.perdidas[index]}',
                                          ],

                                          extra: () {},
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
              String cantPer = 'Perdidas: $cantidadPerdida';
              if (cantPer.split('.').length > 1) {
                if (cantPer.split('.')[1] == '0') {
                  cantPer = cantPer.split('.')[0];
                }
              }
              return Ventanas.ventanaTabla(
                (120 + _historialInfo.cantidades.length * 30 <
                        MediaQuery.of(context).size.height * .7)
                    ? 120 + _historialInfo.cantidades.length * 30
                    : MediaQuery.of(context).size.height * .7,
                MediaQuery.of(context).size.width,
                [cantPer],
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
                                maxLines: 2,
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

  //Componente tipo ventana que muestra la información de un registro, la
  //información del movimiento es guardada en la variable "_registroInfo", su
  //visibilidad es controlada por la variable "_reg".
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
                              [.05, .25, .15, .15, .1, .1, .1],
                              [
                                'id',
                                'Nombre',
                                'Tipo',
                                'Área',
                                'Cerr.',
                                'Paqu.',
                                'Abie.',
                              ],
                            ),
                            SizedBox(
                              height:
                                  (_registroInfo.articulos.length * 35 <
                                      MediaQuery.of(context).size.height * .7)
                                  ? _registroInfo.articulos.length * 35
                                  : MediaQuery.of(context).size.height * .7,
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
                                  List<Color> colores = [];
                                  colores = List.filled(7, Colors.transparent);
                                  colores[4] = Textos.colorLimite(
                                    _registroInfo.limite[index],
                                    _registroInfo.cerrados[index].floor(),
                                  );
                                  String cerrados =
                                      '${_registroInfo.cerrados[index]}';
                                  if (cerrados.split('.').length > 1) {
                                    if (cerrados.split('.')[1] == '0') {
                                      cerrados = cerrados.split('.')[0];
                                    }
                                  }
                                  String paquetes =
                                      '${_registroInfo.paquetes[index]}';
                                  if (paquetes.split('.').length > 1) {
                                    if (paquetes.split('.')[1] == '0') {
                                      paquetes = paquetes.split('.')[0];
                                    }
                                  }
                                  String abiertos =
                                      '${_registroInfo.abiertos[index]}';
                                  if (abiertos.split('.').length > 1) {
                                    if (abiertos.split('.')[1] == '0') {
                                      abiertos = abiertos.split('.')[0];
                                    }
                                  }
                                  return Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    child: Tablas.barraDatos(
                                      MediaQuery.sizeOf(context).width,
                                      [.05, .25, .15, .15, .1, .1, .1],
                                      [
                                        '${_registroInfo.idProducto[index]}',
                                        _registroInfo.articulos[index],
                                        _registroInfo.tipos[index],
                                        _registroInfo.areas[index],
                                        cerrados,
                                        paquetes,
                                        abiertos,
                                      ],
                                      extra: () {},
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
