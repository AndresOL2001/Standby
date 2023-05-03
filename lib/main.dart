import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:standby/services/NotificationsServices.dart';

import '../src/views/Map.dart';

late SharedPreferences sharedPreferences;

void main() async{
  //Para las notificaciones se hizo async el metodo main

  //Para ejecutar las inicializaciones de las notificaciones
  WidgetsFlutterBinding();
  await initNotifications();
  // ------------------------------------------------------

  //Correr la app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stand By',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const Map(),
    );
  }
}