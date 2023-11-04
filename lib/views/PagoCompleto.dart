import 'package:flutter/material.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';

class PagoCompleto extends StatelessWidget {
  const PagoCompleto({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? datos = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final List listaAccesos = datos!['listaAccesos'];
    final total = datos['total'];
    final nombreUsuario = Preferences.nombreUsuario;

    return Scaffold(
      body: Column(
          children: [

            const SafeArea(child: Icon( Icons.check_circle, size: 132, color: Colors.indigo )),
          
            const SizedBox( height: 10 ),

            Text( "Cliente: $nombreUsuario", style: const TextStyle( fontSize: 24 )),

            const SizedBox( height: 10 ),

            Text( "Total: \$$total MXN", style: const TextStyle( fontSize: 24 ) ),

            _AccesosComprados(listaAccesos: listaAccesos),

            Container(
              margin: const EdgeInsets.all(5),
              child: MaterialButton(
                padding: const EdgeInsets.symmetric( horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed: () => Navigator.pop(context), 
                color: Colors.indigo,
                child: const Text("Continuar", style: TextStyle( fontSize: 16, color: Colors.white ),)
              ),
            )

          ],
        ),
    );
  }
}

class _AccesosComprados extends StatelessWidget {
  const _AccesosComprados({
    super.key,
    required this.listaAccesos,
  });

  final List listaAccesos;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
              itemCount: listaAccesos.length,
              itemBuilder: (BuildContext context, int index) {
                final acceso = listaAccesos[index];
                return ListTile(
                  title: Text(acceso['nombre']),
                  trailing: Text("\$${acceso['precio']} MXN"),
                  leading: const Icon(Icons.check, color: Colors.indigo ),
                );
              },
      ),
    );
  }
}