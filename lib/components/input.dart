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
    String texto,
    String hint,
    TextEditingController controller,
    bool enabled,
    bool password,
    Function accion, {
    IconData? icono,
    Color? borderColor,
    Color? errorColor,
    double? fontSize,
    double? height,
    TextAlign? align,
    EdgeInsets? margin,
    FocusNode? focus,
    TextInputFormatter? formato,
    TextInputType? inputType,
  }) {
    return Container(
      width: size,
      height: height,
      margin: margin,
      child: TextField(
        controller: controller,
        inputFormatters: [?formato],
        keyboardType: inputType,
        focusNode: focus,
        onTap: () => {
          if (controller.text.isNotEmpty)
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            ),
        },
        onSubmitted: (event) => accion(),
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        enabled: enabled,
        textAlign: align ?? TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        obscureText: password,
        cursorColor: Color(0xFF8A03A9),
        style: TextStyle(
          color: Color(0xFF8A03A9),
          fontSize: fontSize,
          textBaseline: TextBaseline.ideographic,
        ),
        decoration: InputDecoration(
          filled: true,
          hintText: hint,
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
              color: borderColor ?? Color(0xFFFEE497),
              width: 2.5,
            ),
          ),
          prefixIcon: icono != null ? Icon(icono) : null,
          prefixIconColor: Color(0xFF8A03A9),
          suffixIcon: errorColor != null ? Icon(Icons.warning_rounded) : null,
          suffixIconColor: errorColor,
          fillColor: Colors.white,
          label: Text(texto, style: TextStyle(color: Color(0xFF8A03A9))),
          floatingLabelBehavior: hint.isEmpty
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.always,
          floatingLabelAlignment: align == TextAlign.center
              ? FloatingLabelAlignment.center
              : FloatingLabelAlignment.start,
        ),
      ),
    );
  }

  static Widget inputDropdown(
    double sizeTotal,
    IconData icono,
    String valorActual,
    List<String> lista,
    Color colorWarning,
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
                      child: Textos.textoGeneral(value, true, 1),
                    ),
                  );
                }).toList(),
                onChanged: (value) => accion(value),
              ),
            ),
          ),
          Icon(Icons.warning_rounded, color: colorWarning),
        ],
      ),
    );
  }

  static Widget barraBusqueda(Function accion, bool unidades, bool fecha) {
    return TextField(
      controller: busquedaTexto,
      focusNode: focusBusqueda,
      cursorColor: Color(0xFF8A03A9),
      onChanged: (event) => accion(),
      onTapOutside: (event) => {
        if (busquedaTexto.text.isNotEmpty) accion(),
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
            if (filtro != seleccionFiltro) seleccionFiltro = filtro,
            accion(),
          },
          tooltip: 'Filtros',
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Filtros>>[
            PopupMenuItem<Filtros>(
              value: Filtros.id,
              child: Textos.textoGeneral(
                'ID',
                true,
                1,
                size: 17.5,
                alignment: TextAlign.center,
              ),
            ),
            PopupMenuItem<Filtros>(
              value: Filtros.nombre,
              child: Textos.textoGeneral(
                'Nombre',
                true,
                1,
                size: 17.5,
                alignment: TextAlign.center,
              ),
            ),
            PopupMenuItem<Filtros>(
              value: Filtros.tipo,
              child: Textos.textoGeneral(
                'Tipo',
                true,
                1,
                size: 17.5,
                alignment: TextAlign.center,
              ),
            ),
            PopupMenuItem<Filtros>(
              value: Filtros.area,
              child: Textos.textoGeneral(
                'Área',
                true,
                1,
                size: 17.5,
                alignment: TextAlign.center,
              ),
            ),
            if (unidades)
              PopupMenuItem<Filtros>(
                value: Filtros.unidades,
                child: Textos.textoGeneral(
                  'Unidades',
                  true,
                  1,
                  size: 17.5,
                  alignment: TextAlign.center,
                ),
              ),
            if (fecha)
              PopupMenuItem<Filtros>(
                value: Filtros.fecha,
                child: Textos.textoGeneral(
                  'Fecha',
                  true,
                  1,
                  size: 17.5,
                  alignment: TextAlign.center,
                ),
              ),
          ],
        ),
        hintText: 'Buscar',
        hintStyle: TextStyle(color: Color(0xFFF6AFCF)),
      ),
    );
  }

  static IconButton botonBusqueda(Function accion) {
    return (busquedaTexto.text.isEmpty)
        ? IconButton(
            tooltip: 'Buscar',
            onPressed: () => {
              (busquedaTexto.text.isEmpty)
                  ? {
                      if (!focusBusqueda.hasFocus)
                        FocusManager.instance.primaryFocus?.requestFocus(
                          focusBusqueda,
                        ),
                    }
                  : FocusManager.instance.primaryFocus?.unfocus(),
              accion(),
            },
            icon: Icon(Icons.search, color: Color(0xFF8A03A9)),
          )
        : IconButton(
            tooltip: 'Limpiar busqueda',
            onPressed: () => {
              FocusManager.instance.primaryFocus?.unfocus(),
              busquedaTexto.clear(),
              accion(),
            },
            icon: Icon(Icons.close_rounded, color: Color(0xFF8A03A9)),
          );
  }

  static String filtroTexto() {
    switch (seleccionFiltro) {
      case (Filtros.id):
        return 'id';
      case (Filtros.nombre):
        return 'Nombre';
      case (Filtros.unidades):
        return 'Unidades';
      case (Filtros.tipo):
        return 'Tipo';
      case (Filtros.area):
        return 'Area';
      case (Filtros.fecha):
        return 'Fecha';
      default:
        return 'id';
    }
  }
}
