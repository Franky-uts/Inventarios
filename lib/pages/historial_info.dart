import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/historial_model.dart';
import 'package:provider/provider.dart';
import '../components/textos.dart';

class HistorialInfo extends StatefulWidget {
  final HistorialModel historialInfo;

  const HistorialInfo({super.key, required this.historialInfo});

  @override
  State<HistorialInfo> createState() => _HistorialInfoState();
}

class _HistorialInfoState extends State<HistorialInfo> {
  double cantidadPerdida = 0;
  bool perdidas = true;

  @override
  void initState() {
    widget.historialInfo.perdidas.add(0);
    super.initState();
  }

  Future<List<HistorialModel>> getHistorialInfo() async {
    List<HistorialModel> historial = await HistorialModel.getHistorialInfo(
      widget.historialInfo.id,
      widget.historialInfo.fecha,
    );
    if (perdidas) {
      for (var registro in historial[0].cantidades) {
        cantidadPerdida += registro;
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
                              () => context.read<Ventanas>().tabla(true),
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
            Botones.layerButton(() => Navigator.pop(context)),
            Consumer2<Ventanas, VenDatos>(
              builder: (context, ventana, venDatos, child) {
                return Ventanas.ventanaTabla(
                  MediaQuery.of(context).size.height,
                  MediaQuery.of(context).size.width,
                  [
                    ('$cantidadPerdida'.split('.').length > 1)
                        ? ('$cantidadPerdida'.split('.')[1] == '0')
                              ? 'Perdidas: $cantidadPerdida'.split('.')[0]
                              : 'Perdidas: $cantidadPerdida'
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
                                  (cantidad.split('.').length > 1)
                                      ? (cantidad.split('.')[1] == '0')
                                            ? cantidad.split('.')[0]
                                            : cantidad
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

  ListView listaPrincipal(List lista, ScrollController controller) {
    return ListView.separated(
      controller: controller,
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
