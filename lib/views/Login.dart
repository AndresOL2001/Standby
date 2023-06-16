// ignore: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:standby/model/nuevo_usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';

import '../provider/providers.dart';

import '../services/auth_service.dart';
import '../ui/input_decorations.dart';

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
          
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.phone,
            decoration: InputDecorations.authInputDecoration(
              hintText: '1122334455 (10 dígitos)',
              labelText: 'Número de celular',
              prefixIcon: Icons.numbers
            ),
            onChanged: ( value ) => loginForm.celular = value,
            validator: ( value ) {

                String pattern = r'^[0-9]{10}$';
                RegExp regExp  = RegExp(pattern);
                
                return regExp.hasMatch(value ?? '')
                  ? null
                  : 'El valor ingresado no luce como un número de celular';

            },
          ),

          const SizedBox( height: 30 ),

          TextFormField(
            autocorrect: false,
            obscureText: true,
            keyboardType: TextInputType.text,
            decoration: InputDecorations.authInputDecoration(
              hintText: '*****',
              labelText: 'Contraseña',
              prefixIcon: Icons.lock_outline
            ),
            onChanged: ( value ) => loginForm.password = value,
            validator: ( value ) {

                return ( value != null && value.length >= 6 ) 
                  ? null
                  : 'La contraseña debe de ser de 6 caracteres';                                    
                
            },
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
                Preferences.isLogged = true;
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

              // ignore: use_build_context_synchronously
              //Navigator.pushReplacementNamed(context, 'home');
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