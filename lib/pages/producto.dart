import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:provider/provider.dart';

//Esta es una página ventana con información relacionada con un producto
//seleccionado de la lista de productos.
class Producto with ChangeNotifier {
  static ProductoModel _prod = ProductoModel.dummy('');
  static double productosPerdido = 0;
  static int ventanaNum = 0;
  static FocusNode focus = FocusNode();
  static bool _producto = false,
      _prov = false,
      _emergente = false,
      _tabla = false;
  static List<Color> color = [
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
    Color(0xFF8A03A9),
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
  ];
  static List<TextEditingController> controllerPerdidas = [
    TextEditingController(),
    TextEditingController(),
  ];
  static List<TextEditingController> controller = [
    TextEditingController(),
    TextEditingController(),
  ];

  //Método que establece el producto que se mostrara.
  void setProducto(ProductoModel producto) {
    _prod = producto;
    productosPerdido = calcularPerdidas(producto.perdidaCantidad);
    notifyListeners();
  }

  //Método que controla el booleano "_producto", este se encarga de la
  //visibilidad de la ventana que muestra el producto.
  void producto(bool boolean) {
    _producto = boolean;
    notifyListeners();
  }

  //Método que controla el booleano "_prov", este se encarga de la
  //visibilidad de la ventana que muestra el producto.
  void prov(bool boolean) {
    _prov = boolean;
    notifyListeners();
  }

  //Método que controla el booleano "_emergente", este se encarga de la
  //visibilidad de la ventana emergente que se maneja en esta clase.
  void emergente(bool boolean) {
    _emergente = boolean;
    notifyListeners();
  }

  //Método que controla el booleano "_tabla", este se encarga de la
  //visibilidad de la ventana emergente que se maneja en esta clase.
  void tabla(bool boolean) {
    _tabla = boolean;
    notifyListeners();
  }

  //Este es un método que se encarga de calcular cuantas perdidas hay
  //registradas en un producto ese día (se reinicia a las 12 am de cada día).
  double calcularPerdidas(List<double> lista) {
    double perdida = 0;
    for (double obj in lista) {
      perdida += obj;
    }
    return perdida;
  }

  //Método que se encarga de regresar un texto correspondiente al tipo de unidad
  //del producto, más en específico transforma el texto del producto a plural o
  //al tipo de producto que almacena.
  String tipoUnidad() {
    String objeto = '${_prod.tipo}s';
    switch (_prod.tipo) {
      case 'Costal' || 'Kilo(s)' || 'Bote (Gramos)':
        objeto = 'Kilos';
        break;
      case 'Bote (Litros)' || 'Galón':
        objeto = 'Litros';
        break;
      case 'Caja' || 'Bulto' || 'Paquete' || 'Bote (Piezas)':
        objeto = 'Piezas';
        break;
    }
    return objeto;
  }

  //Método que hace una petición al servidor con el id del producto actual para
  //volver a cargar la información del producto actual, si la petición arroja un
  //error entonces se mantendrán los mismos datos y se le informara a usuario
  //por medio de un mensaje tipo toast.
  void recarga(BuildContext context) async {
    context.read<Carga>().cargaBool(true);
    String mensaje = 'Se actualizó el producto.';
    ProductoModel producto = await ProductoModel.getProducto(_prod.id);
    if (producto.mensaje.isEmpty) {
      productosPerdido = calcularPerdidas(producto.perdidaCantidad);
      color[0] = Color(0xFF8A03A9);
      color[1] = Color(0xFF8A03A9);
      _prod = producto;
      notifyListeners();
    } else {
      mensaje = producto.mensaje;
    }
    Textos.toast(mensaje);
    if (context.mounted) context.read<Carga>().cargaBool(false);
  }

