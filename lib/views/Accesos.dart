import 'package:flutter/material.dart';

import '../widgets/accesos_radio.dart';

// ignore: must_be_immutable
class Accesos extends StatelessWidget {
  const Accesos({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? datos = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    String id = datos!['idUsuario'];
     
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accesos"),
      ),
      body: AccesosRadio(idUsuario: id),
    );
  }
}