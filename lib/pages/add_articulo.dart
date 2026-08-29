import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/articulos_model.dart';
import 'package:provider/provider.dart';

//Esta es una página secundaria encargada de registrar un nuevo artículo en la
//base de datos, si es que se cubren todos los parámetros.
class Addarticulo extends StatefulWidget {
  final List listaArea;
  final List listaTipo;

  const Addarticulo({
    super.key,
    required this.listaArea,
    required this.listaTipo,
  });

  @override
  State<Addarticulo> createState() => _AddproductoState();
}

class _AddproductoState extends State<Addarticulo> {
  late List<String> listaArea = [];
  late List<String> listaTipo = [];
  late String valorArea, valorTipo;
  late bool cantidad, materia;
  final List<TextEditingController> controller = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  late List<Color> colorCampo = [
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
  ];

  @override
  void initState() {
    cantidad = false;
    materia = false;
    listaTipo.add('Tipo');
    listaArea.add('Área');
    listaTipo.addAll(widget.listaTipo.map((item) => item as String).toList());
    listaArea.addAll(widget.listaArea.map((item) => item as String).toList());
    valorArea = listaArea.first;
    valorTipo = listaTipo.first;
    super.initState();
  }

  @override
  void dispose() {
    colorCampo.clear();
    controller.clear();
    listaArea.clear();
    listaTipo.clear();
    super.dispose();
  }

  //Este método se encarga de mantener la consistencia de la información en la
  //base de datos, si se selecciona la opción "Tipos" en la lista de sección de
  //tipo, el campo de cantidad no podrá ser editable y se borrara cualquier
  //texto que se haya ingresado, en cado de que el tipo sea caja, bote, etc.
  //este habilitara la edición del campo de la cantidad por unidad, cualquier
  //otra opción dejara el campo de texto como inhabilitado y el texto en el
  //campo será siempre 1.
  void cantidadValido(String value) {
    cantidad = false;
    switch (value) {
      case "Galón" || "Litro" || "Pieza" || "Garrafa" || "Kilo(s)":
        controller[1].text = '1';
        break;
      case "Tipo":
        controller[1].clear();
        break;
      default:
        cantidad = true;
        controller[1].clear();
        break;
    }
  }

