import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/acceso.dart';
import '../model/acceso_usuario.dart';

class AuthService extends ChangeNotifier{
  final String _baseUrl = 'http://24.199.122.158:5000';


  Future<String?> createUser( String numeroSerie, String nombreCompleto, String calle, String numeroCasa, String celular, String contrasena ) async{

    final Map<String, dynamic> authData ={
      'numeroSerie': numeroSerie,
      'nombreCompleto': nombreCompleto,
      'calle': calle,
      'numeroCasa': numeroCasa,
      'celular': celular,
      'contraseña': contrasena,
    };

    final url = Uri.parse('$_baseUrl/api/auth/registro');
    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final resp = await http.post(url, headers: headers, body: json.encode(authData));

    if (resp.statusCode == 200) {
      return null;
    } else {
      return resp.body;
    }

  } // fin metodo

  Future<String?> loginUser( String celular, String contrasena ) async{

    final Map<String, dynamic> authData ={
      'celular': celular,
      'contraseña': contrasena,
    };

    final url = Uri.parse('$_baseUrl/api/auth/login');
    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final resp = await http.post(url, headers: headers, body: json.encode(authData));

    if (resp.statusCode == 200) {
      //Shared preferences para mantener la sesion
      return null;
    } else {
      return resp.body;
    }

  } // fin metodo

  Future<String?> getUserInfo( String celular ) async{

    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final url = Uri.parse('$_baseUrl/api/auth/$celular');

    final resp = await http.get(url, headers: headers);

    return resp.body;

    // if (resp.statusCode == 200) {
    //   //Shared preferences para mantener la sesion
    //   return null;
    // } else {
    //   return resp.body;
    // }

  } // fin metodo

  Future<String?> editUser( String numeroSerie, String idUsuario, String nombreCompleto, String calle, String numeroCasa, String celular, String contrasena ) async{

    final Map<String, dynamic> authData ={
      'numeroSerie': numeroSerie,
      'nombreCompleto': nombreCompleto,
      'calle': calle,
      'numeroCasa': numeroCasa,
      'celular': celular,
      'contraseña': contrasena,
    };

    final url = Uri.parse('$_baseUrl/api/auth/usuario/$idUsuario');
    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final resp = await http.put(url, headers: headers, body: json.encode(authData));

    if (resp.statusCode == 200) {
      return null;
    } else {
      return resp.body;
    }

  } // fin metodo

  Future<String?> getResidencial( String idResidencial ) async{

    final url = Uri.parse('$_baseUrl/api/residencial/$idResidencial');
    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final resp = await http.get(url, headers: headers);

    if( resp.statusCode == 200 ){
      return resp.body;
    } else {
      throw Exception('API Error');
    }

  } // fin metodo

  List<Acceso> parseAcceso(String responseBody){
    var list = json.decode(responseBody) as List<dynamic>;
    List<Acceso> accesos = list.map((model) => Acceso.fromJson(model)).toList();
    return accesos;
  } // fin metodo

  List<AccesoUsuario> parseAccesoUsuario(String responseBody){
    var list = json.decode(responseBody) as List<dynamic>;
    List<AccesoUsuario> accesos = list.map((model) => AccesoUsuario.fromJson(model)).toList();
    return accesos;
  } // fin metodo

  Future<List<Acceso>> getAccesos( String idResidencial ) async{

    final url = Uri.parse('$_baseUrl/api/accesos/residencial/$idResidencial');
    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final resp = await http.get(url, headers: headers);

    if( resp.statusCode == 200 ){
      return parseAcceso(resp.body);
    } else {
      throw Exception('API Error');
    }

  } // fin metodo

  Future<List<AccesoUsuario>> getAccesosUsuario( String idUsuario ) async{

    final url = Uri.parse('$_baseUrl/api/accesos/usuario/$idUsuario');
    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final resp = await http.get(url, headers: headers);

    if( resp.statusCode == 200 ){
      return parseAccesoUsuario(resp.body);
    } else {
      throw Exception('API Error');
    }

  } // fin metodo

  Future<String?> getAccesosString( String idResidencial ) async{

    final url = Uri.parse('$_baseUrl/api/accesos/residencial/$idResidencial');
    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final resp = await http.get(url, headers: headers);

    if( resp.statusCode == 200 ){
      return resp.body;
    } else {
      throw Exception('API Error');
    }

  } // fin metodo

}