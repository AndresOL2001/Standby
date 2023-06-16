import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:standby/provider/providers.dart';

import 'package:standby/services/services.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';

import 'package:standby/widgets/screens.dart';

import 'views/Map.dart';

//late SharedPreferences sharedPreferences;

void main() async{
  //Para las notificaciones se hizo async el metodo main
  //Para ejecutar las inicializaciones de las notificaciones
  WidgetsFlutterBinding();
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then(
    (value){
      if( value ){
        Permission.notification.request();
      }
    }
  );
  await initNotifications();
  // ------------------------------------------------------
  //sharedPreferences = await SharedPreferences.getInstance();
  await Preferences.init();

  //Correr la app

  runApp(
      MultiProvider(
        providers: [
        ChangeNotifierProvider( create: (context) => UserFormProvider() ),
        ChangeNotifierProvider( create: (context) => AuthService() ),
        ChangeNotifierProvider( create: (context) => LoginFormProvider() ),
        // Agrega otros proveedores aquí
      ],
        builder: (context, child) {
          return MyApp();
      }
      )
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  
  bool isLoggedIn = Preferences.isLogged;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stand By 0.5.5',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          elevation: 0,
        ),
      ),
      initialRoute: isLoggedIn
      ? 'home'
      : 'login',
      routes: {
        'login': ( _ ) => const LoginScreen(),
        'home' : ( _ ) => const Home(),
        'mapa' : ( _ ) => const Map(),
        'registro_usuario' : ( _ ) => const RegistroUsuario(),
        'accesos' : ( _ ) => Accesos(),
      },
    );
  }

}