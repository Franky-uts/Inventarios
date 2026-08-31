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

//Esta es una página ventana con información relacionada con un artículo
//seleccionado de la lista de artículos.
class Articulo extends ChangeNotifier {
  static ArticulosModel _articulo = ArticulosModel.dummy('');
  static List<ProductoModel> _lista = [];
  static int numVen = 0;
  static bool _art = false, _emergente = false, _scan = false;
  static TextEditingController controller = TextEditingController();
  static Color color = Color(0x00000000);

  //Método que establece el artículo que se mostrara.
  void articulo(ArticulosModel art) async {
    _articulo = art;
    _lista = await ProductoModel.getDatosArticulo(art.id);
    notifyListeners();
  }

  //Método que controla el booleano "_art", este se encarga de la visibilidad de
  //la ventana que muestra el artículo.
  void art(bool boolean) {
    _art = boolean;
    notifyListeners();
  }

  //Método que controla el booleano "_emergente", este se encarga de la
  //visibilidad de la ventana emergente que se maneja en esta clase.
  void emergente(bool boolean) {
    _emergente = boolean;
    notifyListeners();
  }

  //Método que controla el booleano "_scan", este se encarga de la visibilidad
  //de la ventana scan que se maneja en esta clase.
  void scan(bool boolean) {
    numVen = 0;
    _scan = boolean;
    notifyListeners();
  }

  //Este método se encarga de decidir que hacer cuando se pide escáner un código
  //de barras, en caso de que se presione el botón con relación a ingresar un
  //código de barras y no hay texto en el campo de texto, la aplicación
  //verificara si se está ejecutando en navegador si este es el caso entonces se
  //abrirá una ventana sonde podrás ingresar el código de barras con el teclado
  //o puedes usar un escáner para escanear un código de barras y establecer el
  //texto relacionado en el campo de texto, al presionar enter o al terminar de
  //escanear se cerrara la ventana y el texto que había en la ventana ahora
  //estará en el campo de texto correspondiente; si la aplicación no se ejecuta
  //en navegador se cambiara a una pantalla donde se habría la cámara y se
  //cerrara hasta que se escanee un código de barras, o se regresará a la
  //anterior y establecerá el texto escaneado en el campo correspondiente, si
  //sucede algún error el campo de texto seguirá vacío; por el contrario si el
  //campo de texto no está vacío, entonces simplemente se dejara el texto que
  //había en el campo de texto sin cambios.
  void iniciarScan(BuildContext ctx) async {
    if (kIsWeb) {
      scan(true);
    } else {
      ctx.read<Carga>().cargaBool(true);
      String respuesta = await Textos.scan(ctx);
      if (ctx.mounted) scanCod(ctx, respuesta);
    }
  }

  //Método que se encarga de recibir la información de una elemento escaneado y
  //establecerlo en el campo correspondiente al código de barras, si detecta que
  //el texto es "-1" o no se escaneó algo se dejara el campo con el texto que
  //tenía previamente, si el código de barras es igual a algún código ya
  //registrado en algún artículo, entonces, se le hará de conocimiento al
  //usuario y el campo de texto mantendrá su valor inicial.
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
          if (kIsWeb) {
            cambioColumna(ctx);
          } else {
            emergente(true);
            ctx.read<Carga>().cargaBool(false);
          }
        }
      } else {
        Textos.toast('El código ya esta registrado');
      }
    }
  }

  //Este método se ejecuta al momento que el usuario quiera cambiar la
  //información de algún dato, más en específico el valor del código de barras,
  //la cantidad por unidad (depende del tipo del artículo) y el precio; si el
  //nuevo dato ingresado no es válido se mostrara en el campo de texto
  //cambiando el borde a color rojo, si es válido se enviara una petición al
  //servidor y se esperara la respuesta, dicha respuesta se mostrara al usuario,
  //si la respuesta es positiva se cerrara la ventana y el valor del campo a
  //cambiar tendrá el nuevo valor.
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
      Textos.toast(mensaje);
      if (ctx.mounted) {
        emergente(false);
        ctx.read<Carga>().cargaBool(false);
      }
    }
  }

  //Es una línea de texto que se establece al momento de abrir el artículo, si
  //este no tiene código de barras se mostrara el texto 'Sin código
  //establecido', en cambio si su código de barras si está establecido este
  //mostrara el texto 'Código de barras: código' donde código cambiara al código
  //de barras del artículo;
  String codigoTexto(String codigo) {
    if (codigo.isEmpty) {
      return 'Sin codigo establecido';
    } else {
      return 'Código de barras: $codigo';
    }
  }

  //Componente tipo ventana que muestra la información de un artículo, la
  //información del artículo es guardada en la variable "_articulo", su
  //visibilidad es controlada por la variable "_art".
  Widget articuloInfo(BuildContext context) {
    String pre = ('${_articulo.precio}'.split('')[1] == '0')
        ? '${_articulo.precio}'.split('.')[0]
        : '${_articulo.precio}';
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
                                      rectanguloContainer('Precio: $pre'),
                                      Botones.btnSimple(
                                        'Cambiar precio',
                                        Icons.price_change_rounded,
                                        Color(0xFF8A03A9),
                                        () => {
                                          numVen = 2,
                                          controller.text = pre,
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
                                  [0.2, 0.1, 0.1, 0.1, 0.2, 0.2],
                                  [
                                    'Tienda',
                                    'Entradas',
                                    'Salidas',
                                    'Perdidas',
                                    'Ultimo usuario',
                                    'Ultima modificación',
                                  ],
                                ),
                                SizedBox(
                                  height: _lista.length * 39,
                                  child: _lista.isNotEmpty
                                      ? listaPrincipal(_lista)
                                      : Carga.carga(),
                                ),
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
                  enabled: numVen != 0,
                  accion: () => cambioColumna(context),
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

  //Componente que regresa una lista de productos, la función de esta lista en
  //esta ventana es para mostrar los productos registrados en diferentes
  //almacenes con este mismo artículo.
  ListView listaPrincipal(List lista) {
    return ListView.separated(
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        String entrada = '${lista[index].entrada}';
        String salida = '${lista[index].salida}';
        if (entrada.split('.').length > 1) {
          if (entrada.split('.')[1] == '0') {
            entrada = entrada.split('.')[0];
          }
        }
        if (salida.split('.').length > 1) {
          if (salida.split('.')[1] == '0') {
            salida = salida.split('.')[0];
          }
        }
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            [0.2, 0.1, 0.1, 0.1, 0.2, 0.2],
            [
              lista[index].nombre,
              entrada,
              salida,
              '${lista[index].perdidaCantidad.length}',
              lista[index].ultimoUsuario,
              lista[index].ultimaModificacion,
            ],
            maxLines: 2,
          ),
        );
      },
    );
  }

  //Componente creado para aumentar la legibilidad del código.
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

  //Componente que toma un valor tipo texto y lo estiliza para que sea más
  //legible en la ventana con información.
  Container rectanguloContainer(String texto) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Color(0x40F6AFCF),
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
