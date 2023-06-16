import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:standby/provider/login_form_provider.dart';
import 'package:standby/provider/usuario_form_provider.dart';
import 'package:standby/services/NotificationsServices.dart';
import 'package:standby/services/auth_service.dart';

import 'package:standby/widgets/screens.dart';

import 'views/Map.dart';

late SharedPreferences sharedPreferences;

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
  sharedPreferences = await SharedPreferences.getInstance();

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
          return const MyApp();
      }
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
            initialRoute: 'login',
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