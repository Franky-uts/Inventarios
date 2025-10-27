import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:inventarios/models/usuario_model.dart';
import '../models/producto_model.dart';

enum Filtros { id, nombre, tipo, area }

class OrdenSalida extends StatefulWidget {
  final UsuarioModel usuario;
  final String busqueda;

  const OrdenSalida({super.key, required this.usuario, required this.busqueda});

  @override
  State<OrdenSalida> createState() => _OrdenSalidaState();
}

class _OrdenSalidaState extends State<OrdenSalida> {
  static Filtros? seleccionFiltro;
  static List<ProductoModel> productos = [];
  final busquedaTexto = TextEditingController();
  final focusBusqueda = FocusNode();
  late bool carga;
  late bool valido;
  late bool lista;
  late List<int> cantidad = [];
  late List<int> color = [];
  Timer? timer;

  @override
  void initState() {
    busquedaTexto.text = widget.busqueda;
    carga = false;
    valido = false;
    lista = true;
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _getProductos() async {
    productos = await ProductoModel.getProductos(url());
  }

  void listas(int length) {
    if (lista) {
      for (int i = 0; i < length; i++) {
        cantidad.add(0);
        color.add(0xFF000000);
      }
      lista = false;
    }
  }

  String url() {
    if (busquedaTexto.text.isEmpty) {
      return "http://192.168.1.130:4000/inventario/${widget.usuario.locacion}/${filtroTexto()}";
    } else {
      return "http://192.168.1.130:4000/inventario/${widget.usuario.locacion}/${filtroTexto()}/${busquedaTexto.text}";
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                barraDeBusqueda(context),
                contenedorInfo(),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 97,
                  child: listaFutura(),
                ),
              ],
            ),
            Visibility(
              visible: carga,
              child: Container(
                decoration: BoxDecoration(color: Colors.black45),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  VerticalDivider _divider() {
    return VerticalDivider(
      thickness: 1,
      width: 0,
      color: Colors.grey,
      indent: 5,
      endIndent: 5,
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
          _barraSuperior(0.25, "Nombre"),
          _divider(),
          _barraSuperior(.175, "Tipo"),
          _divider(),
          _barraSuperior(.08, "Unidades"),
          _divider(),
          _barraSuperior(.2, "Acciones"),
        ],
      ),
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

  Widget barraDeBusqueda(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Inventario(
                  usuario: widget.usuario,
                  busqueda: busquedaTexto.text,
                ),
              ),
            );
          },
          icon: Icon(Icons.arrow_back_rounded, size: 35),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        IconButton.filled(
          onPressed: () {
            for(int i=0;i<cantidad.length;i++){
              if(cantidad[i]!=0){
                print(i);
              }
            }
          },
          icon: Icon(Icons.task_rounded, size: 35),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * .8,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: TextField(
            controller: busquedaTexto,
            focusNode: focusBusqueda,
            onSubmitted: (event) {
              _getProductos();
            },
            onTapOutside: (event) {
              if (busquedaTexto.text.isNotEmpty) {
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
    if (busquedaTexto.text.isEmpty) {
      return IconButton(
        onPressed: () {
          if (busquedaTexto.text.isEmpty) {
            focusBusqueda.requestFocus();
          } else {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() {
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
            busquedaTexto.clear();
          });
          _getProductos();
        },
        icon: Icon(Icons.close_rounded),
      );
    }
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
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(),
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
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * .2,
                  child: botones(
                    cantidad[lista[index].id - 1],
                    0,
                    color[lista[index].id - 1],
                    lista[index].id,
                  ),
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
            listas(snapshot.data.length);
            valido = true;
            productos = snapshot.data;
            if (productos.isNotEmpty) {
              if (productos[0].nombre == "Error") {
                return Center(child: Text(productos[0].tipo));
              } else {
                return listaPrincipal(productos);
              }
            } else {
              return Center(child: Text("No hay productos registrados."));
            }
          } else if (snapshot.hasError) {
            valido = false;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Error:"), Text(snapshot.error.toString())],
              ),
            );
          } else {
            if (busquedaTexto.text.isNotEmpty) {
              return Center(child: Text("No hay coincidencias."));
            }
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Row botones(int textoValor, int tipo, int colorBorde, int id) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            if((cantidad[id - 1]-1)>-1){
              setState(() {
                color[id-1] = 0xFF000000;
                cantidad[id - 1] -= 1;
              });
            }else{
              setState(() {
                color[id-1] = 0xFFFF0000;
              });
            }
          },
          icon: Icon(Icons.remove, color: Colors.white),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Color(colorBorde), width: 2.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            textoValor.toString(),
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              color[id-1] = 0xFF000000;
              cantidad[id - 1] += 1;
            });
          },
          icon: Icon(Icons.add, color: Colors.white),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
