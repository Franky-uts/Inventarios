import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/botones.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/rec_drawer.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/models/historial_model.dart';
import 'package:inventarios/models/registro_model.dart';
import 'package:inventarios/pages/historial_info.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});

  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  bool reporte = false, registros = false;
  String fecIni = '';
  String fecFin = '';
  List<TextEditingController> fecIniCont = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  List<TextEditingController> fecFinCont = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  List<FocusNode> focus = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  Future<List<Object>> getHistorial(String filtro, String busqueda) async =>
      registros
      ? await RegistroModel.getRegistros(fecIni, fecFin, 'Fecha', busqueda)
      : await HistorialModel.getHistorial(fecIni, fecFin, filtro, busqueda);

  Future<void> getHistorialInfo(BuildContext ctx, int id, String fecha) async {
    ctx.read<Carga>().cargaBool(true);
    HistorialModel historial = await HistorialModel.getHistorialInfo(id, fecha);
    (historial.mensaje.isEmpty)
        ? {
            await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text),
            if (ctx.mounted)
              {
                ctx.read<HistorialInfo>().setHisotrial(historial),
                ctx.read<HistorialInfo>().esp(true),
              },
          }
        : Textos.toast(historial.mensaje, true);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  Future<void> getRegistroInfo(
    BuildContext ctx,
    String fecha,
    String hora,
    String usuario,
  ) async {
    ctx.read<Carga>().cargaBool(true);
    RegistroModel registro = await RegistroModel.getRegistro(
      fecha,
      hora,
      usuario,
    );
    (registro.mensaje.isEmpty)
        ? {
            await LocalStorage.set('busqueda', CampoTexto.busquedaTexto.text),
            if (ctx.mounted)
              {
                ctx.read<HistorialInfo>().setRegistro(registro),
                ctx.read<HistorialInfo>().reg(true),
              },
          }
        : Textos.toast(registro.mensaje, true);
    if (ctx.mounted) ctx.read<Carga>().cargaBool(false);
  }

  Future<void> setFecha(BuildContext ctx) async {
    ctx.read<Carga>().cargaBool(true);
    bool valido = true;
    String mensaje = '';
    for (int i = 0; i < 2; i++) {
      valido = !(fecIniCont[i].text.isEmpty || fecFinCont[i].text.isEmpty);
      if (valido) {
        if (fecIniCont[i].text.length < 2) {
          fecIniCont[i].text = '0${fecIniCont[i].text}';
        }
        if (fecFinCont[i].text.length < 2) {
          fecFinCont[i].text = '0${fecFinCont[i].text}';
        }
      }
    }
    valido =
        valido &&
        !(fecFinCont[2].text.length < 4 || fecIniCont[2].text.length < 4);
    if (valido) {
      DateTime fi = DateTime.parse(
        '${fecIniCont[2].text}-${fecIniCont[1].text}-${fecIniCont[0].text}',
      );
      DateTime ff = DateTime.parse(
        '${fecFinCont[2].text}-${fecFinCont[1].text}-${fecFinCont[0].text}',
      );
      (ff.isAfter(fi) || ff.isAtSameMomentAs(fi))
          ? {
              fecIni =
                  '${fecIniCont[0].text}-${fecIniCont[1].text}-${fecIniCont[2].text}',
              fecFin =
                  '${fecFinCont[0].text}-${fecFinCont[1].text}-${fecFinCont[2].text}',
              reporte
                  ? {
                      mensaje = await RecDrawer.historialExcel(
                        ctx,
                        fecIni,
                        fecFin,
                      ),
                      mensaje.split(': ')[0] == 'Error'
                          ? mensaje = mensaje.split(': ')[1]
                          : {
                              fecIniCont[0].text = '',
                              fecIniCont[1].text = '',
                              fecIniCont[2].text = '',
                              fecFinCont[0].text = '',
                              fecFinCont[1].text = '',
                              fecFinCont[2].text = '',
                              fecIni = '',
                              fecFin = '',
                              if (ctx.mounted)
                                ctx.read<Ventanas>().emergente(false),
                            },
                    }
                  : ctx.read<Tablas>().datos(
                      await getHistorial(
                        CampoTexto.filtroTexto(),
                        CampoTexto.busquedaTexto.text,
                      ),
                    ),
            }
          : mensaje = 'La fecha inicial no debe ser mayor a la final.';
    } else {
      mensaje = 'Fecha inválida';
    }
    if (ctx.mounted) {
      mensaje.isEmpty
          ? ctx.read<Ventanas>().emergente(false)
          : Textos.toast(mensaje, true);
      ctx.read<Carga>().cargaBool(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: RecDrawer.drawer(context, [
        if (LocalStorage.local('puesto') == 'Administrador')
          Consumer<Carga>(
            builder: (ctx, carga, child) {
              return Botones.icoCirMor(
                'Cambiar de tienda',
                Icons.change_circle_rounded,
                () => {
                  Navigator.of(ctx).pop(),
                  carga.cargaBool(true),
                  ctx.read<Ventanas>().cambio(true),
                  carga.cargaBool(false),
                },
                () => {},
                false,
                true,
              );
            },
          ),
        Consumer2<Carga, Ventanas>(
          builder: (ctx, carga, ventanas, child) {
            return Botones.icoCirMor(
              'Descargar reporte',
              Icons.download_rounded,
              () => {
                Navigator.of(context).pop(),
                ventanas.emergente(true),
                reporte = true,
              },
              () => Textos.toast('Espera a que los datos carguen.', false),
              true,
              Carga.getValido(),
            );
          },
        ),
        /*if (LocalStorage.local('locación') != 'Cedis')
          Consumer<Carga>(
            builder: (ctx, carga, child) {
              return Botones.icoCirMor(
                'Nueva orden',
                Icons.add_shopping_cart_rounded,
                () async => {
                  carga.cargaBool(true),
                  if (CampoTexto.seleccionFiltro == Filtros.fecha)
                    CampoTexto.seleccionFiltro = Filtros.id,
                  await RecDrawer.salidaOrdenes(context),
                },
                () => Textos.toast('Espera a que los datos carguen.', false),
                false,
                Carga.getValido(),
              );
            },
          ),
        Consumer<Carga>(
          builder: (context, carga, child) {
            return Botones.icoCirMor(
              'Ver almacen',
              Icons.inventory_rounded,
              () => {
                carga.cargaBool(true),
                if (CampoTexto.seleccionFiltro == Filtros.fecha)
                  CampoTexto.seleccionFiltro = Filtros.id,
                RecDrawer.pushAnim(widget.ruta, context),
                carga.cargaBool(false),
              },
              () => {},
              true,
              true,
            );
          },
        ),*/
      ]),
      backgroundColor: Color(0xFFFF5600),
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            Builder(
              builder: (context) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    barraSuperior(context),
                    Column(
                      children: [
                        Consumer<Tablas>(
                          builder: (context, tablas, child) {
                            return Tablas.contenedorInfo(
                              MediaQuery.sizeOf(context).width,
                              registros
                                  ? [.3, .3, .3]
                                  : [.2, .1, .25, .175, .125],
                              registros
                                  ? ['Fecha', 'Hora', 'Usuario']
                                  : [
                                      'Fecha',
                                      'id',
                                      'Nombre',
                                      'Area',
                                      'Movimientos',
                                    ],
                            );
                          },
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 143.5,
                          child: Consumer<Tablas>(
                            builder: (context, tablas, child) {
                              return Tablas.listaFutura(
                                listaPrincipal,
                                'No hay movimientos registrados.',
                                'No hay coincidencias.',
                                () => getHistorial(
                                  CampoTexto.filtroTexto(),
                                  CampoTexto.busquedaTexto.text,
                                ),
                                accionRefresh: () async => tablas.datos(
                                  await getHistorial(
                                    CampoTexto.filtroTexto(),
                                    CampoTexto.busquedaTexto.text,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (LocalStorage.local('puesto') == 'Administrador')
              Consumer2<Ventanas, Carga>(
                builder: (context, ventanas, carga, child) {
                  return Ventanas.cambioDeTienda(
                    context,
                    () async => context.read<Tablas>().datos(
                      await getHistorial(
                        CampoTexto.filtroTexto(),
                        CampoTexto.busquedaTexto.text,
                      ),
                    ),
                  );
                },
              ),
            Consumer2<Ventanas, Carga>(
              builder: (context, ventanas, carga, child) {
                return Ventanas.ventanaEmergente(
                  'Selecciona un rango',
                  'Volver',
                  'Confirmar',
                  () => ventanas.emergente(false),
                  () async => await setFecha(context),
                  widget: Column(
                    children: [
                      Textos.textoGeneral(
                        'Fecha inicial',
                        true,
                        1,
                        size: 20,
                        alignment: TextAlign.center,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CampoTexto.inputTexto(
                            MediaQuery.of(context).size.width * .225,
                            'Dia',
                            '',
                            fecIniCont[0],
                            true,
                            false,
                            accion: () => focus[0].requestFocus(),
                            formato: LengthLimitingTextInputFormatter(2),
                            inputType: TextInputType.number,
                          ),
                          CampoTexto.inputTexto(
                            MediaQuery.of(context).size.width * .225,
                            'Mes',
                            '',
                            fecIniCont[1],
                            true,
                            false,
                            accion: () => focus[1].requestFocus(),
                            focus: focus[0],
                            formato: LengthLimitingTextInputFormatter(2),
                            inputType: TextInputType.number,
                          ),
                          CampoTexto.inputTexto(
                            MediaQuery.of(context).size.width * .225,
                            'Año',
                            '',
                            fecIniCont[2],
                            true,
                            false,
                            accion: () => focus[2].requestFocus(),
                            focus: focus[1],
                            formato: LengthLimitingTextInputFormatter(4),
                            inputType: TextInputType.number,
                          ),
                        ],
                      ),
                      Textos.textoGeneral(
                        'Fecha final',
                        true,
                        1,
                        size: 20,
                        alignment: TextAlign.center,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CampoTexto.inputTexto(
                            MediaQuery.of(context).size.width * .225,
                            'Dia',
                            '',
                            fecFinCont[0],
                            true,
                            false,
                            accion: () => focus[3].requestFocus(),
                            focus: focus[2],
                            formato: LengthLimitingTextInputFormatter(2),
                            inputType: TextInputType.number,
                          ),
                          CampoTexto.inputTexto(
                            MediaQuery.of(context).size.width * .225,
                            'Mes',
                            '',
                            fecFinCont[1],
                            true,
                            false,
                            accion: () => focus[4].requestFocus(),
                            focus: focus[3],
                            formato: LengthLimitingTextInputFormatter(2),
                            inputType: TextInputType.number,
                          ),
                          CampoTexto.inputTexto(
                            MediaQuery.of(context).size.width * .225,
                            'Año',
                            '',
                            fecFinCont[2],
                            true,
                            false,
                            accion: () async => await setFecha(context),
                            focus: focus[4],
                            formato: LengthLimitingTextInputFormatter(4),
                            inputType: TextInputType.number,
                          ),
                        ],
                      ),
                    ],
                  ),
                  extraButton: Botones.btnCirRos(
                    'Restablecer fechas',
                    () async => {
                      for (int i = 0; i < 3; i++)
                        {fecIniCont[i].text = '', fecFinCont[i].text = ''},
                      fecIni = '',
                      fecFin = '',
                      context.read<Tablas>().datos(
                        await getHistorial(
                          CampoTexto.filtroTexto(),
                          CampoTexto.busquedaTexto.text,
                        ),
                      ),
                    },
                  ),
                );
              },
            ),
            Consumer<HistorialInfo>(
              builder: (context, historial, child) {
                return registros
                    ? historial.regInfo(context)
                    : historial.espInfo(context);
              },
            ),
            Carga.ventanaCarga(),
          ],
        ),
      ),
    );
  }

  Widget barraSuperior(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Botones.btnRctMor(
            'Abrir menú',
            Icons.menu_rounded,
            false,
            () => Scaffold.of(context).openDrawer(),
            size: 35,
          ),
          Botones.btnRctMor(
            'Establecer rango de fechas',
            Icons.date_range_rounded,
            false,
            () => {context.read<Ventanas>().emergente(true), reporte = false},
            size: 35,
          ),
          Consumer<Tablas>(
            builder: (context, tablas, child) {
              return Botones.btnRctMor(
                (registros) ? 'Ver movimientos' : 'Ver registros',
                (registros)
                    ? Icons.checklist_rtl_rounded
                    : Icons.inventory_rounded,
                false,
                () => {registros = !registros, tablas.datos([])},
                size: 35,
              );
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width * .8,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Consumer2<Tablas, CampoTexto>(
              builder: (context, tablas, campoTexto, child) {
                return CampoTexto.barraBusqueda(
                  () async => tablas.datos(
                    await getHistorial(
                      CampoTexto.filtroTexto(),
                      CampoTexto.busquedaTexto.text,
                    ),
                  ),
                  false,
                  true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  ListView listaPrincipal(List lista, ScrollController controller) {
    return ListView.separated(
      controller: controller,
      itemCount: lista.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => Container(
        height: 2,
        decoration: BoxDecoration(color: Color(0xFFFDC930)),
      ),
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Tablas.barraDatos(
            MediaQuery.sizeOf(context).width,
            registros ? [.3, .3, .3] : [.2, .1, .25, .175, .125],
            registros
                ? [lista[index].fecha, lista[index].hora, lista[index].usuario]
                : [
                    lista[index].fecha,
                    "${lista[index].id}",
                    lista[index].nombre,
                    lista[index].area,
                    '${lista[index].movimientos}',
                  ],
            [],
            1,
            extra: registros
                ? () async => await getRegistroInfo(
                    context,
                    lista[index].fecha,
                    lista[index].hora,
                    lista[index].usuario,
                  )
                : () async => await getHistorialInfo(
                    context,
                    lista[index].id,
                    lista[index].fecha,
                  ),
          ),
        );
      },
    );
  }
}
