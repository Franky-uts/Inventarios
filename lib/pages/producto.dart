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

class Producto with ChangeNotifier {
  static ProductoModel _prod = ProductoModel.dummy('');
  static double entr = 0, sali = 0;
  static double productosPerdido = 0;
  static int ventanaNum = 0;
  static Timer? timer;
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

  void setProducto(ProductoModel producto) {
    _prod = producto;
    productosPerdido = calcularPerdidas(producto.perdidaCantidad);
    notifyListeners();
  }

  void producto(bool boolean) {
    _producto = boolean;
    notifyListeners();
  }

  void prov(bool boolean) {
    _prov = boolean;
    notifyListeners();
  }

  void emergente(bool boolean) {
    _emergente = boolean;
    notifyListeners();
  }

  void tabla(bool boolean) {
    _tabla = boolean;
    notifyListeners();
  }

  /*@override
  void initState() {
    productosPerdido = calcularPerdidas(productoInfo.perdidaCantidad);
    super.initState();
  }

  @override
  void dispose() {
    controllerPerdidas.clear();
    controller.clear();
    timer?.cancel();
    color.clear();
    super.dispose();
  }*/

  double calcularPerdidas(List<double> lista) {
    double perdida = 0;
    for (double obj in lista) {
      perdida += obj;
    }
    return perdida;
  }

  void recarga(BuildContext context) async {
    context.read<Carga>().cargaBool(true);
    String mensaje = 'Se actualizó el producto.';
    ProductoModel producto = await ProductoModel.getProducto(_prod.id);
    producto.mensaje.isEmpty
        ? {
            entr = 0,
            sali = 0,
            productosPerdido = calcularPerdidas(producto.perdidaCantidad),
            color[0] = Color(0xFF8A03A9),
            color[1] = Color(0xFF8A03A9),
            _prod = producto,
            notifyListeners(),
          }
        : mensaje = producto.mensaje;
    Textos.toast(mensaje, false);
    if (context.mounted) context.read<Carga>().cargaBool(false);
  }

