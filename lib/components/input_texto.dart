import 'package:flutter/material.dart';
import 'package:inventarios/models/producto_model.dart';

enum Filtros { id, nombre, tipo, area }

class CampoTexto {
  static Filtros? seleccionFiltro;
  static List<ProductoModel> productos = [];
  static final focusBusqueda = FocusNode();
  static final busquedaTexto = TextEditingController();

  static Widget barraBusqueda(double grosor, {required Function accion}) {
    var contenedor = Container(
      width: grosor,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: busquedaTexto,
        focusNode: focusBusqueda,
        cursorColor: Color(0xFF8F01AF),
        onSubmitted: (event) => {
          //_getProductos();
          accion(),
        },
        onTapOutside: (event) => {
          if (busquedaTexto.text.isNotEmpty)
            {
              //_getProductos();
              accion(),
            },
          FocusManager.instance.primaryFocus?.unfocus(),
        },
        style: TextStyle(color: Color(0xFF8F01AF)),
        decoration: InputDecoration(
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color(0xFFFDC930), width: 2.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color(0xFFFDC930), width: 2.5),
          ),
          fillColor: Colors.white,
          suffixIcon: Container(
            margin: EdgeInsets.only(right: 5),
            child: botonBusqueda(accion: () => accion()),
          ),
          prefixIcon: PopupMenuButton<Filtros>(
            icon: Icon(Icons.filter_list_rounded, color: Color(0xFF8F01AF)),
            initialValue: seleccionFiltro,
            color: Colors.white,
            onSelected: (Filtros filtro) => {
              seleccionFiltro = filtro,
              accion(),
              /*setState(() {
                seleccionFiltro = filtro;
                _getProductos();
              });*/
            },
            tooltip: "Filtros",
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Filtros>>[
              PopupMenuItem<Filtros>(
                value: Filtros.id,
                child: Text(
                  "id",
                  style: TextStyle(fontSize: 17.5, color: Color(0xFF8F01AF)),
                ),
              ),
              PopupMenuItem<Filtros>(
                value: Filtros.nombre,
                child: Text(
                  "Nombre",
                  style: TextStyle(fontSize: 17.5, color: Color(0xFF8F01AF)),
                ),
              ),
              PopupMenuItem<Filtros>(
                value: Filtros.tipo,
                child: Text(
                  "Tipo",
                  style: TextStyle(fontSize: 17.5, color: Color(0xFF8F01AF)),
                ),
              ),
              PopupMenuItem<Filtros>(
                value: Filtros.area,
                child: Text(
                  "Área",
                  style: TextStyle(fontSize: 17.5, color: Color(0xFF8F01AF)),
                ),
              ),
            ],
          ),
          hintText: "Buscar",
          hintStyle: TextStyle(color: Color(0xFFF6AFCF)),
        ),
      ),
    );
    return contenedor;
  }

  static IconButton botonBusqueda({required Function accion}) {
    IconButton iconb;
    if (busquedaTexto.text.isEmpty) {
      iconb = IconButton(
        onPressed: () => {
          if (busquedaTexto.text.isEmpty)
            {focusBusqueda.requestFocus(), accion()}
          else
            {
              FocusManager.instance.primaryFocus?.unfocus(),
              accion(),
              /*setState(() {
              _getProductos();
            });*/
            },
        },
        icon: Icon(Icons.search, color: Color(0xFF8F01AF)),
      );
    } else {
      iconb = IconButton(
        onPressed: () => {
          FocusManager.instance.primaryFocus?.unfocus(),
          busquedaTexto.clear(),
          accion(), //Algo pasa aqui y en los filtros
          /*setState(() {
            busquedaTexto.clear();
          });
          _getProductos();*/
        },
        icon: Icon(Icons.close_rounded, color: Color(0xFF8F01AF)),
      );
    }
    return iconb;
  }

  static String filtroTexto() {
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
}
