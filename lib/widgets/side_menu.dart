import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';

import '../model/nuevo_usuario.dart';
import '../provider/usuario_form_provider.dart';
import '../services/auth_service.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    final userForm = Provider.of<UserFormProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _DrawerHeader(),

          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                const Text("Hablitar/Deshabilitar"),
                Switch.adaptive(
                  value: Preferences.isAvailable, 
                  onChanged: (value){
                    Preferences.isAvailable = value;
                    //print("---- Estado:  ${Preferences.isAvailable}");
                    setState(() { });
                  }
                )
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
            child: Text(
              "Administracion", 
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500
              )
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: (){},
          ),

          ListTile(
            leading: const Icon(Icons.edit_document),
            title: const Text("Editar información de registro"),
            onTap: () async { 
              final String? data = await authService.getUserInfo( Preferences.celularUsuario );
              Map<String, dynamic> infoUser = jsonDecode(data!);

              userForm.nuevoUsuario = NuevoUsuario(
                idUsuario: infoUser["idUsuario"], 
                numeroSerie: "", 
                nombreCompleto: utf8.decode(infoUser["nombreCompleto"].runes.toList()), 
                calle: infoUser["calle"], 
                numeroCasa: infoUser["numeroCasa"], 
                celular: infoUser["celular"], 
                contrasena: "", 
              );

              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, 'registro_usuario', arguments: { 
                'tipo': 'editar', 
                'numeroSerie': infoUser["residencial"]["numeroSerie"], 
                'idUsuario': infoUser["idUsuario"] 
                }); 
            },
          ),

          ListTile(
            leading: const Icon(Icons.door_back_door),
            title: const Text("Accesos"),
            onTap: (){ Navigator.pushNamed(context, 'accesos'); },
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Info"),
            onTap: (){},
          ),

          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Ayuda"),
            onTap: (){},
          ),

          ListTile(
            leading: const Icon(Icons.map),
            title: const Text("Mapa"),
            onTap: (){ Navigator.pushNamed(context, 'mapa'); },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Cerrar sesión"),
            onTap: () async {
              Preferences.isLogged = false;
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, 'login'); 
            },
          ),


        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/menu-img.jpg'),
          fit: BoxFit.cover
        )
      ),
      child: Container(),
    );
  }
}