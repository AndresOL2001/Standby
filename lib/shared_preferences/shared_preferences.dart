
import 'package:shared_preferences/shared_preferences.dart';

class Preferences{
  static late SharedPreferences _prefs;
  static bool _isLogged = false;

  //Info usuario
  static String _nombreUsuario = "";
  static String _direccionUsuario = "";

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isLogged{
    return _prefs.getBool('isLoggedIn') ?? _isLogged;
  }

  static set isLogged( bool value ){
    _isLogged = value;
    _prefs.setBool('isLoggedIn', value);
  }

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
  
}