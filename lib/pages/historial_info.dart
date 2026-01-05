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

  @override
  void initState() {
    for (int i = 0; i < widget.historialInfo.cantidades.length; i++) {
      cantidadPerdida += widget.historialInfo.cantidades[i];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Consumer<Carga>(
              builder: (context, carga, child) {
                return SingleChildScrollView(
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
                              "Fecha: ${widget.historialInfo.fecha}",
                              20,
                            ),
                            Textos.textoTilulo(
                              "Area: ${widget.historialInfo.nombre}",
                              20,
                            ),
                            Row(
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Textos.textoTilulo(
                                  "Perdidas: $cantidadPerdida".split(".0")[0],
                                  20,
                                ),
                                Botones.btnSimple(
                                  "Ver perdidas",
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
                                "Hora",
                                "Usuario",
                                "Unidades",
                                "Entradas",
                                "Salidas",
                                "Perdidas",
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height - 150,
                              child: ListView.separated(
                                itemCount: widget.historialInfo.unidades.length,
                                scrollDirection: Axis.vertical,
                                separatorBuilder: (context, index) => Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFDC930),
                                  ),
                                ),
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    child: Tablas.barraDatos(
                                      MediaQuery.sizeOf(context).width,
                                      [.2, .2, .1, .1, .1, .1],
                                      [
                                        widget
                                            .historialInfo
                                            .horasModificacion[index],
                                        widget
                                            .historialInfo
                                            .usuarioModificacion[index],
                                        "${widget.historialInfo.unidades[index]}"
                                            .split(".0")[0],
                                        "${widget.historialInfo.entradas[index]}",
                                        "${widget.historialInfo.salidas[index]}",
                                        "${widget.historialInfo.perdidas[index]}",
                                      ],
                                      [],
                                      1,
                                      true,
                                      extra: () => {},
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                  ["Perdidas: ${widget.historialInfo.perdidas.last}"],
                  [],
                  widget.historialInfo.perdidas.last > 0
                      ? Tablas.contenedorInfo(
                          MediaQuery.sizeOf(context).width,
                          [.05, .15, .6],
                          ["#", "Cantidad perdida", "Razón de perdida"],
                        )
                      : Textos.textoTilulo("", 30),
                  widget.historialInfo.perdidas.last > 0
                      ? ListView.separated(
                          itemCount: widget.historialInfo.perdidas.last,
                          scrollDirection: Axis.vertical,
                          separatorBuilder: (context, index) => Container(
                            height: 2,
                            decoration: BoxDecoration(color: Color(0xFFFDC930)),
                          ),
                          itemBuilder: (context, index) {
                            return Container(
                              width: MediaQuery.sizeOf(context).width,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                              ),
                              child: Tablas.barraDatos(
                                MediaQuery.sizeOf(context).width,
                                [.05, .15, .6],
                                [
                                  "${index + 1}",
                                  "${widget.historialInfo.cantidades[index]}",
                                  widget.historialInfo.razones[index],
                                ],
                                [],
                                1,
                                false,
                              ),
                            );
                          },
                        )
                      : Textos.textoTilulo("No hay perdidas registradas", 30),
                  [Botones.btnCirRos("Cerrar", () => ventana.tabla(false))],
                );
              },
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }
}
