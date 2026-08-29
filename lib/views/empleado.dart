import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/historial.dart';
import 'package:inventarios/pages/historial_ordenes.dart';
import 'package:inventarios/pages/esp.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:inventarios/pages/orden_salida.dart';
import 'package:provider/provider.dart';

//Visor de páginas principales, dedicada principalmente a los empleados.
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
      bottomNavigationBar: Consumer2<Carga, Ventanas>(
        builder: (ctx, carga, ventana, child) {
          return NavigationBar(
            height: 55,
            onDestinationSelected: (int index) async {
              carga.cargaBool(true);
              ventana.cerrarVentanas();
              if (Carga.getValido()) {
                Textos.limpiarLista();
                CampoTexto.seleccionFiltro = Filtros.id;
                if (index == 2) {
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
                          Textos.toast(productos.last.mensaje),
                          index = currentPage,
                        };
                }
                setState(() {
                  currentPage = index;
                });
              } else {
                Textos.toast('Espera a que los datos carguen.');
              }
              if (context.mounted) context.read<Carga>().cargaBool(false);
            },
            selectedIndex: currentPage,
            destinations: [
              Botones.botonBarNav('Movimientos', Icons.checklist_rtl_rounded),
              Botones.botonBarNav('Inventario', Icons.inventory_rounded),
              Botones.botonBarNav(
                'Nueva Orden',
                Icons.add_shopping_cart_rounded,
              ),
              Botones.botonBarNav('Ordenes', Icons.history_rounded),
              Botones.botonBarNav(
                'Historial',
                Icons.history_toggle_off_rounded,
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
        ESP(),
        Inventario(),
        OrdenSalida(),
        HistorialOrdenes(),
        Historial(),
      ][currentPage],
    );
  }
}
