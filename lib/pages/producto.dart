import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inventarios/models/productoModel.dart';
import 'package:inventarios/pages/inventario.dart';

class Producto extends StatefulWidget {
  final ProductoModel productoInfo;
  final String url;

  const Producto({super.key, required this.productoInfo, required this.url});

  @override
  State<Producto> createState() => _ProductoState();
}

class _ProductoState extends State<Producto> {
  late int cajasEntrantes = widget.productoInfo.entrada,
      productosSalida = widget.productoInfo.salida,
      productosPerdido = widget.productoInfo.perdida;

  get textovalor => null;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future guardarDatos(String columna, int dato) async {
    return await http.put(
      Uri.parse(
        "http://192.168.1.179:4000/productos/${widget.productoInfo.id}/cantidad/$columna",
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
      case 2:
        if (cajasEntrantes > widget.productoInfo.entrads) {
          guardarDatos(
            "Cajas",
            (cajasEntrantes - widget.productoInfo.entrada) +
                widget.productoInfo.unidad,
          );
          guardarDatos("Entrada", (cajasEntrantes));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Inventario()),
          );
          ProductoModel.getProductos(widget.url);
        } else {
          toast("No hay cambios");
        }
        break;
      case 3:
        if (productosSalida > widget.productoInfo.salida) {
          guardarDatos(
            "Unidades",
            (widget.productoInfo.unidades -
                productosSalida -
                widget.productoInfo.salida),
          );
          guardarDatos("Salidas", (productosSalida));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Inventario()),
          );
          ProductoModel.getProductos(widget.url);
        } else {
          toast("No hay cambios");
        }
        break;
      case 4:
        if (productosPerdido > widget.productoInfo.perdida) {
          guardarDatos(
            "Unidades",
            (widget.productoInfo.unidades -
                productosPerdido -
                widget.productoInfo.perdida),
          );
          guardarDatos("Perdidas", (productosPerdido));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Inventario()),
          );
          ProductoModel.getProductos(widget.url);
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
    if ((productosSalida +
            num +
            (productosPerdido - widget.productoInfo.perdida) -
            widget.productoInfo.salida) <=
        widget.productoInfo.unidades) {
      if ((productosSalida + num) >= 0) {
        if ((productosSalida + num) >= widget.productoInfo.salida) {
          productosSalida += num;
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
    if ((productosPerdido +
            num +
            (productosSalida - widget.productoInfo.salida) -
            widget.productoInfo.perdida) <=
        widget.productoInfo.unidades) {
      if ((productosPerdido + num) >= 0) {
        if ((productosPerdido + num) >= widget.productoInfo.perdida) {
          productosPerdido += num;
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
                "Cajas entrantes:",
                widget.productoInfo.entrada.toString(),
              ),
              contenedorInfo(
                "Salidas del producto:",
                widget.productoInfo.salida.toString(),
              ),
              contenedorInfo(
                "Productos perdidos:",
                widget.productoInfo.perdida.toString(),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    botonesAccion("Cajas entrantes", cajasEntrantes, 2),
                    botonesAccion("Salida de producto", productosSalida, 3),
                    botonesAccion("Producto perdido", productosPerdido, 4),
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
                  case 2:
                    setState(() {
                      cambioCajasEntrantes(-1);
                    });
                    break;
                  case 3:
                    setState(() {
                      cambioProductoSalida(-1);
                    });
                    break;
                  case 4:
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
                  case 2:
                    setState(() {
                      cambioCajasEntrantes(1);
                    });
                    break;
                  case 3:
                    setState(() {
                      cambioProductoSalida(1);
                    });
                    break;
                  case 4:
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
