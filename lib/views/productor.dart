import 'package:flutter/material.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/historial_ordenes.dart';
import 'package:inventarios/pages/inventario_prod.dart';
import 'package:inventarios/pages/orden_salida_prod.dart';
import 'package:provider/provider.dart';

class Productor extends StatefulWidget {
  final int index;

  const Productor({super.key, required this.index});

  @override
  State<Productor> createState() => _ProductorState();
}

class _ProductorState extends State<Productor> {
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
                      await ProductoModel.getProductosProd('id', '');
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
              Botones.botonBarNav('Almacen', Icons.inventory_rounded, () => {}),
              Botones.botonBarNav(
                'Nueva Orden',
                Icons.add_shopping_cart_rounded,
                () => {},
              ),
              Botones.botonBarNav('Ordenes', Icons.history_rounded, () => {}),
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
        InventarioProd(),
        OrdenSalidaProd(),
        HistorialOrdenes(),
      ][currentPage],
    );
  }
}
