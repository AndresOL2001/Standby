
import 'package:shared_preferences/shared_preferences.dart';

class Preferences{
  static late SharedPreferences _prefs;
  static bool _isLogged = false;

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
  
}