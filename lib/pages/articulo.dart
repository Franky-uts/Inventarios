import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/articulos_model.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:provider/provider.dart';

class Articulo extends ChangeNotifier {
  static ArticulosModel _articulo = ArticulosModel.dummy('');
  static List<ProductoModel> _lista = [];
  static int numVen = 0;
  static bool _art = false, _emergente = false, _scan = false;
  static TextEditingController controller = TextEditingController();
  static Color color = Color(0x00000000);

  void articulo(ArticulosModel art) async {
    _articulo = art;
    _lista = await ProductoModel.getDatosArticulo(art.id);
    notifyListeners();
  }

  void art(bool boolean) {
    _art = boolean;
    notifyListeners();
  }

  void emergente(bool boolean) {
    _emergente = boolean;
    notifyListeners();
  }

  void scan(bool boolean) {
    numVen = 0;
    _scan = boolean;
    notifyListeners();
  }

  void iniciarScan(BuildContext ctx) async {
    if (kIsWeb) {
      scan(true);
    } else {
      ctx.read<Carga>().cargaBool(true);
      String respuesta = await Textos.scan(ctx);
      if (ctx.mounted) scanCod(ctx, respuesta);
    }
  }

  void scanCod(BuildContext ctx, String texto) async {
    if (texto == '-1' || texto.isEmpty) {
      texto = _articulo.codigoBarras;
    } else {
      List<ArticulosModel> lista = await ArticulosModel.getArticulos('id', '');
      bool flag = true;
      for (ArticulosModel articulo in lista) {
        if (articulo.codigoBarras == texto) flag = false;
      }
      if (flag) {
        controller.text = texto;
        if (ctx.mounted) {
          (kIsWeb)
              ? cambioColumna(ctx)
              : {emergente(true), ctx.read<Carga>().cargaBool(false)};
        }
      } else {
        Textos.toast('El código ya esta registrado', flag);
      }
    }
  }

  void cambioColumna(BuildContext ctx) async {
    if (controller.text.isEmpty) {
      color = Color(0xFFFF0000);
      notifyListeners();
    } else {
      ctx.read<Carga>().cargaBool(true);
      String mensaje = await ArticulosModel.editarArticulo(
        _articulo.id,
        (numVen == 0) ? "'${controller.text}'" : controller.text,
        ['CodigoBarras', 'CantidadPorUnidad', 'Precio'][numVen],
      );
      if (mensaje.split(': ')[0] != 'Error') {
        color = Color(0x00000000);
        switch (numVen) {
          case 0:
            _articulo.codigoBarras = controller.text;
            break;
          case 1:
            _articulo.cantidadPorUnidad = double.parse(controller.text);
            break;
          case 2:
            _articulo.precio = double.parse(controller.text);
            break;
        }
        notifyListeners();
      }
      Textos.toast(mensaje, true);
      if (ctx.mounted) {
        emergente(false);
        ctx.read<Carga>().cargaBool(false);
      }
    }
  }

  /*void recarga(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    String mensaje = 'Se actualizó el articulo.';
    ArticulosModel articulo = await ArticulosModel.getArticulo(
      articulo.id,
    );
    articulo.mensaje.isEmpty
        ? {
            setState(() {
              this.articulo = articulo;
            }),
          }
        : mensaje = articulo.mensaje;

    Textos.toast(mensaje, false);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }*/

  String codigoTexto(String codigo) {
    (codigo.isEmpty)
        ? codigo = 'Sin codigo establecido'
        : codigo = 'Código de barras: $codigo';
    return codigo;
  }

