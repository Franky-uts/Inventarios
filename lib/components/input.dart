import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/textos.dart';

enum Filtros { id, nombre, unidades, tipo, area, fecha }

class CampoTexto with ChangeNotifier {
  static Filtros? seleccionFiltro = Filtros.id;
  static final focusBusqueda = FocusNode();
  static final busquedaTexto = TextEditingController();

  static Widget inputTexto(
    double size,
    IconData? icono,
    String texto,
    TextEditingController controller,
    Color errorColor,
    bool enabled,
    bool password,
    Function accion, {
    Color? borderColor,
    EdgeInsets? margin,
    FocusNode? focus,
    TextInputFormatter? formato,
    TextInputType? inputType,
  }) {
    Icon? icon;
    if (icono != null) {
      icon = Icon(icono);
    }
    return Container(
      width: size,
      margin: margin,
      child: TextField(
        controller: controller,
        inputFormatters: [?formato],
        keyboardType: inputType,
        focusNode: focus,
        onSubmitted: (event) => accion(),
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        enabled: enabled,
        obscureText: password,
        cursorColor: Color(0xFF8A03A9),
        style: TextStyle(color: Color(0xFF8A03A9)),
        decoration: InputDecoration(
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: borderColor ?? Color(0xFFFDC930),
              width: 3.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: borderColor ?? Color(0xFFFDC930),
              width: 3.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: borderColor ?? Color(0xFFFDC930),
              width: 2.5,
            ),
          ),
          prefixIcon: icon,
          prefixIconColor: Color(0xFF8A03A9),
          suffixIcon: Icon(Icons.warning_rounded),
          suffixIconColor: errorColor,
          fillColor: Colors.white,
          label: Text(texto, style: TextStyle(color: Color(0xFF8A03A9))),
        ),
      ),
    );
  }

  static Widget inputDropdown(
    double sizeTotal,
    IconData icono,
    String valorActual,
    List<String> lista,
    Color color,
    Function accion,
  ) {
    return Container(
      width: sizeTotal * .365,
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFFDC930), width: 2.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icono, color: Color(0xFF8A03A9)),
          Container(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
            width: sizeTotal * .276,
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                elevation: 1,
                alignment: AlignmentGeometry.centerLeft,
                value: valorActual,
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                dropdownColor: Colors.white,
                items: lista.map<DropdownMenuItem>((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: SizedBox(
                      width: sizeTotal * .223,
                      child: Textos.textoGeneral(value, 0, true, false, 1),
                    ),
                  );
                }).toList(),
                onChanged: (value) => {accion(value)},
              ),
            ),
          ),
          Icon(Icons.warning_rounded, color: color),
        ],
      ),
    );
  }

  static Widget barraBusqueda(Function accion, bool unidades, bool fecha) {
    return TextField(
      controller: busquedaTexto,
      focusNode: focusBusqueda,
      cursorColor: Color(0xFF8A03A9),
      onSubmitted: (event) => {accion()},
      onTapOutside: (event) => {
        if (busquedaTexto.text.isNotEmpty) {accion()},
        FocusManager.instance.primaryFocus?.unfocus(),
      },
      style: TextStyle(color: Color(0xFF8A03A9)),
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
          child: botonBusqueda(() => accion()),
        ),
        prefixIcon: PopupMenuButton<Filtros>(
          icon: Icon(Icons.filter_list_rounded, color: Color(0xFF8A03A9)),
          initialValue: seleccionFiltro,
          color: Colors.white,
          onSelected: (Filtros filtro) => {
            if (filtro != seleccionFiltro) {seleccionFiltro = filtro, accion()},
          },
          tooltip: "Filtros",
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Filtros>>[
            PopupMenuItem<Filtros>(
              value: Filtros.id,
              child: Textos.textoGeneral("ID", 17.5, true, true, 1),
            ),
            PopupMenuItem<Filtros>(
              value: Filtros.nombre,
              child: Textos.textoGeneral("Nombre", 17.5, true, true, 1),
            ),
            PopupMenuItem<Filtros>(
              value: Filtros.tipo,
              child: Textos.textoGeneral("Tipo", 17.5, true, true, 1),
            ),
            PopupMenuItem<Filtros>(
              value: Filtros.area,
              child: Textos.textoGeneral("Área", 17.5, true, true, 1),
            ),
            if (unidades)
              PopupMenuItem<Filtros>(
                value: Filtros.unidades,
                child: Textos.textoGeneral("Unidades", 17.5, true, true, 1),
              ),
            if (fecha)
              PopupMenuItem<Filtros>(
                value: Filtros.fecha,
                child: Textos.textoGeneral("Fecha", 17.5, true, true, 1),
              ),
          ],
        ),
        hintText: "Buscar",
        hintStyle: TextStyle(color: Color(0xFFF6AFCF)),
      ),
    );
  }

  static IconButton botonBusqueda(Function accion) {
    IconButton iconb;
    if (busquedaTexto.text.isEmpty) {
      iconb = IconButton(
        tooltip: "Buscar",
        onPressed: () => {
          if (busquedaTexto.text.isEmpty)
            {
              if (!focusBusqueda.hasFocus)
                {
                  FocusManager.instance.primaryFocus?.requestFocus(
                    focusBusqueda,
                  ),
                },
            }
          else
            {FocusManager.instance.primaryFocus?.unfocus(), accion()},
        },
        icon: Icon(Icons.search, color: Color(0xFF8A03A9)),
      );
    } else {
      iconb = IconButton(
        tooltip: "Limpiar busqueda",
        onPressed: () => {
          FocusManager.instance.primaryFocus?.unfocus(),
          busquedaTexto.clear(),
          accion(),
        },
        icon: Icon(Icons.close_rounded, color: Color(0xFF8A03A9)),
      );
    }
    return iconb;
  }

  void setBusqueda(String busqueda) {
    busquedaTexto.text = busqueda;
  }

  static String filtroTexto(bool idProducto) {
    String filtro;
    switch (seleccionFiltro) {
      case (Filtros.id):
        filtro = "id";
        if (idProducto) {
          filtro = "idProducto";
        }
        break;
      case (Filtros.nombre):
        filtro = "Nombre";
        break;
      case (Filtros.unidades):
        filtro = "Unidades";
        break;
      case (Filtros.tipo):
        filtro = "Tipo";
        break;
      case (Filtros.area):
        filtro = "Area";
        break;
      case (Filtros.fecha):
        filtro = "Fecha";
        break;
      default:
        filtro = "id";
        break;
    }
    return filtro;
  }
}
