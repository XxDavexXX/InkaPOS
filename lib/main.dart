import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/services.dart';
import 'pages/home.dart';
import 'services/hive_helper.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Hive code
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await Hive.openBox('settings');
  await Hive.openBox<Map>('products');
  await Hive.openBox<Map>('clients');
  await Hive.openBox<Map>('cart');
  await Hive.openBox<Map>('turnos');
  await Hive.openBox<Map>('Registro de ventas');
  await Hive.openBox<Map>('Pedidos borrados');
  await Hive.openBox<Map>('Cierres de turno');
  await Hive.openBox<Map>('Usuarios');
  await Hive.openBox<Map>('Grupo de usuarios');
  await Hive.openBox<Map>('Metodos de pago');
  await Hive.openBox<Map>('Grupos');
  await Hive.openBox<Map>('Subgrupos');
  await Hive.openBox<Map>('Observaciones');
  await Hive.openBox<Map>('Areas');
  await Hive.openBox<Map>('Egresos');
  await Hive.openBox<Map>('Correlativos');
  await Hive.openBox<Map>('Impresoras');
  await Hive.openBox<Map>('Cajas');

  // Agregar algunos valores iniciales en la base de datos
  bool appJustInstalled = Hive.box('settings').get('appJustInstalled') == null;
  //Si no hay usuarios, crear el usuario admin por defecto
  Box usuarios = Hive.box<Map>('Usuarios');
  if (usuarios.keys.toList().isEmpty) {
    Map adminUser = {'usuario': 'admin', 'contraseña': '123', 'activo': true};
    dynamic id = await usuarios.add(adminUser);
    await usuarios.put(id, {'id': id, ...adminUser});
  }
  //Crear los primeros métodos de pago
  Box metodosDePago = Hive.box<Map>('Metodos de pago');
  if (appJustInstalled) {
    print('Creando los métodos de pago iniciales por defecto');
    Hive.box('settings').put('appJustInstalled', false);
    await addMetodoDePago({
      'abreviatura': 'S/',
      'nombre': 'Efectivo soles',
      'tipo': 'efectivo',
      'divisa': 'PEN',
    });
    await addMetodoDePago({
      'abreviatura': '\$',
      'nombre': 'Efectivo dólares',
      'tipo': 'efectivo',
      'divisa': 'USD',
    });
    await addMetodoDePago({
      'abreviatura': 'Vi',
      'nombre': 'Tarjeta Visa',
      'tipo': 'tarjeta',
      'divisa': 'PEN',
    });
    await addMetodoDePago({
      'abreviatura': 'MC',
      'nombre': 'Tarjeta Mastercard',
      'tipo': 'tarjeta',
      'divisa': 'PEN',
    });
    await addMetodoDePago({
      'abreviatura': 'Ya',
      'nombre': 'Yape',
      'tipo': 'yape',
      'divisa': 'PEN',
    });
    await addMetodoDePago({
      'abreviatura': 'Pl',
      'nombre': 'Plin',
      'tipo': 'plin',
      'divisa': 'PEN',
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inkapos',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(235, 114, 12, 1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(235, 114, 12, 1),
          toolbarHeight: 66,
        ),
        colorScheme: const ColorScheme(
          primary: Color.fromRGBO(235, 114, 12, 1),
          onPrimary: Colors.white,
          secondary: Color.fromRGBO(102, 102, 102, 1),
          onSecondary: Colors.white,
          brightness: Brightness.light,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 19.0,
          ),
          bodyMedium: TextStyle(color: Colors.black, fontSize: 16.0),
        ),
      ),
      home: const Home(),
    );
  }
}