  /*Future enviarDatos(BuildContext context) async {
    context.read<Carga>().cargaBool(true);
    String mensaje = await ProductoModel.guardarES(entr, sali, productoInfo.id);
    if (mensaje.split(": ")[0] != 'Error') {
      ProductoModel producto = await ProductoModel.getProducto(productoInfo.id);
      (producto.mensaje.isEmpty)
          ? setState(() {
              productoInfo = producto;
              productosPerdido = calcularPerdidas(producto.perdidaCantidad);
              entr = 0;
              sali = 0;
              color[0] = Color(0xFF8A03A9);
              color[1] = Color(0xFF8A03A9);
            })
          : mensaje =
                'Se guardó la información, pero no se pudo actualizar el producto';
    }
    if (context.mounted) context.read<Carga>().cargaBool(false);
    Textos.toast(mensaje, true);
  }*/

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
        mensaje = await ProductoModel.guardarES(ent, sal, _prod.id);
        if (mensaje.split(": ")[0] != 'Error') {
          ProductoModel producto = await ProductoModel.getProducto(_prod.id);
          (producto.mensaje.isEmpty)
              ? {
                  _prod = producto,
                  color[0] = Color(0x00000000),
                  color[1] = Color(0x00000000),
                  controller[0].text = '',
                  controller[1].text = '',
                  notifyListeners(),
                }
              : mensaje =
                    'Se guardó la información, pero no se pudo actualizar el producto';
        }
      }
    }
    Textos.toast(mensaje, true);
    if (context.mounted) context.read<Carga>().cargaBool(false);
  }

  void cambioValor(bool entrada, int valor) {
    Color col = Color(0xFFFF0000);
    entrada
        ? {
            if ((entr + _prod.entrada + valor) >= _prod.entrada)
              {
                col = Color(0xFF8A03A9),
                entr += valor,
                if (valor < 0 && _prod.unidades + entr - sali < 0)
                  {sali += valor, if (sali == 0) color[1] = Color(0xFF8A03A9)},
              },
            if (entr + _prod.entrada != _prod.entrada) col = Color(0xFF00be00),
          }
        : {
            if ((sali + _prod.salida + valor) >= _prod.salida)
              {
                col = Color(0xFF8A03A9),
                if ((_prod.unidades + entr - (sali + valor)) >= 0)
                  sali += valor,
                if (sali + _prod.salida != _prod.salida)
                  col = Color(0xFF00be00),
              },
          };
    color[entrada ? 0 : 1] = col;
    notifyListeners();
  }

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
      double unidades = double.parse(
        (_prod.unidades - (perdidas / _prod.cantidadPorUnidad)).toStringAsFixed(
          3,
        ),
      );
      String mensaje = 'Error: Las perdidas exceden la cantidad almacenada';
      if (unidades >= 0) {
        mensaje = await ProductoModel.guardarPerdidas(
          controllerPerdidas[1].text,
          perdidas,
          _prod.id,
        );
        if (mensaje.split(": ")[0] != 'Error') {
          ProductoModel producto = await ProductoModel.getProducto(_prod.id);
          (producto.mensaje.isEmpty)
              ? {
                  productosPerdido += perdidas,
                  _prod = producto,
                  notifyListeners(),
                }
              : mensaje =
                    'Se guardó la información, pero no se pudo actualizar el producto';
        }
        if (context.mounted) {
          emergente(mensaje.split(':')[0] == 'Error');
          tabla(mensaje.split(':')[0] != 'Error');
        }
        Textos.toast(mensaje, true);
      }
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
      double unidades = double.parse(
        (perdidas / _prod.cantidadPorUnidad).toStringAsFixed(3),
      );
      String mensaje = 'Error: Las perdidas exceden la cantidad almacenada';
      if (_prod.unidades - unidades >= 0) {
        mensaje = await ProductoModel.guardarPerdidas(
          controller[1].text,
          perdidas,
          _prod.id,
        );
        if (mensaje.split(": ")[0] != 'Error') {
          ProductoModel producto = await ProductoModel.getProducto(_prod.id);
          (producto.mensaje.isEmpty)
              ? {productosPerdido += perdidas, _prod = producto}
              : mensaje =
                    'Se guardó la información, pero no se pudo actualizar el producto';
        }
      }
      if (ctx.mounted) {
        emergente(mensaje.split(':')[0] == 'Error');
        tabla(mensaje.split(':')[0] != 'Error');
      }
      Textos.toast(mensaje, true);
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  void editarLimite(BuildContext context) async {
    String mensaje = '';
    (controllerPerdidas[0].text.isEmpty)
        ? {color[3] = Color(0xFFFF0000), notifyListeners()}
        : {
            context.read<Carga>().cargaBool(true),
            mensaje = await ProductoModel.editarProducto(
              _prod.id,
              controllerPerdidas[0].text,
              'LimiteProd',
            ),
            if (mensaje.split(': ')[0] != 'Error')
              {
                {
                  color[3] = Color(0x00000000),
                  _prod.limiteProd = double.parse(
                    controllerPerdidas[0].text,
                  ).floor(),
                  controllerPerdidas[0].text = '',
                  notifyListeners(),
                },
                mensaje =
                    'Se actualizó el límite de productos del producto con id $mensaje.',
                if (context.mounted)
                  {emergente(false), context.read<Carga>().cargaBool(false)},
              },
          };
    if (mensaje.isNotEmpty) Textos.toast(mensaje, true);
  }

  Widget productoInfo(BuildContext context) {
    return Visibility(
      visible: _producto,
      child: Stack(
        children: [
          Consumer<Carga>(
            builder: (context, carga, child) {
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
                            tipoTexto(_prod.tipo, context),
                            contenedorInfo(
                              ' que entraron:',
                              _prod.entrada,
                              0,
                              context,
                            ),
                            contenedorInfo(
                              ' que salieron:',
                              _prod.salida,
                              1,
                              context,
                            ),
                            contenedorInfoPerdidas(
                              productosPerdido,
                              2,
                              context,
                            ),
                            Botones.icoCirMor(
                              'Guardar movimientos',
                              Icons.save_rounded,
                              () => enviarDatos(context),
                              () => Textos.toast('No hay hay cambios.', false),
                              false,
                              true,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                footer([
                                  'Ultima modificación:',
                                  _prod.ultimaModificacion,
                                ], context),
                                footer([
                                  'Modificada por:',
                                  _prod.ultimoUsuario,
                                ], context),
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
          Visibility(
            visible: _tabla,
            child: Consumer<VenDatos>(
              builder: (context, venDatos, child) {
                return Ventanas.ventanaTabla(
                  (productosPerdido > 0)
                      ? (120 + _prod.perdidaCantidad.length * 30 <
                                MediaQuery.of(context).size.height * .7)
                            ? 120 + _prod.perdidaCantidad.length * 30
                            : MediaQuery.of(context).size.height * .7
                      : MediaQuery.of(context).size.height * .175,
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
                              decoration: BoxDecoration(
                                color: Color(0xFFFDC930),
                              ),
                            ),
                            itemBuilder: (context, index) {
                              String cantidad =
                                  '${_prod.perdidaCantidad[index]}';
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
                                    (cantidad.split('.').length > 1)
                                        ? (cantidad.split('.')[1] == '0')
                                              ? cantidad.split('.')[0]
                                              : cantidad
                                        : cantidad,
                                    _prod.perdidaRazones[index],
                                  ],
                                  [],
                                  2,
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
          ),
          Visibility(
            visible: _emergente,
            child: Consumer2<Carga, Tablas>(
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
                          true,
                          false,
                          () => (ventanaNum == 0)
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
                            true,
                            false,
                            () => guardarPerdidas(context),
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
          ),
        ],
      ),
    );
  }

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
                                        Textos.recuadroCantidad(
                                          ('${_prod.unidades}'
                                                      .split('.')
                                                      .length >
                                                  1)
                                              ? ('${_prod.unidades}'.split(
                                                          '.',
                                                        )[1] ==
                                                        '0')
                                                    ? '${_prod.unidades}'.split(
                                                        '.',
                                                      )[0]
                                                    : '${_prod.unidades}'
                                              : '${_prod.unidades}',
                                          Textos.colorLimite(
                                            _prod.limiteProd,
                                            _prod.unidades.floor(),
                                          ),
                                          1,
                                          size: 20,
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
                                          'Perdidas: $productosPerdido',
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
                                                '${_prod.perdidaCantidad[index]}',
                                                _prod.perdidaRazones[index],
                                              ],
                                              [],
                                              1,
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
                          true,
                          false,
                          () => focus.requestFocus(),
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
                          true,
                          false,
                          () => guardarPerdidasProv(context),
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

  SizedBox tipoTexto(String tipo, BuildContext ctx) {
    String titulo = '${tipo}s:';
    String cantidad = '${_prod.cantidadPorUnidad}';
    if (cantidad.split('.').length > 1) {
      if (cantidad.split('.')[1] == '0') cantidad = cantidad.split('.')[0];
    }
    if (tipo == 'Granel') {
      titulo = 'Kilos:';
    } else if (tipo == 'Costal') {
      titulo = 'Unidades:';
      cantidad = 'Kilos por unidad: $cantidad';
    } else if (tipo == 'Bote') {
      titulo = 'Unidades:';
      cantidad = 'Kilos/Piezas por unidad: $cantidad';
    } else if (tipo == 'Caja' || tipo == 'Bulto' || tipo == 'Paquete') {
      cantidad = 'Productos por $tipo: $cantidad';
    } else if (tipo == 'Galón') {
      titulo = 'Galones:';
    }
    String unidades = '${_prod.unidades + entr - sali}';
    if (unidades.split('.').length > 1) {
      if (unidades.split('.')[1] == '0') unidades = unidades.split('.')[0];
    }
    return SizedBox(
      width: MediaQuery.of(ctx).size.width * .5,
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Textos.textoGeneral(
                titulo,
                true,
                1,
                size: 20,
                alignment: TextAlign.center,
              ),
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
          Textos.recuadroCantidad(
            unidades,
            Textos.colorLimite(
              _prod.limiteProd,
              (_prod.unidades + entr - sali).floor(),
            ),
            1,
            size: 20,
          ),
        ],
      ),
    );
  }

  /*SizedBox contenedorInfo(
    String textoInfo,
    double textoValor,
    double textoTotal,
    bool entrada,
  ) {
    String valor = ('$textoValor'.split('.').length > 1)
        ? ('$textoValor'.split('.')[1] == '0')
              ? '$textoValor'.split('.')[0]
              : '$textoValor'
        : '$textoValor';
    String text = '${productoInfo.tipo}s$textoInfo';
    if (productoInfo.tipo == 'Galón') {
      text = 'Galones$textoInfo';
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * .55,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Textos.textoGeneral(
            text,
            false,
            1,
            size: 20,
            alignment: TextAlign.center,
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onLongPress: () => timer = Timer.periodic(
                      Duration(milliseconds: 150),
                      (timer) => cambioValor(entrada, -1),
                    ),
                    onLongPressEnd: (_) => setState(() {
                      timer?.cancel();
                    }),
                    child: Botones.btnRctMor(
                      '',
                      Icons.remove,
                      false,
                      () => cambioValor(entrada, -1),
                    ),
                  ),
                  Textos.recuadroCantidad(
                    valor,
                    color[entrada ? 0 : 1],
                    1,
                    size: 20,
                  ),
                  GestureDetector(
                    onLongPress: () => timer = Timer.periodic(
                      Duration(milliseconds: 150),
                      (timer) => cambioValor(entrada, 1),
                    ),
                    onLongPressEnd: (_) => setState(() {
                      timer?.cancel();
                    }),
                    child: Botones.btnRctMor(
                      '',
                      Icons.add,
                      false,
                      () => cambioValor(entrada, 1),
                    ),
                  ),
                ],
              ),
              Textos.textoGeneral('Total: $textoTotal', true, 1),
            ],
          ),
        ],
      ),
    );
  }*/

  static SizedBox contenedorInfo(
    String textoInfo,
    double textoValor,
    int valor,
    BuildContext ctx,
  ) {
    String text = 'Kilos ${_prod.tipo}s$textoInfo';
    return SizedBox(
      width: MediaQuery.of(ctx).size.width * .55,
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CampoTexto.inputTexto(
            MediaQuery.sizeOf(ctx).width * .3575,
            text,
            '',
            controller[valor],
            true,
            false,
            () => FocusManager.instance.primaryFocus?.unfocus(),
            icono: Icons.info_outline_rounded,
            errorColor: color[valor],
            formato: FilteringTextInputFormatter.allow(
              RegExp(r'(^\d*\.?\d{0,3})'),
            ),
            inputType: TextInputType.numberWithOptions(decimal: true),
            borderColor: Color(0xFF8A03A9),
          ),
          Textos.recuadroCantidad(
            '$textoValor',
            Color(0xFF8A03A9),
            1,
            size: 20,
          ),
        ],
      ),
    );
  }

  SizedBox contenedorInfoPerdidas(
    double textoValor,
    int valor,
    BuildContext ctx,
  ) {
    String text = 'Productos perdidos:';
    if (_prod.tipo == 'Granel' || _prod.tipo == 'Costal') {
      text = 'Kilos perdidos:';
    } else if (_prod.tipo == 'Bote') {
      text = 'Gramos/Piezas perdidos:';
    }
    return SizedBox(
      width: MediaQuery.of(ctx).size.width * .55,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Textos.textoGeneral(
            text,
            false,
            1,
            size: 20,
            alignment: TextAlign.center,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Textos.recuadroCantidad(
                ('$textoValor'.split('.').length > 1)
                    ? ('$textoValor'.split('.')[1] == '0')
                          ? '$textoValor'.split('.')[0]
                          : '$textoValor'
                    : '$textoValor',
                color[valor],
                1,
                size: 20,
              ),
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

  SizedBox footer(List<String> textos, BuildContext ctx) {
    List<Widget> lista = [];
    for (String txt in textos) {
      lista.add(Textos.textoGeneral(txt, false, 1, size: 15));
    }
    return SizedBox(
      width: MediaQuery.of(ctx).size.width * .35,
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: lista,
      ),
    );
  }
}
