import 'package:flutter/material.dart';
import 'dart:async';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/pages/inicio.dart';
import 'package:inventarios/pages/producto.dart';
import 'package:inventarios/services/local_storage.dart';

enum Filtros { id, nombre, tipo, area }

class Inventario extends StatefulWidget {
  final usuarioModel usuario;

  const Inventario({super.key, required this.usuario});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  static Filtros? seleccionFiltro;
  static String busqueda = "";
  static List<ProductoModel> productos = [];
  final busquedaTexto = TextEditingController();
  final focusBusqueda = FocusNode();

  Future<void> _getProductos() async {
    productos = await ProductoModel.getProductos(url());
  }

  Future<void> datosExcel() async{

  }

  String url() {
    if (busqueda.isEmpty) {
      return "http://192.168.1.179:4000/almacen/${filtroTexto()}";
    } else {
      return "http://192.168.1.179:4000/almacen/${filtroTexto()}/$busqueda";
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
    //_getProductos();
    super.initState();
  }

  @override
  void dispose() {
    //_getProductos();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        child: Builder(
          builder: (context) => Column(
            children: [
              barraDeBusqueda(context),
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
      ),
    );
  }

  Drawer drawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Bienvenido, ", style: TextStyle(fontSize: 15)),
                    Text(
                      widget.usuario.nombre,
                      style: TextStyle(fontSize: 30),
                      maxLines: 1,
                    ),
                  ],
                ),
                Text(widget.usuario.puesto, style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          Column(
            spacing: 15,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              TextButton(
                onPressed: () {
                  datosExcel();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  "Descargar reporte",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  "Añadir un producto",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  "Añadir un producto",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await LocalStorage.preferencias.remove('usuario');
                  await LocalStorage.preferencias.remove('puesto');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Inicio()),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(color: Colors.black, width: 5),
                  ),
                ),
                child: Text(
                  "Cerrar sesión",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
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

  Widget barraDeBusqueda(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: Icon(Icons.menu_rounded, size: 35),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * .875,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: TextField(
            controller: busquedaTexto,
            focusNode: focusBusqueda,
            onChanged: (event) {
              busqueda = busquedaTexto.text;
            },
            onSubmitted: (event) {
              busqueda = busquedaTexto.text;
              _getProductos();
            },
            onTapOutside: (event) {
              busqueda = busquedaTexto.text;
              if (busqueda.isNotEmpty) {
                _getProductos();
              }
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
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<Filtros>>[
                      PopupMenuItem<Filtros>(
                        value: Filtros.id,
                        child: Text("id"),
                      ),
                      PopupMenuItem<Filtros>(
                        value: Filtros.nombre,
                        child: Text("Nombre"),
                      ),
                      PopupMenuItem<Filtros>(
                        value: Filtros.tipo,
                        child: Text("Tipo"),
                      ),
                      PopupMenuItem<Filtros>(
                        value: Filtros.area,
                        child: Text("Área"),
                      ),
                    ],
              ),
              hintText: "Buscar",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  IconButton botonBusqueda() {
    if (busqueda.isEmpty) {
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
          _barraSuperior(0.25, "Nombre"),
          _divider(),
          _barraSuperior(.175, "Tipo"),
          _divider(),
          _barraSuperior(.08, "Unidades"),
          _divider(),
          _barraSuperior(.175, "Área"),
          _divider(),
          _barraSuperior(.075, "Entrada"),
          _divider(),
          _barraSuperior(.075, "Salida"),
          _divider(),
          _barraSuperior(.075, "Perdida"),
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
      maxLines: 1,
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
                  builder: (context) => Producto(
                    productoInfo: lista[index],
                    usuario: widget.usuario,
                  ),
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
                _barraDato(.25, lista[index].nombre, TextAlign.center, 20),
                _divider(),
                _barraDato(.175, lista[index].tipo, TextAlign.center, 20),
                _divider(),
                _barraDato(
                  .08,
                  lista[index].unidades.toString(),
                  TextAlign.center,
                  20,
                ),
                _divider(),
                _barraDato(.175, lista[index].area, TextAlign.center, 20),
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
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            productos = snapshot.data;
            if (productos.isNotEmpty) {
              return listaPrincipal(productos);
            } else {
              return Center(child: Text("No hay coincidencias."));
            }
          } else {
            if (busqueda.isNotEmpty) {
              return Center(child: Text("No hay coincidencias."));
            }
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