  //Método encargado de enviar la entrada y salida del producto al servidor para
  //que se actualice en la base de datos, espera la respuesta de la petición y
  //la muestra al usuario en forma de toast.
  Future enviarDatos(BuildContext context) async {
    context.read<Carga>().cargaBool(true);
    double ent, sal;
    String mensaje = 'No hay datos';
    if (!(controller[0].text.isEmpty && controller[1].text.isEmpty)) {
      (controller[0].text.isEmpty)
          ? ent = 0
          : ent = double.parse(controller[0].text);
      (controller[1].text.isEmpty)
          ? sal = 0
          : sal = double.parse(controller[1].text);
      if (ent < 0) color[0] = Color(0xFFFF0000);
      if (sal < 0) color[1] = Color(0xFFFF0000);
      if (ent >= 0 && sal >= 0) {
        mensaje = await ProductoModel.guardarES(_prod.id, ent, sal);
        if (mensaje.split(": ")[0] != 'Error') {
          ProductoModel producto = await ProductoModel.getProducto(_prod.id);
          if (producto.mensaje.isEmpty) {
            _prod = producto;
            color[0] = Color(0x00000000);
            color[1] = Color(0x00000000);
            controller[0].text = '';
            controller[1].text = '';
            notifyListeners();
          } else {
            mensaje =
                'Se guardó la información, pero no se pudo actualizar el producto';
          }
        }
      }
    }
    Textos.toast(mensaje);
    if (context.mounted) context.read<Carga>().cargaBool(false);
  }

  //Método encargado de enviar la perdida del producto al servidor para que se
  //actualice en la base de datos, espera la respuesta de la petición y la
  //muestra al usuario en forma de toast.
  void guardarPerdidas(BuildContext context) async {
    context.read<Carga>().cargaBool(true);
    bool valido = true;
    for (int i = 0; i < controllerPerdidas.length; i++) {
      color[i + 3] = Color(0x00FFFFFF);
      if (controllerPerdidas[i].text.isEmpty) {
        valido = false;
        color[i + 3] = Color(0xFFFF0000);
      }
    }
    notifyListeners();
    if (valido) {
      double perdidas = double.parse(controllerPerdidas[0].text);
      String mensaje = await ProductoModel.guardarPerdidas(
        _prod.id,
        controllerPerdidas[1].text,
        perdidas,
      );
      if (mensaje.split(": ")[0] != 'Error') {
        ProductoModel producto = await ProductoModel.getProducto(_prod.id);
        if (producto.mensaje.isEmpty) {
          productosPerdido += perdidas;
          _prod = producto;
          notifyListeners();
        } else {
          mensaje =
              'Se guardó la información, pero no se pudo actualizar el producto';
        }
      }
      if (context.mounted) {
        emergente(mensaje.split(':')[0] == 'Error');
        tabla(mensaje.split(':')[0] != 'Error');
      }
      Textos.toast(mensaje);
    }
    if (context.mounted) context.read<Carga>().cargaBool(false);
  }

