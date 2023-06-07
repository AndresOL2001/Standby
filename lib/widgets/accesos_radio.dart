import 'package:flutter/material.dart';

import '../model/acceso.dart';

class AccesosRadio extends StatefulWidget {
  const AccesosRadio({super.key});

  @override
  State<AccesosRadio> createState() => _AccesosRadio();
}

class _AccesosRadio extends State<AccesosRadio> {

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
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: accesos
            .map((acceso) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: RadioListTile<Acceso>(
                    value: acceso,
                    groupValue: selectedValue,
                    title: Text(acceso.nombre),
                    subtitle: Text(acceso.ubicacion),
                    onChanged: (value) => setState(() => selectedValue = value!),
                  ),
                ))
            .toList()
  );
}