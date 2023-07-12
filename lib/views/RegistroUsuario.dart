import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';

import '../provider/usuario_form_provider.dart';
import '../services/auth_service.dart';
import 'package:standby/model/nuevo_usuario.dart';

import '../widgets/textfield_registro.dart';

class RegistroUsuario extends StatefulWidget {
  const RegistroUsuario({super.key});

  @override
  State<RegistroUsuario> createState() => _RegistroUsuarioState();
}

class _RegistroUsuarioState extends State<RegistroUsuario> {
  @override
  Widget build(BuildContext context) {

    final userForm = Provider.of<UserFormProvider>(context);
    final user = userForm.nuevoUsuario;

    final Map<String, dynamic>? datos = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: userForm.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: _textFieldsRegistro(datos, user, userForm, context),
          ),
        ),
      ),
    );
  }

  Column _textFieldsRegistro(Map<String, dynamic>? datos, NuevoUsuario? user, UserFormProvider userForm, BuildContext context) {
    return Column(
            children: [
            
              datos?['tipo'] == "editar"
              ? const SizedBox( height: 0 )
              : TextFieldRegistro(
                  obscureText: false,
                  tipoTexto: TextInputType.number, 
                  textoHint: '123456',
                  textoLabel: 'No. de serie', 
                  icono: Icons.numbers, 
                  initialValue: user!.numeroSerie,
                  funcionOnChange: (value) => user.numeroSerie = value, 
                  patron: r'^[0-9]+$', 
                  mensajeError: 'El valor ingresado no luce como un numero de serie'
                ),
                
              const SizedBox(height: 10),
                

              TextFieldRegistro(
                  obscureText: false,
                  tipoTexto: TextInputType.phone, 
                  textoHint: '123456',
                  textoLabel: 'No. de celular', 
                  icono: Icons.settings_cell_rounded, 
                  initialValue: user!.celular,
                  funcionOnChange: (value) => user.celular = value, 
                  patron: r'^[0-9]{10}$', 
                  mensajeError: 'El valor ingresado no luce como un numero telefónico.'
              ),
                
              const SizedBox(height: 10),

              TextFieldRegistro(
                  obscureText: false,
                  tipoTexto: TextInputType.text, 
                  textoHint: 'John Doe',
                  textoLabel: 'Nombre y apellidos', 
                  icono: Icons.text_fields, 
                  initialValue: user.nombreCompleto,
                  funcionOnChange: (value) => user.nombreCompleto = value, 
                  patron: r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$', 
                  mensajeError: 'El valor ingresado no luce como un nombre.'
              ),
                
              const SizedBox(height: 10),

              TextFieldRegistro(
                  obscureText: false,
                  tipoTexto: TextInputType.number, 
                  textoHint: '1468',
                  textoLabel: 'Número de casa', 
                  icono: Icons.house, 
                  initialValue: user.numeroCasa,
                  funcionOnChange: (value) => user.numeroCasa = value, 
                  patron: r'^\d{1,4}$', 
                  mensajeError: 'El valor ingresado no luce como un numero de casa.'
              ),
                
              const SizedBox(height: 10),

              TextFieldRegistro(
                  obscureText: false,
                  tipoTexto: TextInputType.text, 
                  textoHint: 'Matamoros',
                  textoLabel: 'Calle', 
                  icono: Icons.map, 
                  initialValue: user.calle,
                  funcionOnChange: (value) => user.calle = value, 
                  patron: r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$', 
                  mensajeError: 'El valor ingresado no luce como una calle.'
              ),
                
              const SizedBox(height: 10),

              TextFieldRegistro(
                  obscureText: false,
                  tipoTexto: TextInputType.text, 
                  textoHint: '*****',
                  textoLabel: 'Contraseña', 
                  icono: Icons.lock, 
                  initialValue: user.contrasena,
                  funcionOnChange: (value) => user.contrasena = value, 
                  patron:  r'^.{6,}$', 
                  mensajeError: 'La contraseña debe de ser de 6 caracteres.'
              ),
        
              const SizedBox(height: 20),

              datos?['tipo'] == "editar"
              ? _editarButton(userForm, context, user, datos?['numeroSerie'] ,datos?['idUsuario'])
              : _registrarButton(userForm, context, user)
                
            ],
          );
  }

  MaterialButton _registrarButton(UserFormProvider userForm, BuildContext context, NuevoUsuario user) {
    return MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.indigo,
                onPressed: userForm.isLoading 
                ? null 
                : () async{
                    FocusScope.of(context).unfocus();
                    final authService = Provider.of<AuthService>(context, listen: false);
                    if( !userForm.isValidForm() ) return;

                    userForm.isLoading = true;

                    final String? errorMessage = await authService.createUser(
                      user.numeroSerie, 
                      user.nombreCompleto,
                      user.calle,
                      user.numeroCasa,
                      user.celular,
                      user.contrasena,
                    );

                    if( errorMessage == null ){

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);

                      Preferences.nombreUsuario = user.nombreCompleto;
                      Preferences.celularUsuario = user.celular;
                      Preferences.direccionUsuario = "${user.calle} ${user.numeroCasa}";

                      userForm.isLoading = false;
                    } else{
                      userForm.isLoading = false;
                      // ignore: use_build_context_synchronously
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _alertError(context, "No existe una residencial con ese numero de serie.");
                        }
                      );
                    }

                },
                child: Container(
                  padding: const EdgeInsets.symmetric( horizontal: 80, vertical: 15 ),
                  child: Text(
                    userForm.isLoading 
                    ? 'Espere'
                    : 'Registrarse',
                    style: const TextStyle( color: Colors.white ),
                  )
                ),
              );
  }

  MaterialButton _editarButton(UserFormProvider userForm, BuildContext context, NuevoUsuario user, String numeroSerie, String idUsuario) {
    return MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.indigo,
                onPressed: userForm.isLoading 
                ? null 
                : () async{
                    FocusScope.of(context).unfocus();
                    final authService = Provider.of<AuthService>(context, listen: false);
                    if( !userForm.isValidForm() ) return;

                    userForm.isLoading = true;

                    final String? errorMessage = await authService.editUser(
                      numeroSerie,
                      idUsuario, 
                      user.nombreCompleto,
                      user.calle,
                      user.numeroCasa,
                      user.celular,
                      user.contrasena,
                    );

                    if( errorMessage == null ){
                      setState(() {
                        Preferences.nombreUsuario = user.nombreCompleto;
                        Preferences.direccionUsuario = "${user.calle} ${user.numeroCasa}";
                        Preferences.celularUsuario = user.celular;
                      });
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, 'home');
                      userForm.isLoading = false;
                    } else{
                      userForm.isLoading = false;
                      // ignore: use_build_context_synchronously
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _alertError(context, errorMessage);
                        }
                      );
                    }

                },
                child: Container(
                  padding: const EdgeInsets.symmetric( horizontal: 80, vertical: 15 ),
                  child: Text(
                    userForm.isLoading 
                    ? 'Espere'
                    : 'Editar',
                    style: const TextStyle( color: Colors.white ),
                  )
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