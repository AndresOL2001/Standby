
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:standby/widgets/listtile_sliver.dart';

import '../model/nuevo_usuario.dart';
import '../provider/usuario_form_provider.dart';
import '../services/auth_service.dart';
import '../shared_preferences/shared_preferences.dart';

class CustomSliverList extends StatefulWidget {
  const CustomSliverList({super.key});

  @override
  State<CustomSliverList> createState() => _CustomSliverListState();
}

class _CustomSliverListState extends State<CustomSliverList> {
  @override
  Widget build(BuildContext context) {
    final userForm = Provider.of<UserFormProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    return SliverList(

// --------------- LISTA DE OPCIONES -----------------

      delegate: SliverChildListDelegate(
        <Widget>[

          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                const Text("Hablitar/Deshabilitar"),
                Switch.adaptive(
                  value: Preferences.isAvailable, 
                  onChanged: (value){
                    Preferences.isAvailable = value;
                    setState(() {
                      
                    });
                    //print("---- Estado:  ${Preferences.isAvailable}");
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

          ListTileSliver(
            icono: Icons.edit_document, 
            titulo: "Editar información de registro", 
            onTapFunction: () async { 
              final String? data = await authService.getUserInfo( Preferences.celularUsuario );
              Map<String, dynamic> infoUser = jsonDecode(data!);

              userForm.nuevoUsuario = NuevoUsuario(
                idUsuario: infoUser["idUsuario"], 
                numeroSerie: "", 
                nombreCompleto: utf8.decode(infoUser["nombreCompleto"].runes.toList()), 
                calle: utf8.decode(infoUser["calle"].runes.toList()), 
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
            }
          ),

          ListTileSliver(
            icono: Icons.door_back_door, 
            titulo: "Accesos", 
            onTapFunction: () => Navigator.pushNamed(context, 'accesos', arguments: { 'idResidencial': Preferences.idResidencial })
          ),

          ListTileSliver(
            icono: Icons.info, 
            titulo: "Info", 
            onTapFunction: () {}
          ),

          ListTileSliver(
            icono: Icons.help, 
            titulo: "Ayuda", 
            onTapFunction: () {}
          ),

          ListTileSliver(
            icono: Icons.map, 
            titulo: "Mapa", 
            onTapFunction: () => Navigator.pushNamed(context, 'mapa')
          ),

          ListTileSliver(
            icono: Icons.logout, 
            titulo: "Cerrar sesión", 
            onTapFunction: () {
              Preferences.isLogged = false;
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, 'login'); 
            }
          ),

        ]
        
      )
    );
  }
}