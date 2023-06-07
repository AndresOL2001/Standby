import 'package:flutter/material.dart';

class Acceso {
  final String nombre;
  final String ubicacion;

  const Acceso({ 
    required this.nombre, 
    required this.ubicacion 
  });

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
      other is Acceso &&
              runtimeType == other.runtimeType &&
              nombre == other.nombre &&
              ubicacion == other.ubicacion;

  @override
  int get hashCode => nombre.hashCode ^ ubicacion.hashCode;

}