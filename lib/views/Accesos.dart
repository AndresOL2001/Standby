import 'package:flutter/material.dart';
import 'package:standby/model/acceso.dart';

import '../widgets/accesos_radio.dart';

// ignore: must_be_immutable
class Accesos extends StatelessWidget {
  Accesos({super.key});

  static const accesos = [
    Acceso(
      nombre: "Acceso 1", 
      ubicacion: "Camino del rey"
    ),
    Acceso(
      nombre: "Acceso 2", 
      ubicacion: "Camino del alamo"
    ),
    Acceso(
      nombre: "Acceso 3", 
      ubicacion: "Piedra bola"
    ),
  ];

  Acceso selectedValue = accesos.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accesos"),
      ),
      body: const AccesosRadio(),
    );
  }
}