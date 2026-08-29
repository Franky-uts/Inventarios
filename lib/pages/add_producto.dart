import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/models/articulos_model.dart';
import 'package:inventarios/models/producto_model.dart';
import 'package:provider/provider.dart';

//Esta es una página secundaria encargada de registrar un nuevo preoducto en la
//base de datos, si es que se cubren todos los parámetros.
class AddProducto extends StatefulWidget {
  final List<ArticulosModel> listaArticulos;
  final List areas;

  const AddProducto({
    super.key,
    required this.listaArticulos,
    required this.areas,
  });

  @override
  State<AddProducto> createState() => _AddproductoState();
}

class _AddproductoState extends State<AddProducto> {
  late List<String> articuloLista = [];
  late List<String> areasLista = [];
  late String articuloValor;
  late String areaValor;
  late int id;
  final List<TextEditingController> control = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  late List<Color> colorCampo = [
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
    Color(0x00FFFFFF),
  ];
  String? res;

  @override
  void initState() {
    articuloLista.add('Artículos');
    areasLista.add('Áreas');
    articuloValor = articuloLista.first;
    areaValor = areasLista.first;
    areasLista.addAll(widget.areas.map((item) => item as String).toList());
    super.initState();
  }

  @override
  void dispose() {
    colorCampo.clear();
    articuloLista.clear();
    areasLista.clear();
    control.clear();
    super.dispose();
  }

  //Método que se encarga de verificar que todos los parámetros que debe tener
  //un artículo para poder registrarse sean cubiertos correctamente, en caso de
  //que falte algún campo o que el valor se atenga valores incorrectos, este
  //mostrara un color rojo alrededor en el borde del campo que necesite una
  //revisión, cuando la información sea válida esta enviara una petición y
  //mostrara en forma de toast el mensaje que recibió por parte del servidor.
  void registrarProducto(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    colorCampo = List.filled(3, Color(0x00FFFFFF), growable: true);
    if (control[0].text.isEmpty) colorCampo[2] = Color(0xFFFF0000);
    if (articuloValor == 'Artículos') colorCampo[1] = Color(0xFFFF0000);
    if (areaValor == 'Áreas') colorCampo[0] = Color(0xFFFF0000);
    if (control[0].text.isNotEmpty &&
        articuloValor != 'Artículos' &&
        areaValor != 'Áreas') {
      String respuesta = await ProductoModel.addProducto(
        id,
        int.parse(control[0].text),
      );
      (respuesta.split(': ')[0] != 'Error')
          ? {
              id = 0,
              control[0].text = '',
              control[1].text = '',
              control[2].text = '',
              articuloValor = articuloLista.first,
              areaValor = areasLista.first,
            }
          : respuesta = respuesta.split(': ')[1];
      Textos.toast(respuesta);
    }
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  //Método que se encarga de establecer la lista de áreas disponibles,
  //dependiendo del área seleccionada se mostraran los artículos asociados con
  //el área para añadir al almacén.
  void setArea(String areaNombre) {
    articuloLista = ['Artículos'];
    articuloValor = articuloLista.first;
    if (areaNombre != 'Áreas') {
      for (ArticulosModel articulo in widget.listaArticulos) {
        if (articulo.area == areaNombre) articuloLista.add(articulo.nombre);
      }
    }
    id = 0;
    setState(() {
      control[1].text = '';
      control[2].text = '';
      areaValor = areaNombre;
    });
  }

  //Método que se encarga de establecer la lista de artículos disponibles,
  //dependiendo del área previamente seleccionada, cuando se seleccione un
  //artículo se mostraran los demás datos del artículo para determinar si es el
  //que se quiere añadir al almacén.
  void setArticulo(String articuloNombre) {
    ArticulosModel? art;
    if (articuloNombre != 'Artículos') {
      for (ArticulosModel articulo in widget.listaArticulos) {
        if (articulo.nombre == articuloNombre && articulo.area == areaValor) {
          art = articulo;
        }
      }
    }
    id = art!.id;
    setState(() {
      control[1].text = art!.tipo;
      control[2].text = '${art.cantidadPorUnidad}';
      articuloValor = articuloNombre;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5600),
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Consumer<Carga>(
              builder: (context, carga, child) {
                return Container(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 15,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Textos.textoBlanco('Áreas', size: 15),
                                CampoTexto.inputDropdown(
                                  MediaQuery.of(context).size.width,
                                  Icons.door_front_door_rounded,
                                  areaValor,
                                  areasLista,
                                  colorCampo[0],
                                  (value) => setArea(value),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Textos.textoBlanco('Artículo', size: 15),
                                CampoTexto.inputDropdown(
                                  MediaQuery.of(context).size.width,
                                  Icons.door_front_door_rounded,
                                  articuloValor,
                                  articuloLista,
                                  colorCampo[1],
                                  (value) => setArticulo(value),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 20,
                          children: [
                            CampoTexto.inputTexto(
                              MediaQuery.of(context).size.width * .365,
                              'Tipo',
                              '',
                              control[1],
                              enabled: false,
                              accion: () =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              icono: Icons.file_copy_rounded,
                            ),
                            CampoTexto.inputTexto(
                              MediaQuery.of(context).size.width * .365,
                              'Cantidad por unidad',
                              '',
                              control[2],
                              enabled: false,
                              accion: () =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              icono: Icons.question_mark_rounded,
                            ),
                          ],
                        ),
                        CampoTexto.inputTexto(
                          MediaQuery.of(context).size.width * .75,
                          'Limite minimo de productos',
                          '',
                          control[0],
                          accion: () => registrarProducto(context),
                          icono: Icons.production_quantity_limits_rounded,
                          errorColor: colorCampo[2],
                          inputType: TextInputType.number,
                          formato: FilteringTextInputFormatter.digitsOnly,
                        ),
                        Botones.iconoTexto(
                          'Añadir',
                          Icons.add_circle_rounded,
                          () => registrarProducto(context),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Botones.layerButton(() => Navigator.pop(context)),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }
}