  //Método que se encarga de verificar que todos los parámetros que debe tener
  //un artículo para poder registrarse sean cubiertos correctamente, en caso de
  //que falte algún campo o que el valor se atenga valores incorrectos, este
  //mostrara un color rojo alrededor en el borde del campo que necesite una
  //revisión, cuando la información sea válida esta enviara una petición y
  //mostrara en forma de toast el mensaje que recibió por parte del servidor.
  void registrarArticulo(BuildContext ctx) async {
    setState(() {
      context.read<Carga>().cargaBool(true);
    });
    colorCampo = List.filled(
      colorCampo.length,
      Color(0x00FFFFFF),
      growable: true,
    );
    if (controller[0].text.isEmpty) colorCampo[0] = Color(0xFFFF0000);
    if (controller[1].text.isEmpty) colorCampo[3] = Color(0xFFFF0000);
    if (controller[3].text.isEmpty) colorCampo[4] = Color(0xFFFF0000);
    if (valorArea == 'Área') colorCampo[2] = Color(0xFFFF0000);
    if (valorTipo == 'Tipo') colorCampo[1] = Color(0xFFFF0000);
    if (controller[0].text.isNotEmpty &&
        controller[1].text.isNotEmpty &&
        controller[3].text.isNotEmpty &&
        valorTipo != 'Tipo' &&
        valorArea != 'Área') {
      String respuesta = await ArticulosModel.addArticulo(
        controller[0].text,
        valorTipo,
        valorArea,
        double.parse(controller[1].text),
        controller[2].text,
        double.parse(controller[3].text),
        materia,
      );
      if (respuesta.split(': ')[0] != 'Error') {
        controller[0].text = '';
        controller[1].text = '';
        controller[2].text = '';
        controller[3].text = '';
        cantidad = false;
        valorTipo = listaTipo.first;
        valorArea = listaArea.first;
      }
      Textos.toast(respuesta);
    }
    setState(() {
      context.read<Carga>().cargaBool(false);
    });
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
  //campo de texto no está vacío, entonces simplemente se borrara el texto que
  //había en el campo de texto.
  void iniciarScan(BuildContext ctx) async {
    if (controller[2].text.isEmpty) {
      if (kIsWeb) {
        ctx.read<Ventanas>().scan(true);
      } else {
        ctx.read<Carga>().cargaBool(true);
        String respuesta = await Textos.scan(context);
        if (ctx.mounted) scanCod(ctx, respuesta);
      }
    } else {
      controller[2].text = '';
    }
  }

  //Método que se encarga de recibir la información de una elemento escaneado y
  //establecerlo en el campo correspondiente al código de barras, si detecta que
  //el texto es "-1" o no se escaneó algo se dejara el campo como vacío, si el
  //código de barras es igual a algún código ya registrado en algún artículo,
  //entonces, se le hará de conocimiento al usuario y el campo de texto se
  //mantendrá vacío.
  void scanCod(BuildContext ctx, String texto) async {
    if (texto == '-1' || texto.isEmpty) {
      texto = '';
    } else {
      List<ArticulosModel> lista = await ArticulosModel.getArticulos('id', '');
      bool flag = true;
      for (ArticulosModel articulo in lista) {
        if (articulo.codigoBarras == texto) flag = false;
      }
      if (!flag) Textos.toast('El código ya esta registrado');
    }
    setState(() {
      controller[2].text = texto;
    });
    if (ctx.mounted) {
      ctx.read<Ventanas>().emergente(true);
      ctx.read<Carga>().cargaBool(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
      drawer: RecDrawer.drawer(context, []),
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .675,
                          'Nombre',
                          '',
                          controller[0],
                          accion: () =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          icono: Icons.file_copy_rounded,
                          errorColor: colorCampo[0],
                        ),
                        Column(
                          children: [
                            Textos.textoBlanco('Materia prima', size: 15),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .075,
                              child: Botones.btnRctMor(
                                'Materia Prima',
                                materia
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                false,
                                () => setState(() {
                                  materia = !materia;
                                }),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Textos.textoBlanco('Área', size: 15),
                            CampoTexto.inputDropdown(
                              MediaQuery.of(context).size.width,
                              Icons.door_front_door_rounded,
                              valorArea,
                              listaArea,
                              colorCampo[2],
                              (value) => setState(() {
                                valorArea = value;
                              }),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Textos.textoBlanco('Tipo', size: 15),
                            CampoTexto.inputDropdown(
                              MediaQuery.of(context).size.width,
                              Icons.settings_suggest,
                              valorTipo,
                              listaTipo,
                              colorCampo[1],
                              (value) {
                                cantidadValido(value);
                                setState(() {
                                  valorTipo = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      spacing: 5,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .365,
                          'Cantidad por unidades',
                          '',
                          controller[1],
                          enabled: cantidad,
                          icono: Icons.numbers_rounded,
                          errorColor: colorCampo[3],
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          formato: FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,3})'),
                          ),
                          accion: () =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .365,
                          'Precio',
                          '',
                          controller[3],
                          accion: () =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          icono: Icons.numbers_rounded,
                          errorColor: colorCampo[4],
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          formato: FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,3})'),
                          ),
                          inputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75 * .925,
                          'Codigo de barras',
                          '',
                          controller[2],
                          enabled: false,
                          icono: Icons.barcode_reader,
                        ),
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width * (.75 * .075),
                          child: Botones.btnSimple(
                            'Escanear código',
                            (controller[2].text.isEmpty)
                                ? Icons.document_scanner_rounded
                                : Icons.refresh_rounded,
                            Color(0xFFFFFFFF),
                            () async => iniciarScan(context),
                          ),
                        ),
                      ],
                    ),
                    Botones.iconoTexto(
                      'Añadir',
                      Icons.add_circle_rounded,
                      () => registrarArticulo(context),
                    ),
                  ],
                ),
              ),
            ),
            Botones.layerButton(() => Navigator.pop(context)),
            Consumer2<Ventanas, Carga>(
              builder: (context, ventanas, carga, child) {
                return Ventanas.ventanaScan(
                  context,
                  () => ventanas.scan(false),
                  (texto) => scanCod(context, texto),
                );
              },
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }
}
