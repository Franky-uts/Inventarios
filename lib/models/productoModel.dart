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