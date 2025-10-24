import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventarios/models/usuario_model.dart';
import 'package:inventarios/pages/inicio.dart';
import 'package:inventarios/pages/inventario.dart';
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
      return Inventario(
        usuario: UsuarioModel(
          nombre: LocalStorage.preferencias.getString('usuario').toString(),
          puesto: LocalStorage.preferencias.getString('puesto').toString(),
          locacion: LocalStorage.preferencias.getString('locación').toString(),
        ),
        busqueda: "",
      );
    } else {
      return Inicio();
    }
  }
}
