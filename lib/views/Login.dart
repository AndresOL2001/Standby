// ignore: file_names
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:standby/model/nuevo_usuario.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';
import 'package:standby/widgets/textfield_registro.dart';

import '../provider/providers.dart';

import '../services/auth_service.dart';

import '../widgets/auth_background.dart';
import '../widgets/card_container.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userForm = Provider.of<UserFormProvider>(context);

    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox( height: 250 ),

              CardContainer(
                child: Column(
                  children: [

                    const SizedBox( height: 10 ),

                    Text('Iniciar Sesión', style: Theme.of(context).textTheme.headlineMedium ),

                    const SizedBox( height: 30 ),

                    _LoginForm()
                 
                  ],
                )
              ),

              const SizedBox( height: 50 ),
              TextButton(
                onPressed: (){ 
                  userForm.nuevoUsuario = NuevoUsuario(
                    idUsuario: '',
                    numeroSerie: '', 
                    nombreCompleto: '', 
                    calle: '', 
                    numeroCasa: '',
                    celular: '', 
                    contrasena: ''
                  );
                  Navigator.pushNamed(context, 'registro_usuario'); 
                }, 
                child: const Text('Crear una nueva cuenta', style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold )),
              ),
              //const Text('Crear una nueva cuenta', style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold )),
              const SizedBox( height: 50 ),
            ],
          ),
        )
      )
   );
  }
}


class _LoginForm extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final loginForm = Provider.of<LoginFormProvider>(context);

    return Form(
      key: loginForm.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,

      child: Column(
        children: [

          TextFieldRegistro(
            obscureText: false,
            tipoTexto: TextInputType.phone, 
            textoHint: '1122334455 (10 dígitos)', 
            textoLabel: 'Número de celular', 
            icono: Icons.numbers, 
            funcionOnChange: (value) => loginForm.celular = value, 
            patron: r'^[0-9]{10}$', 
            mensajeError: 'El valor ingresado no luce como un número de celular'
          ),

          const SizedBox( height: 30 ),

          TextFieldRegistro(
            obscureText: true,
            tipoTexto: TextInputType.text, 
            textoHint: '*******', 
            textoLabel: 'Contraseña', 
            icono: Icons.lock_outline, 
            funcionOnChange: (value) => loginForm.password = value, 
            patron: r'^.{6,}$', 
            mensajeError: 'La contraseña debe de ser de 6 caracteres'
          ),

          const SizedBox( height: 30 ),

          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.indigo,
            onPressed: loginForm.isLoading 
            ? null 
            : () async {
              
              FocusScope.of(context).unfocus();
              final authService = Provider.of<AuthService>(context, listen: false);
              if( !loginForm.isValidForm() ) return;

              loginForm.isLoading = true;

              final String? errorMessage = await authService.loginUser(
                loginForm.celular, 
                loginForm.password
              );

              if( errorMessage == null ){
                //Para un login persistente
                Preferences.isLogged = true;

                //Obtener info del usuario y la guardamos con shared preferences
                final String? data = await authService.getUserInfo( loginForm.celular );
                Map<String, dynamic> infoUser = jsonDecode(data!);

                //Se actualiza el nombre del usuario y la direccion
                Preferences.nombreUsuario = utf8.decode(infoUser["nombreCompleto"].runes.toList());

                Preferences.idUsuario = infoUser["idUsuario"];
                
                String direccionData = "${infoUser["calle"]} ${infoUser["numeroCasa"]}";
                Preferences.direccionUsuario = utf8.decode(direccionData.runes.toList());
                Preferences.idResidencial = infoUser["residencial"]["idResidencial"];
                Preferences.celularUsuario = loginForm.celular;

                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(context, 'home');
                loginForm.isLoading = false;
              } else{
                loginForm.isLoading = false;
                // ignore: use_build_context_synchronously
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _alertError(context, "Usuario o contraseña incorrectos.");
                  }
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric( horizontal: 80, vertical: 15),
              child: Text(
                loginForm.isLoading 
                  ? 'Espere'
                  : 'Ingresar',
                style: const TextStyle( color: Colors.white ),
              )
            )
          )

        ],
      ),
    );
  }

  _alertError(context, mensaje){
    return AlertDialog(
        title: const Text("Error"),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
  }
}