import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductoModel{
  int id;
  String nombre;
  String tipo;
  int individual;
  int cajas;
  String ultimaModificacion;
  int cantidadPorCajas;
  String area;
  int entradas;
  int salidas;
  int perdidas;
  int cajasAbiertas;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.individual,
    required this.cajas,
    required this.ultimaModificacion,
    required this.cantidadPorCajas,
    required this.area,
    required this.entradas,
    required this.salidas,
    required this.perdidas,
    required this.cajasAbiertas
  });

  static List<ProductoModel> listaProvicional(){
    List<ProductoModel> Productos = [];

    Productos.add(
        ProductoModel(
          id: 1,
          nombre: "Producto 1",
          tipo: "Tipo 1",
          individual: 12,
          cajas: 10,
          ultimaModificacion: "Lun 15/09 10:30pm",
          cantidadPorCajas: 2,
          area: "Area 1",
          entradas: 0,
          salidas: 0,
          perdidas: 0,
          cajasAbiertas: 0
        )
    );

    Productos.add(
        ProductoModel(
          id: 2,
          nombre: "Producto 2",
          tipo: "Tipo 2",
          individual: 21,
          cajas: 1,
          ultimaModificacion: "Dom 26/09 3:10am",
          cantidadPorCajas: 20,
          area: "Area 1",
          entradas: 0,
          salidas: 0,
          perdidas: 0,
          cajasAbiertas: 0
        )
    );

    return Productos;
  }

  static Future<List<ProductoModel>> getProductos(String url)async{
    late List<ProductoModel> productosFuture = [];

    var res = await http.get(Uri.parse(url));

    final datos = json.decode(res.body);
    for (var item in datos){
      productosFuture.add(
        ProductoModel(
            id: item["id"],
            nombre: item["Nombre"].toString(),
            tipo: item["Tipo"].toString(),
            individual: item["Individual"],
            cajas: item["Cajas"],
            ultimaModificacion: item["UltimaModificacion"].toString(),
            cantidadPorCajas: item["CantidadPorCajas"],
            area: item["Area"].toString(),
            entradas: item["Entradas"],
            salidas: item["Salidas"],
            perdidas: item["Perdidas"],
            cajasAbiertas: item["CajasAbiertas"]
        ),
      );
    }
    return productosFuture;
  }
}