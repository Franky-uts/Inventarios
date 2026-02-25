import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/components/carga.dart';
import 'package:inventarios/components/input.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/components/ventanas.dart';
import 'package:inventarios/components/tablas.dart';
import 'package:inventarios/components/ven_datos.dart';
import 'package:inventarios/views/empleado.dart';
import 'package:inventarios/pages/inicio.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:inventarios/views/productor.dart';
import 'package:inventarios/views/proveedor.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await LocalStorage.getPreferencias();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Carga()),
        ChangeNotifierProvider(create: (_) => Ventanas()),
        ChangeNotifierProvider(create: (_) => Tablas()),
        ChangeNotifierProvider(create: (_) => CampoTexto()),
        ChangeNotifierProvider(create: (_) => Textos()),
        ChangeNotifierProvider(create: (_) => VenDatos()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: ruta());
  }

  Widget ruta() {
    StatefulWidget ruta = Inicio();
    if (LocalStorage.preferencias.getString('usuario') != null) {
      ruta = Empleado(index: 0);
      switch (LocalStorage.preferencias.getString('puesto')) {
        case ('Proveedor'):
          ruta = Proveedor(index: 0);
          break;
        case ('Producción'):
          ruta = Productor(index: 0);
          break;
      }
    }
    return ruta;
  }
}
