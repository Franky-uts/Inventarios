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

class EmpleadoView extends StatefulWidget {
  final int index;

  const EmpleadoView({super.key, required this.index});

  @override
  State<EmpleadoView> createState() => _EmpleadoViewState();
}

class _EmpleadoViewState extends State<EmpleadoView> {
  late int currentPage = widget.index;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomPadding: true,
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
                  if (productos.last.mensaje == '') {
                    if (context.mounted) {
                      Textos.crearLista(productos.last.id, Color(0xFFFDC930));
                    }
                  } else {
                    Textos.toast(productos.last.mensaje, true);
                  }
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
            //labelTextStyle: TextStyle(),
            backgroundColor: Colors.white,
          );
        },
      ),
      body: [
        Inventario(),
        OrdenSalida(),
        HistorialOrdenes(ruta: EmpleadoView(index: 2)),
        Historial(ruta: EmpleadoView(index: 3)),
      ][currentPage],
    );
  }
}
