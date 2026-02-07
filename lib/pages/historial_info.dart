import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/historial_model.dart';
import 'package:inventarios/pages/historial.dart';
import 'package:provider/provider.dart';

import '../components/textos.dart';

class HistorialInfo extends StatefulWidget {
  final HistorialModel historialInfo;
  final StatefulWidget ruta;

  const HistorialInfo({
    super.key,
    required this.historialInfo,
    required this.ruta,
  });

  @override
  State<HistorialInfo> createState() => _HistorialInfoState();
}

class _HistorialInfoState extends State<HistorialInfo> {
  double cantidadPerdida = 0;
  bool perdidas = true;

  @override
  void initState() {
    widget.historialInfo.perdidas = [0];
    super.initState();
  }

  Future<List<HistorialModel>> getHistorialInfo() async {
    List<HistorialModel> historial = await HistorialModel.getHistorialInfo(
      widget.historialInfo.id,
      widget.historialInfo.fecha,
    );
    if (perdidas) {
      for (int i = 0; i < historial[0].cantidades.length; i++) {
        cantidadPerdida += historial[0].cantidades[i];
      }
      setState(() {
        widget.historialInfo.cantidades = historial[0].cantidades;
        widget.historialInfo.razones = historial[0].razones;
      });
      perdidas = false;
    }
    return historial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Textos.textoTilulo(
                        widget.historialInfo.nombre,
                        30,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Textos.textoTilulo(
                          'Fecha: ${widget.historialInfo.fecha}',
                          20,
                        ),
                        Textos.textoTilulo(
                          'Area: ${widget.historialInfo.nombre}',
                          20,
                        ),
                        Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Textos.textoTilulo(
                              ('$cantidadPerdida'.split('.')[1] == '0')
                                  ? 'Perdidas: $cantidadPerdida'.split('.')[0]
                                  : 'Perdidas: $cantidadPerdida',
                              20,
                            ),
                            Botones.btnSimple(
                              'Ver perdidas',
                              Icons.cookie_rounded,
                              Color(0xFF8A03A9),
                              () => {context.read<Ventanas>().tabla(true)},
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
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 150,
                          child: Consumer<Tablas>(
                            builder: (context, tablas, child) {
                              return Tablas.listaFutura(
                                listaPrincipal,
                                'No hay datos registrados.',
                                'No hay datos registrados.',
                                () => getHistorialInfo(),
                                accionRefresh: () async =>
                                    tablas.datos(await getHistorialInfo()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Botones.layerButton(
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Historial(ruta: widget.ruta),
                ),
              ),
            ),
            Consumer2<Ventanas, VenDatos>(
              builder: (context, ventana, venDatos, child) {
                return Ventanas.ventanaTabla(
                  MediaQuery.of(context).size.height,
                  MediaQuery.of(context).size.width,
                  [
                    '$cantidadPerdida'.split('.')[1] == '0'
                        ? 'Perdidas: $cantidadPerdida'.split('.')[0]
                        : 'Perdidas: $cantidadPerdida',
                  ],
                  [],
                  cantidadPerdida > 0
                      ? Tablas.contenedorInfo(
                          MediaQuery.sizeOf(context).width,
                          [.05, .15, .6],
                          ['#', 'Cantidad perdida', 'Razón de perdida'],
                        )
                      : Textos.textoTilulo('', 30),
                  cantidadPerdida > 0
                      ? ListView.separated(
                          itemCount: widget.historialInfo.cantidades.length,
                          scrollDirection: Axis.vertical,
                          separatorBuilder: (context, index) => Container(
                            height: 2,
                            decoration: BoxDecoration(color: Color(0xFFFDC930)),
                          ),
                          itemBuilder: (context, index) {
                            String cantidad =
                                '${widget.historialInfo.cantidades[index]}';
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
                                  (cantidad.split('.')[1] == '0')
                                      ? cantidad.split('.')[0]
                                      : cantidad,
                                  widget.historialInfo.razones[index],
                                ],
                                [],
                                2,
                                false,
                              ),
                            );
                          },
                        )
                      : Textos.textoTilulo('No hay perdidas registradas', 30),
                  [Botones.btnCirRos('Cerrar', () => ventana.tabla(false))],
                );
              },
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }

  ListView listaPrincipal(List lista) {
    return ListView.separated(
      itemCount: lista[0].movimientos,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        String unidad = '${lista[0].unidades[index]}';
        String entrada = '${lista[0].entradas[index]}';
        String salida = '${lista[0].salidas[index]}';
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [.2, .2, .1, .1, .1, .1],
            [
              lista[0].horasModificacion[index],
              lista[0].usuarioModificacion[index],
              (unidad.split('.')[1] == '0') ? unidad.split('.')[0] : unidad,
              (entrada.split('.')[1] == '0') ? entrada.split('.')[0] : entrada,
              (salida.split('.')[1] == '0') ? salida.split('.')[0] : salida,
              '${lista[0].perdidas[index]}',
            ],
            [],
            1,
            true,
            extra: () => {},
          ),
        );
      },
    );
  }
}
