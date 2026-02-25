import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/pages/articulos.dart';
import 'package:inventarios/pages/historial.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:inventarios/pages/ordenes.dart';
import 'package:provider/provider.dart';

import '../components/carga.dart';

class Proveedor extends StatefulWidget {
  final int index;

  const Proveedor({super.key, required this.index});

  @override
  State<Proveedor> createState() => _ProveedorState();
}

class _ProveedorState extends State<Proveedor> {
  late int currentPage = widget.index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Consumer<Carga>(
        builder: (ctx, carga, child) {
          return NavigationBar(
            height: 55,
            onDestinationSelected: (int index) async {
              if (Carga.getValido()) {
                carga.cargaBool(true);
                setState(() {
                  currentPage = index;
                });
              } else {
                Textos.toast('Espera a que los datos carguen.', false);
              }
              if (context.mounted) context.read<Carga>().cargaBool(false);
            },
            selectedIndex: currentPage,
            destinations: [
              Botones.botonBarNav(
                'Ordenes',
                Icons.border_color_rounded,
                () => {},
              ),
              Botones.botonBarNav(
                'Almacen',
                Icons.inventory_rounded,
                () => {
                  if (CampoTexto.seleccionFiltro == Filtros.fecha)
                    CampoTexto.seleccionFiltro = Filtros.id,
                },
              ),
              Botones.botonBarNav(
                'Artículos',
                Icons.list,
                () => {
                  if (CampoTexto.seleccionFiltro == Filtros.unidades ||
                      CampoTexto.seleccionFiltro == Filtros.fecha)
                    CampoTexto.seleccionFiltro = Filtros.id,
                },
              ),
              Botones.botonBarNav(
                'Movimientos',
                Icons.history_toggle_off_rounded,
                () => {
                  if (CampoTexto.seleccionFiltro == Filtros.unidades)
                    CampoTexto.seleccionFiltro = Filtros.id,
                },
              ),
            ],
            indicatorColor: Color(0xFFFF5600),
            labelTextStyle: WidgetStateProperty<TextStyle>.fromMap(
              <WidgetStatesConstraint, TextStyle>{
                WidgetState.selected: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFFF5600),
                ),
                WidgetState.hovered: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF8A03A9),
                ),
                WidgetState.any: TextStyle(color: Color(0xFF8A03A9)),
              },
            ),
            backgroundColor: Colors.white,
          );
        },
      ),
      body: const [
        Ordenes(),
        Inventario(),
        Articulos(),
        Historial(),
      ][currentPage],
    );
  }
}
