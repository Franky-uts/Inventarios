import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class Textos with ChangeNotifier {
  static List<Color> color = [];

  //Esta función se utiliza para mostrar un breve mensaje (personalizado con la
  //variable texto, claro) en la parte inferior de la pantalla en forma de
  //toast, imo se ve mucho mejor en teléfonos, pero como no me quiero romper la
  //cabeza usaremos este para Android y para web, aunque si quiero mejorarlo en
  //un futuro lo puedo cambiar *wink* *wink*.
  static void toast(String texto) {
    Fluttertoast.showToast(
      msg: texto,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color(0xBFFDC930),
      textColor: Colors.white,
      fontSize: 15,
    );
  }

  //Esta es una función activa la cámara trasera del dispositivo la escanea un
  //código de barras, cabe destacar que solo tiene funcionalidad en Android.
  static Future<String> scan(BuildContext ctx) async {
    return (await SimpleBarcodeScanner.scanBarcode(
      ctx,
      lineColor: '#8A03A9',
      cancelButtonText: 'Regresar',
      isShowFlashIcon: true,
      delayMillis: 2000,
      cameraFace: CameraFace.back,
    ))!;
  }

  //Este es un componente de tipo texto el cual requiere texto, un booleano,
  //este booleano determina el color del texto (morado si es true, rosa si es
  //false); y el número de líneas que puede mostrar (en caso de que el
  //contenedor rebase el número de líneas establecidas entonces el resto del
  //texto se omitirá y se mostrara una elipsis), otros valores que se pueden
  //editar, pero no son necesarios, son el alineamiento y el tamaño del texto.
  static Text textoGeneral(
    String texto,
    bool principal,
    int maxLines, {
    double? size,
    TextAlign? alignment,
  }) {
    return Text(
      texto,
      textAlign: alignment ?? TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: size,
        color: principal ? Color(0xFF8A03A9) : Color(0xFFFF82B9),
      ),
    );
  }

  //Este es un componente de tipo texto blanco el cual solo requiere texto,
  //otro valor opcional que se puede editar, es el tamaño del texto.
  static Text textoBlanco(String texto, {double? size}) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: size, color: Color(0xFFFFFFFF)),
    );
  }

  //Este es un componente de tipo texto morado y con fuente grande el cual
  //requiere texto y tamaño del texto.
  static Text textoTilulo(String texto, double size) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      maxLines: 2,
      style: TextStyle(
        color: Color(0xFF8A03A9),
        fontSize: size,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  //Este es un componente contenedor con un texto rosa en el centro y fondo
  //morado requiere texto.
  static Center textoError(String texto) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color(0x808A03A9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFF6AFCF), fontSize: 20),
        ),
      ),
    );
  }

  //Este es un componente contenedor con un "textoGeneral" en el centro y borde
  //usualmente morado requiere texto (usualmente números) y color de borde.
  static Container recuadroCantidad(String textoValor, Color colorBorde) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: colorBorde, width: 2.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: textoGeneral(
        textoValor,
        true,
        1,
        size: 20,
        alignment: TextAlign.center,
      ),
    );
  }

  //Este es un método que devuelve un color dependiendo de un cálculo, esto se
  //utiliza principalmente al momento de querer representar la cantidad de un
  //producto en un almacén con relación al límite del producto registrado, la
  //lógica funcionaria de siguiente manera: en caso de que haya más productos
  //que el límite establecido entonces devolverá un color verde (representando
  //que la cantidad es aceptable), en caso de tener menos de la cantidad
  //establecida en el límite, pero más de la mitad entonces se devolverá un
  //color amarillo (representando que la cantidad no está mal, pero se deben de
  //pedir producto lo más pronto posible), en caso de contar con menos productos
  //que la mitad del límite establecido entonces se regresara un color rojo
  //(representando que la cantidad es menor de la esperada y que ya se tenía que
  //pedir en una orden, es importante pedir el producto lo más pronto posible).
  static Color colorLimite(int limite, int cantidad) {
    Color color = Color(0xff32c864);
    if (cantidad < limite) color = Color(0xFFFDC930);
    if (cantidad < limite / 2) color = Color(0xFFFF4B4B);
    return color;
  }

  //Este es un método que devuelve un color dependiendo de un texto, esto se
  //utiliza principalmente al momento de querer representar el estado de una
  //orden con relación a los estados existentes, la lógica es más fácil de
  //entender aquí.
  static Color colorEstado(String estado) {
    switch (estado) {
      case ('En proceso'):
        return Colors.blue.shade200;
      case ('Entregado'):
        return Colors.green.shade100;
      case ('Incompleto'):
        return Colors.yellow.shade300;
      case ('Finalizado'):
        return Colors.green.shade300;
      case ('Cancelado'):
        return Colors.red.shade200;
      case ('Denegado'):
        return Colors.red.shade300;
      default:
        return Colors.transparent;
    }
  }

  //Ostras manolo, madre del amor hermoso, tío; hice esta mafufada para poder
  //crear listas de colores cuando se tienen ventanas con tablas porque no se me
  //ocurrió una mejor manera para crearlas, por Dios no puede ser que esta cosa
  //siga funcionando y me pregunto si hay alguna manera de que esta cosa con
  //cimientos de palitos pueda funcionar mejor o de una manera más eficiente.
  static void crearLista(int length, Color color_) {
    color.addAll(List.filled(length, color_));
  }

  //Camarada, ¿Recuerdas la lista anterior? ¿Vez que no sabía como generarla?
  //Bueno, tampoco sabia como vaciarla para que volviera a llenarse con la
  //siguiente lista que se generase, acepto soluciones, no tengo a nadie que me
  //apoye por ahora así que esto se lo estoy escribiendo al fantasma que me
  //está acompañando en estos momentos.
  static void limpiarLista() {
    if (color.isNotEmpty) color = [];
  }

  //Relacionado con lo anterior, como no puedes acceder directamente a la lista
  //de colores tienes que usar esta función para acceder al color de la lista de
  //colores, carnavalito, no entiendo por qué se me hizo tan complicado esto,
  //en fin necesitas ingresar la posición del arreglo que quieres consultar ¡y
  //puede que obtengas un color! (a menos de que haya un error obtendrás un
  //color transparente, que técnicamente es no obtener color, pero como esto
  //funciona, con suerte, pero funciona, siempre obtendrás un color).
  static Color getColor(int i) {
    return color[i];
  }

  //Hermano del alma, recuerdas el método anterior, el cual te devolvía un
  //color ubicado en el arreglo color usado para guardar valores tipo color si
  //le dabas una posición, pues es parte de un set/get, ese es el get, solo
  //falta el set ¿no? Pues es este, dale una posición y un color y verás que
  //pasa en la ventana (apenas que estoy escribiendo esto estoy recordando para
  //que use esto y no creo que tenga usos actualmente).
  void setColor(int i, Color colorInt) {
    color[i] = colorInt;
    notifyListeners();
  }

  //"setAllColor" es como set color, solo que en lugar de seleccionar la
  //ubicación del arreglo que quieres modificar modificas toda la lista,
  //también cabe recalcar que el método set/get anterior no sé san para NADA en
  //el programa, pero quien sabe si en algún futuro tengan uso, si es así me
  //ahorraré colocarle más cinta adhesiva a este código tambaleante.
  void setAllColor(Color color_) {
    for (int i = 0; i < color.length; i++) {
      color[i] = color_;
    }
    notifyListeners();
  }
}
