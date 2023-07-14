
import 'package:shared_preferences/shared_preferences.dart';

class Preferences{
  static late SharedPreferences _prefs;

  //Login
  static bool _isLogged = false;

  //Info usuario
  static String _nombreUsuario = "";
  static String _direccionUsuario = "";
  static String _celularUsuario = "";
  static String _idResidencial = "";

  //Funcion habilitar y deshabilitar
  static bool _isAvailable = false;

  //Mapa
  static double _latitudResidencial = 0;
  static double _longitudResidencial = 0;

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

   // ------------------- RESIDENCIAL -------------------
    static String get idResidencial{
      return _prefs.getString('idResidencial') ?? _idResidencial;
    }

  static set idResidencial( String value ){
    _idResidencial = value;
    _prefs.setString('idResidencial', value);
  }

  // ------------------- HABILITAR / DESHABILITAR ------------------------------
  static bool get isAvailable{
    return _prefs.getBool('isAvailable') ?? _isAvailable;
  }

  static set isAvailable( bool value ){
    _isAvailable = value;
    _prefs.setBool('isAvailable', value);
  }

  // ------------------ MAPA -------------------------
  static double get latitudResidencial{
    return _prefs.getDouble('latitudResidencial') ?? _latitudResidencial;
  }

  static set latitudResidencial( double value ){
    _latitudResidencial = value;
    _prefs.setDouble('latitudResidencial', value);
  }

  static double get longitudResidencial{
    return _prefs.getDouble('longitudResidencial') ?? _longitudResidencial;
  }

  static set longitudResidencial( double value ){
    _longitudResidencial = value;
    _prefs.setDouble('longitudResidencial', value);
  }
  
}