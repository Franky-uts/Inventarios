import 'package:flutter/material.dart';
import 'dart:async';
import 'package:inventarios/models/productoModel.dart';
import 'package:inventarios/pages/producto.dart';

enum Filtros { id, nombre, tipo, area }

class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  Filtros? seleccionFiltro;
  String busqueda = "";
  List<ProductoModel> productos = [];
  final busquedaTexto = TextEditingController();
  final focusBusqueda = FocusNode();

  Future<void> _getProductos() async {
    productos = await ProductoModel.getProductos(url());
  }

  String url() {
    if (busqueda.isEmpty) {
      return "http://192.168.1.179:4000/productos/${filtroTexto()}";
    } else {
      return "http://192.168.1.179:4000/productos/${filtroTexto()}/$busqueda";
    }
  }

  String filtroTexto() {
    String filtro;
    switch (seleccionFiltro) {
      case (Filtros.id):
        filtro = "id";
        break;
      case (Filtros.nombre):
        filtro = "Nombre";
        break;
      case (Filtros.tipo):
        filtro = "Tipo";
        break;
      case (Filtros.area):
        filtro = "Area";
        break;
      default:
        filtro = "id";
        break;
    }
    return filtro;
  }

  @override
  void initState() {
    super.initState();
    seleccionFiltro = Filtros.id;
    _getProductos();
  }

  @override
  void dispose() {
    _getProductos();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        child: Column(
          children: [
            barraDeBusqueda(),
            contenedorInfo(),
            Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 97,
                  child: listaFutura(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        "Inventario",
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      leading: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.grey),
        child: Icon(Icons.menu_rounded, size: 30),
      ),
    );
  }

  Container barraDeBusqueda() {
    return Container(
      margin: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      child: (TextField(
        controller: busquedaTexto,
        focusNode: focusBusqueda,
        onChanged: (event) {
          busqueda = busquedaTexto.text;
        },
        onSubmitted: (event) {
          setState(() {
            busqueda = busquedaTexto.text;
            _getProductos();
          });
        },
        onTapOutside: (event) {
          setState(() {
            busqueda = busquedaTexto.text;
            _getProductos();
          });
          FocusManager.instance.primaryFocus?.unfocus();
        },
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          fillColor: Colors.white,
          suffixIcon: Container(
            margin: EdgeInsets.only(right: 5),
            child: botonBusqueda(),
          ),
          prefixIcon: PopupMenuButton<Filtros>(
            icon: Icon(Icons.filter_list_rounded),
            initialValue: seleccionFiltro,
            onSelected: (Filtros filtro) {
              setState(() {
                seleccionFiltro = filtro;
                _getProductos();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Filtros>>[
              PopupMenuItem<Filtros>(value: Filtros.id, child: Text("id")),
              PopupMenuItem<Filtros>(
                value: Filtros.nombre,
                child: Text("Nombre"),
              ),
              PopupMenuItem<Filtros>(value: Filtros.tipo, child: Text("Tipo")),
              PopupMenuItem<Filtros>(value: Filtros.area, child: Text("Área")),
            ],
          ),
          hintText: "Buscar",
          hintStyle: TextStyle(color: Colors.grey),
        ),
      )),
    );
  }

  Container contenedorInfo() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(color: Colors.grey),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _barraSuperior(.05, "id"),
          _divider(),
          _barraSuperior(0.225, "Nombre"),
          _divider(),
          _barraSuperior(.15, "Tipo"),
          _divider(),
          _barraSuperior(.06, "Indiv."),
          _divider(),
          _barraSuperior(.06, "Total"),
          _divider(),
          _barraSuperior(.15, "Área"),
          _divider(),
          _barraSuperior(.075, "Entradas"),
          _divider(),
          _barraSuperior(.075, "Salidas"),
          _divider(),
          _barraSuperior(.075, "Perdias"),
        ],
      ),
    );
  }

  VerticalDivider _divider() {
    return VerticalDivider(
      thickness: 1,
      width: 0,
      color: Colors.grey,
      indent: 5,
      endIndent: 5,
    );
  }

  Widget _barraDato(
    double grosor,
    String texto,
    TextAlign alineamiento,
    double tamanoFuente,
  ) => Container(
    width: MediaQuery.sizeOf(context).width * grosor,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      texto,
      textAlign: alineamiento,
      style: TextStyle(color: Colors.black, fontSize: tamanoFuente),
    ),
  );

  SizedBox _barraSuperior(double grosor, String texto) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * grosor,
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  ListView listaPrincipal(List lista) {
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) =>
          Container(height: 2, decoration: BoxDecoration(color: Colors.grey)),
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: 40,
          decoration: BoxDecoration(color: Colors.white54),
          child: TextButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Producto(productoInfo: lista[index], url: url()),
                ),
              ),
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(0),
              shape: ContinuousRectangleBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _barraDato(
                  .05,
                  lista[index].id.toString(),
                  TextAlign.center,
                  20,
                ),
                _divider(),
                _barraDato(.225, lista[index].nombre, TextAlign.center, 20),
                _divider(),
                _barraDato(.15, lista[index].tipo, TextAlign.center, 20),
                _divider(),
                _barraDato(
                  .06,
                  lista[index].unidades.toString(),
                  TextAlign.center,
                  20,
                ),
                _divider(),
                _barraDato(.15, lista[index].area, TextAlign.center, 20),
                _divider(),
                _barraDato(
                  .075,
                  lista[index].entrada.toString(),
                  TextAlign.center,
                  20,
                ),
                _divider(),
                _barraDato(
                  .075,
                  lista[index].salida.toString(),
                  TextAlign.center,
                  20,
                ),
                _divider(),
                _barraDato(
                  .075,
                  lista[index].perdida.toString(),
                  TextAlign.center,
                  20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  FutureBuilder listaFutura() {
    return FutureBuilder(
      future: ProductoModel.getProductos(url()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return listaPrincipal(productos);
        } else {
          if (busqueda.isNotEmpty) {
            return Center(child: Text("No hay coincidencias."));
          } else {
            //return Center(child: CircularProgressIndicator());
            return listaPrincipal(ProductoModel.listaProvicional());
          }
        }
      },
    );
  }

  IconButton botonBusqueda() {
    if (busquedaTexto.text.isEmpty) {
      return IconButton(
        onPressed: () {
          if (busquedaTexto.text.isEmpty) {
            focusBusqueda.requestFocus();
          } else {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() {
              busqueda = busquedaTexto.text;
              _getProductos();
            });
          }
        },
        icon: Icon(Icons.search),
      );
    } else {
      return IconButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            busquedaTexto.text = "";
            busqueda = "";
          });
          _getProductos();
        },
        icon: Icon(Icons.close_rounded),
      );
    }
  }
}
