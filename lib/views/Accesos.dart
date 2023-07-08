import 'package:flutter/material.dart';
import 'package:standby/model/acceso.dart';

import '../widgets/accesos_radio.dart';

// ignore: must_be_immutable
class Accesos extends StatelessWidget {
  Accesos({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? datos = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    String id = datos!['idResidencial'];
     
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accesos"),
      ),
      body: AccesosRadio(idResidencial: id),
    );
  }
}