import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:standby/provider/providers.dart';
import 'package:standby/provider/ui_provider.dart';

import 'package:standby/services/services.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';
import 'package:standby/views/Accesos.dart';
import 'package:standby/views/Home.dart';
import 'package:standby/views/Login.dart';
import 'package:standby/views/MapResidencial.dart';
import 'package:standby/views/PagoCompleto.dart';
import 'package:standby/views/Principal.dart';
import 'package:standby/views/RegistroUsuario.dart';

//late SharedPreferences sharedPreferences;

void main() async{
  Stripe.publishableKey = "pk_test_51NgIgBDxEzW2L8puKidxqRts08Lv8LUeRjdpOYolNBs7NJwtbIWEZUc1HPlalvodu6goeh6z0eCypyMsuuM7rQoH00wH1tUFZj";

  List<Permission> permissions = [
    Permission.location,
    Permission.activityRecognition, // Asegúrate de que sea el nombre correcto del permiso de actividad física
    Permission.notification,
  ];

  //Para las notificaciones se hizo async el metodo main
  //Para ejecutar las inicializaciones de las notificaciones
  WidgetsFlutterBinding();
  DartPluginRegistrant.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  await Permission.locationAlways.isDenied.then((value) {
      if( value ){
        Permission.locationAlways.request();
      }
  });

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
        ChangeNotifierProvider( create: (context) => UiProvider() ),
        // Agrega otros proveedores aquí
      ],
        builder: (context, child) {
          return MyApp();
      }
      )
  );
}

// ignore: must_be_immutable
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
        primaryColor: Colors.indigo,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo
        )
      ),
      initialRoute: isLoggedIn
      ? 'home'
      : 'login',
      routes: {
        'login': ( _ ) => const LoginScreen(),
        'home' : ( _ ) => const Home(),
        'principal' : ( _ ) => const Principal(),
        'mapa' : ( _ ) => const MapResidencial(),
        'registro_usuario' : ( _ ) => const RegistroUsuario(),
        'accesos' : ( _ ) => const Accesos(),
        'pago_completo' : ( _ ) => const PagoCompleto(),
      },
    );
  }

}