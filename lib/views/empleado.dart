import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/historial.dart';
import 'package:inventarios/pages/historial_ordenes.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:inventarios/pages/orden_salida.dart';
import 'package:provider/provider.dart';

class Empleado extends StatefulWidget {
  final int index;

  const Empleado({super.key, required this.index});

  @override
  State<Empleado> createState() => _EmpleadoState();
}

class _EmpleadoState extends State<Empleado> {
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
                Textos.limpiarLista();
                if (index == 1) {
                  CampoTexto.seleccionFiltro = Filtros.id;
                  List<ProductoModel> productos =
                      await ProductoModel.getProductos('id', '');
                  (productos.last.mensaje == '')
                      ? {
                          if (context.mounted)
                            Textos.crearLista(
                              productos.last.id,
                              Color(0xFFFDC930),
                            ),
                        }
                      : {
                          Textos.toast(productos.last.mensaje, true),
                          index = currentPage,
                        };
                }
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
                'Inventario',
                Icons.inventory_rounded,
                () => {
                  if (CampoTexto.seleccionFiltro == Filtros.fecha)
                    CampoTexto.seleccionFiltro = Filtros.id,
                },
              ),
              Botones.botonBarNav(
                'Nueva Orden',
                Icons.add_shopping_cart_rounded,
                () => {},
              ),
              Botones.botonBarNav('Ordenes', Icons.history_rounded, () => {}),
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
      body: [
        Inventario(),
        OrdenSalida(),
        HistorialOrdenes(),
        Historial(),
      ][currentPage],
    );
  }
}
