import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:inventarios/pages/inventario.dart';

class Producto extends StatefulWidget {
  final ProductoModel productoInfo;

  //final String url;

  const Producto({
    super.key,
    required this.productoInfo /*, required this.url*/,
  });

  @override
  State<Producto> createState() => _ProductoState();
}

class _ProductoState extends State<Producto> {
  late int cajasEntrantes = widget.productoInfo.entrada,
      cajasSalida = widget.productoInfo.salida,
      productosPerdido = widget.productoInfo.perdida;

  get textovalor => null;

  @override
  void initState() {
    print(widget.productoInfo.ultimaModificacion);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future guardarDatos(String columna, int dato) async {
    return await http.put(
      Uri.parse(
        "http://192.168.1.179:4000/almacen/${widget.productoInfo.id}/$columna",
      ),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
      body: jsonEncode(<String, int>{'dato': dato}),
    );
  }

  Future enviarDatos(int valor) async {
    switch (valor) {
      case 1:
        if (cajasEntrantes > widget.productoInfo.entrada) {
          final int unidades =
              (cajasEntrantes - widget.productoInfo.entrada) +
              widget.productoInfo.unidades;
          guardarDatos("Unidades", unidades);
          guardarDatos("Entrada", (cajasEntrantes));
          setState(() {
            widget.productoInfo.unidades = unidades;
            widget.productoInfo.entrada = cajasEntrantes;
          });
          //ProductoModel.getProductos(widget.url);
        } else {
          toast("No hay cambios");
        }
        break;
      case 2:
        if (cajasSalida > widget.productoInfo.salida) {
          final int unidades =
              widget.productoInfo.unidades -
              (cajasSalida - widget.productoInfo.salida);
          guardarDatos("Unidades", unidades);
          guardarDatos("Salida", (cajasSalida));
          setState(() {
            widget.productoInfo.unidades = unidades;
            widget.productoInfo.salida = cajasSalida;
          });
          //ProductoModel.getProductos(widget.url);
        } else {
          toast("No hay cambios");
        }
        break;
      case 3:
        if (productosPerdido > widget.productoInfo.perdida) {
          guardarDatos("Perdida", (productosPerdido));
          setState(() {
            widget.productoInfo.perdida = productosPerdido;
          });
          //ProductoModel.getProductos(widget.url);
        } else {
          toast("No hay cambios");
        }
        break;
    }
  }

  void toast(String texto) {
    Fluttertoast.showToast(
      msg: texto,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 15,
    );
  }

  void cambioCajasEntrantes(int num) {
    if ((cajasEntrantes + num) >= widget.productoInfo.entrada) {
      cajasEntrantes += num;
    } else {
      if (cajasEntrantes + num >= 0) {
        toast("El valor ya esta registrado.");
      } else {
        toast("El valor no puede ser menor a 0.");
      }
    }
  }

  void cambioProductoSalida(int num) {
    if ((cajasSalida + num - widget.productoInfo.salida) <=
        widget.productoInfo.unidades) {
      if ((cajasSalida + num) >= 0) {
        if ((cajasSalida + num) >= widget.productoInfo.salida) {
          cajasSalida += num;
        } else {
          toast("El valor ya esta registrado.");
        }
      } else {
        toast("El valor no puede ser menor a 0.");
      }
    } else {
      toast("Ya son todos los productos.");
    }
  }

  void cambioProductoPerdido(int num) {
    if ((productosPerdido + num) >= widget.productoInfo.perdida) {
      productosPerdido += num;
    } else {
      if (productosPerdido + num >= 0) {
        toast("El valor ya esta registrado.");
      } else {
        toast("El valor no puede ser menor a 0.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Inventario()),
          );
        },
        elevation: 0,
        backgroundColor: Colors.grey,
        tooltip: "Guardar información del producto.",
        child: Icon(Icons.arrow_back_rounded, color: Colors.white),
      ),
      body: PopScope(
        canPop: false,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.productoInfo.nombre,
                style: TextStyle(color: Colors.black, fontSize: 30),
              ),
              contenedorInfo(
                "Unidades:",
                widget.productoInfo.unidades.toString(),
              ),
              contenedorInfo(
                "Cajas que entraron:",
                widget.productoInfo.entrada.toString(),
              ),
              contenedorInfo(
                "Cajas que salieron:",
                widget.productoInfo.salida.toString(),
              ),
              contenedorInfo(
                "Productos perdidos:",
                widget.productoInfo.perdida.toString(),
              ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .45,
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Ultima modificación", style: TextStyle(fontSize: 15, color: Colors.grey)),
                  Container(
                    width: MediaQuery.of(context).size.width * .1,
                    height: 1,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  Text(widget.productoInfo.ultimaModificacion, style: TextStyle(fontSize: 15, color: Colors.grey)),
                ],
              ),
            ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    botonesAccion("Cajas entrantes", cajasEntrantes, 1),
                    botonesAccion("Salida de producto", cajasSalida, 2),
                    botonesAccion("Producto perdido", productosPerdido, 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox contenedorInfo(String textoInfo, String textoValor) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .55,
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(textoInfo, style: TextStyle(fontSize: 20)),
          Container(
            width: MediaQuery.of(context).size.width * .25,
            height: 1,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
          ),
          Text(textoValor.toString(), style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Column botonesAccion(String textoInfo, int textoValor, int tipo) {
    return Column(
      children: [
        Text(textoInfo, style: TextStyle(fontSize: 20)),
        Row(
          children: [
            IconButton(
              onPressed: () {
                switch (tipo) {
                  case 1:
                    setState(() {
                      cambioCajasEntrantes(-1);
                    });
                    break;
                  case 2:
                    setState(() {
                      cambioProductoSalida(-1);
                    });
                    break;
                  case 3:
                    setState(() {
                      cambioProductoPerdido(-1);
                    });
                    break;
                }
              },
              icon: Icon(Icons.remove, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                textoValor.toString(),
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            IconButton(
              onPressed: () {
                switch (tipo) {
                  case 1:
                    setState(() {
                      cambioCajasEntrantes(1);
                    });
                    break;
                  case 2:
                    setState(() {
                      cambioProductoSalida(1);
                    });
                    break;
                  case 3:
                    setState(() {
                      cambioProductoPerdido(1);
                    });
                    break;
                }
              },
              icon: Icon(Icons.add, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () {
            enviarDatos(tipo);
          },
          style: IconButton.styleFrom(backgroundColor: Colors.black),
          label: Text(
            "Guardar",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          icon: Icon(Icons.save_rounded, size: 20, color: Colors.white),
        ),
      ],
    );
  }
}
