import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';

class Ventas extends StatefulWidget {
  const Ventas({super.key});

  @override
  State<Ventas> createState() => _VentasState();
}

class _VentasState extends State<Ventas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Builder(
              builder: (context) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    barraSuperior(context),
                    Column(
                      children: [
                        Tablas.contenedorInfo(
                          MediaQuery.sizeOf(context).width,
                          [.05, .25, .15, .15, .1, .1, .1, .075],
                          [
                            'id',
                            'Nombre',
                            'Área',
                            'Tipo',
                            'Ent. Cont.',
                            'Ent. Paq.',
                            'Ent. Piez.',
                            'Info.',
                          ],
                        ),
                        SizedBox(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget barraSuperior(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Botones.btnRctMor(
            'Abrir menú',
            Icons.menu_rounded,
            false,
            () => Scaffold.of(context).openDrawer(),
            size: 35,
          ),
          Container(
            width: MediaQuery.of(context).size.width * .775,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Consumer2<Tablas, CampoTexto>(
              builder: (context, tablas, campoTexto, child) {
                return CampoTexto.barraBusqueda(() async => {});
              },
            ),
          ),
        ],
      ),
    );
  }

  ListView listaPrincipal(List lista, ScrollController controller) {
    return ListView.separated(
      controller: controller,
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        return Container();
      },
    );
  }
}
