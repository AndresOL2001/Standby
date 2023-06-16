import 'package:flutter/material.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';
import 'package:standby/widgets/side_menu.dart';


class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    String nombreUsuario = Preferences.nombreUsuario;
    String direccionUsuario = Preferences.direccionUsuario;


    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        elevation: 0,
        child: const Icon(Icons.share),
      ),
      drawer: const SideMenu(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    _InfoUser(topico: "Usuario: ", info: nombreUsuario),
                    _InfoUser(topico: "No. Serie Activado: ", info: direccionUsuario),
                    const _InfoUser(topico: "Plan vigente", info: ""),
                  ],
                ),
              ),

              const _BotonAbrir(),

            ],
          ),
        ),
     ),
   );
  }
}

class _BotonAbrir extends StatelessWidget {
  const _BotonAbrir({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        fixedSize: const Size(double.maxFinite, 50),
        textStyle: const TextStyle(fontSize: 20)
      ),
      onPressed: (){}, 
      child: const Text("Abrir")
    );
  }
}

class _InfoUser extends StatelessWidget {

  final String topico;
  final String info;

  const _InfoUser({
    required this.topico,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          topico, 
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold
          ),
        ),
        Expanded(child: Text(info, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)))
      ],
    );
  }
}