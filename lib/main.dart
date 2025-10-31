import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/pages/inicio.dart';
import 'package:inventarios/pages/inventario.dart';
import 'package:inventarios/pages/ordenes.dart';
import 'package:inventarios/services/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await LocalStorage.getPreferencias();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: ruta());
  }

  Widget ruta() {
    if (LocalStorage.preferencias.getString('usuario') != null) {
      if (LocalStorage.preferencias.getString('puesto') == 'Proveedor') {
        return Ordenes();
      } else {
        return Inventario();
      }
    } else {
      return Inicio();
    }
  }
}
