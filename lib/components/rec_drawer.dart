import 'package:flutter/material.dart';
import 'package:inventarios/components/textos.dart';
import 'package:inventarios/services/local_storage.dart';
import 'package:provider/provider.dart';

import 'botones.dart';
import 'carga.dart';

class RecDrawer {
  static Drawer drawer(BuildContext ctx, List<Widget> botones) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFFFDC930)),
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(6.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Textos.textoGeneral("Bienvenido, ", 15, true, false),
                    Botones.btnRctMor(
                      "Cerrar sesión",
                      0,
                      Icons.logout_rounded,
                      true,
                      () => {
                        ctx.read<Carga>().cargaBool(true),
                        Textos.limpiarLista(),
                        LocalStorage.logout(ctx),
                        ctx.read<Carga>().cargaBool(false),
                      },
                    ),
                  ],
                ),
                Textos.textoGeneral(
                  LocalStorage.local('usuario'),
                  30,
                  true,
                  false,
                ),
                Textos.textoGeneral(
                  LocalStorage.local('puesto'),
                  15,
                  true,
                  false,
                ),
                Textos.textoGeneral(
                  "Mostrando: ${LocalStorage.local('locación')}",
                  20,
                  true,
                  false,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: botones,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
