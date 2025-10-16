import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductoModel {
  int id;
  String nombre;
  String tipo;
  int unidades;
  String ultimaModificacion;
  int cantidadPorUnidad;
  String area;
  int entrada;
  int salida;
  int perdida;
  String ultimoUsuario;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.unidades,
    required this.ultimaModificacion,
    required this.cantidadPorUnidad,
    required this.area,
    required this.entrada,
    required this.salida,
    required this.perdida,
    required this.ultimoUsuario,
  });

  static List<ProductoModel> listaProvicional() {
    List<ProductoModel> productos = [];

    productos.add(
      ProductoModel(
        id: 1,
        nombre: "Producto 1",
        tipo: "Tipo 1",
        unidades: 12,
        ultimaModificacion: "Lun 15/09 10:30pm",
        cantidadPorUnidad: 2,
        area: "Area 1",
        entrada: 0,
        salida: 0,
        perdida: 0,
        ultimoUsuario: "usuario",
      ),
    );

    productos.add(
      ProductoModel(
        id: 2,
        nombre: "Producto 2",
        tipo: "Tipo 2",
        unidades: 21,
        ultimaModificacion: "Dom 26/09 3:10am",
        cantidadPorUnidad: 20,
        area: "Area 1",
        entrada: 0,
        salida: 0,
        perdida: 0,
        ultimoUsuario: "usuario",
      ),
    );

    return productos;
  }

  static Future<List<ProductoModel>> getProductos(String url) async {
    late List<ProductoModel> productosFuture = [];

    var res = await http.get(Uri.parse(url));

    final datos = json.decode(res.body);
    for (var item in datos) {
      productosFuture.add(
        ProductoModel(
          id: item["id"],
          nombre: item["Nombre"].toString(),
          tipo: item["Tipo"].toString(),
          unidades: item["Unidades"],
          ultimaModificacion: item["UltimaModificación"],
          cantidadPorUnidad: item["CantidadPorUnidad"],
          area: item["Area"].toString(),
          entrada: item["Entrada"],
          salida: item["Salida"],
          perdida: item["Perdida"],
          ultimoUsuario: item["UltimoUsuario"],
        ),
      );
    }
    return productosFuture;
  }
}
