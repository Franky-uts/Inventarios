import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences preferencias;

  static Future<void> getPreferencias() async {
    preferencias = await SharedPreferences.getInstance();
  }
}