  Widget articuloInfo(BuildContext context) {
    return Visibility(
      visible: _art,
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
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Textos.textoTilulo(_articulo.nombre, 30),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .8,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                spacing: 20,
                                children: [
                                  rectanguloContainer(
                                    'Área: ${_articulo.area}',
                                  ),
                                  rectanguloContainer(
                                    'Tipo: ${_articulo.tipo}',
                                  ),
                                  rowBoton(context),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Color(0x59F6AFCF),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Textos.textoGeneral(
                                          'Materia prima:',
                                          true,
                                          1,
                                          size: 20,
                                          alignment: TextAlign.center,
                                        ),
                                      ),
                                      Botones.btnRctMor(
                                        'Materia Prima',
                                        _articulo.materia
                                            ? Icons.check_box_rounded
                                            : Icons
                                                  .check_box_outline_blank_rounded,
                                        false,
                                        () => {},
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .9,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      rectanguloContainer(
                                        codigoTexto(_articulo.codigoBarras),
                                      ),
                                      Botones.btnSimple(
                                        'Cambiar Código de barras',
                                        Icons.edit_note_rounded,
                                        Color(0xFF8A03A9),
                                        () => iniciarScan(context),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      rectanguloContainer(
                                        ('${_articulo.precio}'.split('')[1] ==
                                                '0')
                                            ? 'Precio: ${_articulo.precio}'
                                                  .split('.')[0]
                                            : 'Precio: ${_articulo.precio}',
                                      ),
                                      Botones.btnSimple(
                                        'Cambiar precio',
                                        Icons.price_change_rounded,
                                        Color(0xFF8A03A9),
                                        () => {
                                          numVen = 2,
                                          controller.text =
                                              ('${_articulo.precio}'.split(
                                                    '',
                                                  )[1] ==
                                                  '0')
                                              ? '${_articulo.precio}'.split(
                                                  '.',
                                                )[0]
                                              : '${_articulo.precio}',
                                          emergente(true),
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Tablas.contenedorInfo(
                                  MediaQuery.sizeOf(context).width,
                                  [0.2, 0.075, 0.075, 0.075, 0.075, 0.2, 0.2],
                                  [
                                    'Tienda',
                                    'Unidades',
                                    'Entradas',
                                    'Salidas',
                                    'Perdidas',
                                    'Ultimo usuario',
                                    'Ultima modificación',
                                  ],
                                ),
                                SizedBox(
                                  height: _lista.length * 35,
                                  child: _lista.isNotEmpty
                                      ? listaPrincipal(_lista)
                                      : Carga.carga(),
                                ),
                                /*SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height*.3,
                                  child: Consumer2<Tablas, Articulo>(
                                    builder:
                                        (context, tablas, articulo, child) {
                                          return Tablas.listaFutura(

                                            'No hay productos registrados.',
                                            'No hay coincidencias.',
                                            () => await lista(),
                                            accionRefresh: () => {},
                                          );
                                        },
                                  ),
                                ),*/
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Botones.btnCirRos(
                                        'Cerrar',
                                        () => art(false),
                                      ),
                                    ],
                                  ),
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
          Consumer2<Carga, Tablas>(
            builder: (context, carga, tablas, child) {
              return Ventanas.ventanaEmergente(
                [
                  'Confirmar Código de barras',
                  'Editar cantidad por unidad',
                  'Editar precio',
                ][numVen],
                'Cancelar',
                'Confirmar',
                () => {
                  color = Color(0x00000000),
                  emergente(false),
                  notifyListeners(),
                },
                () => cambioColumna(context),
                widget: CampoTexto.inputTexto(
                  MediaQuery.of(context).size.width * .75,
                  ['Código de barras', 'Cantidad por unidad', 'Precio'][numVen],
                  '',
                  controller,
                  numVen != 0,
                  false,
                  () => cambioColumna(context),
                  icono: Icons.mode_edit_outline_rounded,
                  errorColor: color,
                  formato: FilteringTextInputFormatter.allow(
                    RegExp(r'(^\d*\.?\d{0,3})'),
                  ),
                  inputType: TextInputType.numberWithOptions(decimal: true),
                ),
                visible: _emergente,
              );
            },
          ),
          Consumer2<Ventanas, Carga>(
            builder: (context, ventanas, carga, child) {
              return Ventanas.ventanaScan(
                context,
                () => scan(false),
                (texto) => scanCod(context, texto),
                visible: _scan,
              );
            },
          ),
        ],
      ),
    );
  }

  ListView listaPrincipal(List lista) {
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        List<Color> colores = [];
        colores = List.filled(7, Colors.transparent);
        colores[1] = Textos.colorLimite(
          lista[index].limiteProd,
          lista[index].unidades.floor(),
        );
        String unidad = '${lista[index].unidades}';
        String entrada = '${lista[index].entrada}';
        String salida = '${lista[index].salida}';
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [0.2, 0.075, 0.075, 0.075, 0.075, 0.2, 0.2],
            [
              lista[index].nombre,
              (unidad.split('.').length > 1)
                  ? (unidad.split('.')[1] == '0')
                        ? unidad.split('.')[0]
                        : unidad
                  : unidad,
              (entrada.split('.').length > 1)
                  ? (entrada.split('.')[1] == '0')
                        ? entrada.split('.')[0]
                        : entrada
                  : entrada,
              (salida.split('.').length > 1)
                  ? (salida.split('.')[1] == '0')
                        ? salida.split('.')[0]
                        : salida
                  : salida,
              '${lista[index].perdidaCantidad.length}',
              lista[index].ultimoUsuario,
              lista[index].ultimaModificacion,
            ],
            colores,
            2,
          ),
        );
      },
    );
  }

  Row rowBoton(BuildContext ctx) {
    String texto = '${_articulo.cantidadPorUnidad}';
    if (texto.split('.').length > 1) {
      if (texto.split('.')[1] == '0') texto = texto.split('.')[0];
    }
    return Row(
      children: [
        rectanguloContainer('Cantidad por unidad: $texto'),
        if (_articulo.tipo == 'Bote' ||
            _articulo.tipo == 'Bulto' ||
            _articulo.tipo == 'Caja' ||
            _articulo.tipo == 'Costal' ||
            _articulo.tipo == 'Paquete')
          Botones.btnSimple(
            'Cambiar cantidad por unidad',
            Icons.edit_rounded,
            Color(0xFF8A03A9),
            () => {
              numVen = 1,
              controller.text = '${_articulo.cantidadPorUnidad}',
              emergente(true),
            },
          ),
      ],
    );
  }

  Container rectanguloContainer(String texto) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Color(0x59F6AFCF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Textos.textoGeneral(
        texto,
        true,
        1,
        size: 20,
        alignment: TextAlign.center,
      ),
    );
  }
}
