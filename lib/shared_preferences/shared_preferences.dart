
import 'package:shared_preferences/shared_preferences.dart';

class Preferences{
  static late SharedPreferences _prefs;

  //Login
  static bool _isLogged = false;

  //Info usuario
  static String _nombreUsuario = "";
  static String _direccionUsuario = "";
  static String _celularUsuario = "";

  //Funcion habilitar y deshabilitar
  static bool _isAvailable = false;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ------------------- LOGIN ------------------------------
  static bool get isLogged{
    return _prefs.getBool('isLoggedIn') ?? _isLogged;
  }

  static set isLogged( bool value ){
    _isLogged = value;
    _prefs.setBool('isLoggedIn', value);
  }

  // ------------------- USUARIO -------------------
  static String get nombreUsuario{
    return _prefs.getString('nombreUsuario') ?? _nombreUsuario;
  }

  static set nombreUsuario( String value ){
    _nombreUsuario = value;
    _prefs.setString('nombreUsuario', value);
  }

  static String get direccionUsuario{
    return _prefs.getString('direccionUsuario') ?? _direccionUsuario;
  }

  static set direccionUsuario( String value ){
    _direccionUsuario = value;
    _prefs.setString('direccionUsuario', value);
  }

  static String get celularUsuario{
    return _prefs.getString('celularUsuario') ?? _celularUsuario;
  }

  static set celularUsuario( String value ){
    _celularUsuario = value;
    _prefs.setString('celularUsuario', value);
  }

  // ------------------- HABILITAR / DESHABILITAR ------------------------------
  static bool get isAvailable{
    return _prefs.getBool('isAvailable') ?? _isAvailable;
  }

  static set isAvailable( bool value ){
    _isAvailable = value;
    _prefs.setBool('isAvailable', value);
  }
  
}