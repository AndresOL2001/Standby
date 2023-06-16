import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  }

}