  void guardarPerdidasProv(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    List.filled(2, Color(0x00FFFFFF), growable: true);
    if (controller[0].text.isEmpty) {
      color[0] = Color(0xFFFF0000);
    }
    if (controller[1].text.isEmpty) {
      color[1] = Color(0xFFFF0000);
    }
    if (controller[1].text.isNotEmpty || controller[1].text.isNotEmpty) {
      double perdidas = double.parse(controller[0].text);
      String mensaje = 'Error: No puedes perder menos de 0 (Buen intento).';
      if (perdidas > 0) {
        String mensaje = await ProductoModel.guardarPerdidas(
          _prod.id,
          controller[1].text,
          perdidas,
        );
        if (mensaje.split(": ")[0] != 'Error') {
          ProductoModel producto = await ProductoModel.getProducto(_prod.id);
          if (producto.mensaje.isEmpty) {
            productosPerdido += perdidas;
            _prod = producto;
          } else {
            mensaje =
                'Se guardó la información, pero no se pudo actualizar el producto';
          }
        }
      }
      if (ctx.mounted) {
        emergente(mensaje.split(':')[0] == 'Error');
        tabla(mensaje.split(':')[0] != 'Error');
      }
      Textos.toast(mensaje);
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  //Método encargado de actualizar el limite del producto al servidor para que
  //se actualice en la base de datos, espera la respuesta de la petición y la
  //muestra al usuario en forma de toast.
  void editarLimite(BuildContext context) async {
    String mensaje = '';
    if (controllerPerdidas[0].text.isEmpty) {
      color[3] = Color(0xFFFF0000);
      notifyListeners();
    } else {
      context.read<Carga>().cargaBool(true);
      mensaje = await ProductoModel.editarProducto(
        _prod.id,
        controllerPerdidas[0].text,
        'LimiteProd',
      );
      if (mensaje.split(': ')[0] != 'Error') {
        color[3] = Color(0x00000000);
        _prod.limiteProd = double.parse(controllerPerdidas[0].text).floor();
        controllerPerdidas[0].text = '';
        notifyListeners();
        mensaje =
            'Se actualizó el límite de productos del producto con id $mensaje.';
        if (context.mounted) {
          emergente(false);
          context.read<Carga>().cargaBool(false);
        }
      }
    }
    if (mensaje.isNotEmpty) Textos.toast(mensaje);
  }

  //Componente tipo ventana que muestra la información de un producto, la
  //información del producto es guardada en la variable "_prod", su visibilidad
  //es controlada por la variable "_producto".
  Widget productoInfo() {
    String entrada = '${_prod.entrada}';
    String salida = '${_prod.salida}';
    if (entrada.split('.').length > 1) {
      if (entrada.split('.')[1] == '0') entrada = entrada.split('.')[0];
    }
    if (salida.split('.').length > 1) {
      if (salida.split('.')[1] == '0') salida = salida.split('.')[0];
    }
    return Visibility(
      visible: _producto,
      child: Stack(
        children: [
          Consumer<Carga>(
            builder: (ctx, carga, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 30),
                decoration: BoxDecoration(color: Colors.black38),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadiusGeometry.circular(25),
                      border: BoxBorder.all(
                        color: Color(0xFFFDC930),
                        width: 2.5,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          spacing: 20,
                          children: [
                            Textos.textoTilulo(_prod.nombre, 30),
                            tipoTexto(ctx),
                            contenedorInfo(
                              '${_prod.tipo}s que entraron:',
                              entrada,
                              0,
                              ctx,
                            ),
                            contenedorInfo(
                              '${tipoUnidad()} que salieron:',
                              salida,
                              1,
                              ctx,
                            ),
                            contenedorInfoPerdidas('$productosPerdido', 2, ctx),
                            Botones.icoCirMor(
                              'Guardar movimientos',
                              Icons.save_rounded,
                              () => enviarDatos(ctx),
                              () => Textos.toast('No hay hay cambios.'),
                              false,
                              true,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Textos.textoGeneral(
                                  'Ultima modificación: \n${_prod.ultimaModificacion}',
                                  false,
                                  2,
                                  size: 15,
                                  alignment: TextAlign.center,
                                ),
                                Textos.textoGeneral(
                                  'Modificada por:  \n${_prod.ultimoUsuario}',
                                  false,
                                  2,
                                  size: 15,
                                  alignment: TextAlign.center,
                                ),
                                Botones.btnCirRos(
                                  'Cerrar',
                                  () => producto(false),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Consumer<VenDatos>(
            builder: (context, venDatos, child) {
              return Ventanas.ventanaTabla(
                (productosPerdido > 0)
                    ? (120 + _prod.perdidaCantidad.length * 30 <
                              MediaQuery.of(context).size.height * .7)
                          ? 120 + _prod.perdidaCantidad.length * 30
                          : MediaQuery.of(context).size.height * .7
                    : null,
                MediaQuery.of(context).size.width,
                ['Perdidas: $productosPerdido'],
                (productosPerdido > 0)
                    ? Tablas.contenedorInfo(
                        MediaQuery.sizeOf(context).width,
                        [.05, .15, .6],
                        ['#', 'Cantidad perdida', 'Razón de perdida'],
                      )
                    : Textos.textoTilulo('No hay perdidas registradas.', 30),
                (productosPerdido > 0)
                    ? SizedBox(
                        height:
                            (_prod.perdidaCantidad.length * 30 <
                                MediaQuery.of(context).size.height * .7)
                            ? _prod.perdidaCantidad.length * 30
                            : MediaQuery.of(context).size.height * .7,
                        child: ListView.separated(
                          itemCount: _prod.perdidaCantidad.length,
                          scrollDirection: Axis.vertical,
                          separatorBuilder: (context, index) => Container(
                            height: 2,
                            decoration: BoxDecoration(color: Color(0xFFFDC930)),
                          ),
                          itemBuilder: (context, index) {
                            String cantidad = '${_prod.perdidaCantidad[index]}';
                            if (cantidad.split('.').length > 1) {
                              if (cantidad.split('.')[1] == '0') {
                                cantidad = cantidad.split('.')[0];
                              }
                            }
                            cantidad = '$cantidad ${tipoUnidad()}';
                            if (_prod.perdidaCantidad[index] == 1) {
                              cantidad = cantidad.substring(
                                0,
                                cantidad.length - 1,
                              );
                            }
                            return Container(
                              width: MediaQuery.sizeOf(context).width,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                              ),
                              child: Tablas.barraDatos(
                                MediaQuery.sizeOf(context).width,
                                [.05, .15, .6],
                                [
                                  '${index + 1}',
                                  '$cantidad ${tipoUnidad()}',
                                  _prod.perdidaRazones[index],
                                ],
                                maxLines: 2,
                              ),
                            );
                          },
                        ),
                      )
                    : SizedBox(
                        child: Botones.btnCirRos(
                          'Agregar perdida',
                          () => {
                            controllerPerdidas[0].text = '',
                            controllerPerdidas[1].text = '',
                            color[3] = Color(0x00000000),
                            color[4] = Color(0x00000000),
                            notifyListeners(),
                            emergente(true),
                            tabla(false),
                          },
                        ),
                      ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Row(
                    spacing: 7.5,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Botones.btnCirRos('Cerrar', () => tabla(false)),
                      if (productosPerdido > 0)
                        Botones.btnCirRos(
                          'Agregar perdida',
                          () => {
                            controllerPerdidas[0].text = '',
                            controllerPerdidas[1].text = '',
                            color[3] = Color(0x00000000),
                            color[4] = Color(0x00000000),
                            notifyListeners(),
                            emergente(true),
                            tabla(false),
                          },
                        ),
                    ],
                  ),
                ),
                visible: _tabla,
              );
            },
          ),
          Consumer2<Carga, Tablas>(
            builder: (context, carga, tablas, child) {
              return Ventanas.ventanaEmergente(
                [
                  '¿Cuánto se perdió y por qué?',
                  'Confirma el nuevo límite de productos.',
                ][ventanaNum],
                'Volver',
                'Guardar',
                () => {
                  emergente(false),
                  color[3] = Color(0x00000000),
                  color[4] = Color(0x00000000),
                  notifyListeners(),
                  tabla(ventanaNum == 0),
                },
                () async => {
                  (ventanaNum == 0)
                      ? guardarPerdidas(context)
                      : editarLimite(context),
                },
                widget: SingleChildScrollView(
                  child: Column(
                    spacing: 10,
                    children: [
                      CampoTexto.inputTexto(
                        MediaQuery.of(context).size.width * .75,
                        'Cantidad',
                        '',
                        controllerPerdidas[0],
                        accion: () => (ventanaNum == 0)
                            ? focus.requestFocus()
                            : editarLimite(context),
                        icono: Icons.numbers_rounded,
                        errorColor: color[3],
                        formato: FilteringTextInputFormatter.allow(
                          RegExp(r'(^\d*\.?\d{0,3})'),
                        ),
                        inputType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      if (ventanaNum == 0)
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75,
                          'Razón de la perdida',
                          '',
                          controllerPerdidas[1],
                          accion: () => guardarPerdidas(context),
                          icono: Icons.message_rounded,
                          errorColor: color[4],
                          focus: focus,
                        ),
                    ],
                  ),
                ),
                visible: _emergente,
              );
            },
          ),
        ],
      ),
    );
  }

  //Componente tipo ventana que muestra la información de un producto, la
  //información del producto es guardada en la variable "_prod", su visibilidad
  //es controlada por la variable "_prov".
  Widget productorInfo(BuildContext context) {
    return Visibility(
      visible: _prov,
      child: Stack(
        children: [
          Consumer<Carga>(
            builder: (context, carga, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 30),
                decoration: BoxDecoration(color: Colors.black38),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadiusGeometry.circular(25),
                      border: BoxBorder.all(
                        color: Color(0xFFFDC930),
                        width: 2.5,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        child: Column(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Textos.textoTilulo(_prod.nombre, 30),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .5,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Textos.textoGeneral(
                                          'Área: ${_prod.area}',
                                          true,
                                          1,
                                          size: 20,
                                          alignment: TextAlign.center,
                                        ),
                                        Textos.textoGeneral(
                                          '${_prod.tipo}:',
                                          true,
                                          1,
                                          size: 20,
                                          alignment: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              child: Column(
                                children: [
                                  (productosPerdido > 0)
                                      ? Tablas.contenedorInfo(
                                          MediaQuery.sizeOf(context).width,
                                          [.05, .15, .6],
                                          [
                                            '#',
                                            'Cantidad perdida',
                                            'Razón de perdida',
                                          ],
                                        )
                                      : Textos.textoTilulo(
                                          'No hay perdidas registradas',
                                          20,
                                        ),
                                  if (productosPerdido > 0)
                                    SizedBox(
                                      height:
                                          3 + _prod.perdidaCantidad.length * 26,
                                      child: ListView.separated(
                                        itemCount: _prod.perdidaCantidad.length,
                                        scrollDirection: Axis.vertical,
                                        separatorBuilder: (context, index) =>
                                            Container(
                                              height: 2,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFDC930),
                                              ),
                                            ),
                                        itemBuilder: (context, index) {
                                          return Container(
                                            width: MediaQuery.sizeOf(
                                              context,
                                            ).width,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            child: Tablas.barraDatos(
                                              MediaQuery.sizeOf(context).width,
                                              [.05, .15, .6],
                                              [
                                                '${index + 1}',
                                                '${_prod.perdidaCantidad[index]} ${tipoUnidad()}',
                                                _prod.perdidaRazones[index],
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                spacing: 10,
                                children: [
                                  Botones.btnCirRos(
                                    'Cerrar',
                                    () => prov(false),
                                  ),
                                  Botones.btnCirRos(
                                    'Agregar perdida',
                                    () => {
                                      controller[0].text = '',
                                      controller[1].text = '',
                                      color[0] = Color(0x00000000),
                                      color[1] = Color(0x00000000),
                                      notifyListeners(),
                                      emergente(true),
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Visibility(
            visible: _emergente,
            child: Consumer2<Carga, Tablas>(
              builder: (context, carga, tablas, child) {
                return Ventanas.ventanaEmergente(
                  '¿Cuánto se perdió y por qué?',
                  'Volver',
                  'Guardar',
                  () => emergente(false),
                  () async => guardarPerdidasProv(context),
                  widget: SingleChildScrollView(
                    child: Column(
                      spacing: 10,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75,
                          'Cantidad',
                          '',
                          controller[0],
                          accion: () => focus.requestFocus(),
                          icono: Icons.numbers_rounded,
                          errorColor: color[0],
                          formato: FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,3})'),
                          ),
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75,
                          'Razón de la perdida',
                          '',
                          controller[1],
                          accion: () => guardarPerdidasProv(context),
                          icono: Icons.message_rounded,
                          errorColor: color[1],
                          focus: focus,
                        ),
                      ],
                    ),
                  ),
                  visible: _emergente,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //Método que se encarga de regresar un componente correspondiente con un texto
  //correspondiente al tipo del producto, este se utiliza para describir cierta
  //parte de la información importante del producto.
  SizedBox tipoTexto(BuildContext ctx) {
    String cantidad = '${_prod.cantidadPorUnidad}';
    if (cantidad.split('.').length > 1) {
      if (cantidad.split('.')[1] == '0') cantidad = cantidad.split('.')[0];
    }
    switch (_prod.tipo) {
      case 'Costal' || 'Bote (Granel)':
        cantidad = 'Kilos por unidad: $cantidad';
        break;
      case 'Bote(Litros)':
        cantidad = 'Litros por unidad: $cantidad';
        break;
      case 'Caja' || 'Bulto' || 'Paquete' || 'Bote (Piezas)':
        cantidad = 'Productos por ${_prod.tipo}: $cantidad';
        break;
    }
    return SizedBox(
      width: MediaQuery.of(ctx).size.width * .5,
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_prod.cantidadPorUnidad != 1)
                Textos.textoGeneral(cantidad, true, 1, size: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Textos.textoGeneral(
                    'Minimo requerido: ${_prod.limiteProd}',
                    true,
                    1,
                    size: 15,
                  ),
                  SizedBox(
                    height: 40,
                    child: Botones.btnSimple(
                      'Editar limite',
                      Icons.edit_rounded,
                      Color(0xFF8A03A9),
                      () => {
                        emergente(true),
                        controllerPerdidas[0].text = '${_prod.limiteProd}',
                        color[3] = Color(0x00000000),
                        ventanaNum = 1,
                        notifyListeners(),
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  //Componente que muestra el tipo del producto junto con las entradas o las
  //salidas, depende del texto declarado, además con la cantidad disponible del
  //dato relacionado.
  static SizedBox contenedorInfo(
    String textoInfo,
    String textoValor,
    int valor,
    BuildContext ctx,
  ) {
    return SizedBox(
      width: MediaQuery.of(ctx).size.width * .55,
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CampoTexto.inputTexto(
            MediaQuery.sizeOf(ctx).width * .3575,
            textoInfo,
            '',
            controller[valor],
            accion: () => FocusManager.instance.primaryFocus?.unfocus(),
            icono: Icons.info_outline_rounded,
            errorColor: color[valor],
            formato: FilteringTextInputFormatter.allow(
              RegExp(r'(^\d*\.?\d{0,3})'),
            ),
            inputType: TextInputType.numberWithOptions(decimal: true),
            borderColor: Color(0xFF8A03A9),
          ),
          Textos.recuadroCantidad(textoValor, Color(0xFF8A03A9)),
        ],
      ),
    );
  }

  //Componente que muestra el tipo del producto junto con la cantidad de
  //productos perdidos, además de las perdidas registradas.
  SizedBox contenedorInfoPerdidas(
    String textoValor,
    int valor,
    BuildContext ctx,
  ) {
    if (textoValor.split('.').length > 1) {
      if (textoValor.split('.')[1] == '0') {
        textoValor = textoValor.split('.')[0];
      }
    }
    return SizedBox(
      width: MediaQuery.of(ctx).size.width * .55,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Textos.textoGeneral(
            'Perdidas registradas:',
            false,
            1,
            size: 20,
            alignment: TextAlign.center,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Textos.recuadroCantidad(textoValor, color[valor]),
              Botones.btnRctMor(
                'Producto perdido',
                Icons.info_outline_rounded,
                false,
                () => {tabla(true), ventanaNum = 0, notifyListeners()},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
