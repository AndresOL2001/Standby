import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/usuario_form_provider.dart';
import '../services/auth_service.dart';
import '../ui/input_decorations.dart';

class RegistroUsuario extends StatelessWidget {
  const RegistroUsuario({super.key});

  @override
  Widget build(BuildContext context) {

    final userForm = Provider.of<UserFormProvider>(context);
    final user = userForm.nuevoUsuario;

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
            child: Column(
              children: [
              
                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecorations.authInputDecoration(
                    hintText: '123456',
                    labelText: 'No. de serie',
                    prefixIcon: Icons.numbers
                  ),
                  initialValue: user!.numeroSerie,
                  onChanged: ( value ) => user.numeroSerie = value,
                  validator: ( value ) {
                      String pattern = r'^[0-9]+$';
                      RegExp regExp  = RegExp(pattern);
                      
                      return regExp.hasMatch(value ?? '')
                        ? null
                        : 'El valor ingresado no luce como un numero de serie';
                  },
                ),
                  
                const SizedBox(height: 10),
                  
                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecorations.authInputDecoration(
                    hintText: '123456',
                    labelText: 'No. de celular',
                    prefixIcon: Icons.settings_cell_rounded
                  ),
                  initialValue: user.celular,
                  onChanged: ( value ) => user.celular = value,
                  validator: ( value ) {
                      String pattern = r'^[0-9]{10}$';
                      RegExp regExp  = RegExp(pattern);
                      
                      return regExp.hasMatch(value ?? '')
                        ? null
                        : 'El valor ingresado no luce como un numero telefónico.';
                  },
                ),
                  
                const SizedBox(height: 10),
                  
                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecorations.authInputDecoration(
                    hintText: 'Juan Perez',
                    labelText: 'Primer nombre y apellido',
                    prefixIcon: Icons.text_fields
                  ),
                  initialValue: user.nombreCompleto,
                  onChanged: ( value ) => user.nombreCompleto = value,
                  validator: ( value ) {
                      String pattern = r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$';
                      RegExp regExp  = RegExp(pattern);
                      
                      return regExp.hasMatch(value ?? '')
                        ? null
                        : 'El valor ingresado no luce como un nombre.';
                  },
                ),
                  
                const SizedBox(height: 10),
                  
                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecorations.authInputDecoration(
                    hintText: '1152',
                    labelText: 'Número de casa',
                    prefixIcon: Icons.house
                  ),
                  initialValue: user.numeroCasa,
                  onChanged: ( value ) => user.numeroCasa = value,
                  validator: ( value ) {
                      String pattern = r'^\d{1,4}$';
                      RegExp regExp  = RegExp(pattern);
                      
                      return regExp.hasMatch(value ?? '')
                        ? null
                        : 'El valor ingresado no luce como un numero de casa.';
                  },
                ),
                  
                const SizedBox(height: 10),
                  
                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecorations.authInputDecoration(
                    hintText: 'Matamoros',
                    labelText: 'Calle',
                    prefixIcon: Icons.map
                  ),
                  initialValue: user.calle,
                  onChanged: ( value ) => user.calle = value,
                  validator: ( value ) {
                      String pattern = r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$';
                      RegExp regExp  = RegExp(pattern);
                      
                      return regExp.hasMatch(value ?? '')
                        ? null
                        : 'El valor ingresado no luce como una calle.';
                  },
                ),
                  
                const SizedBox(height: 10),
                  
                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecorations.authInputDecoration(
                    hintText: '*****',
                    labelText: 'Contraseña',
                    prefixIcon: Icons.lock
                  ),
                  initialValue: user.contrasena,
                  onChanged: ( value ) => user.contrasena = value,
                  validator: ( value ) {
                    return ( value != null && value.length >= 6 ) 
                    ? null
                    : 'La contraseña debe de ser de 6 caracteres';
                  },
                ),
          
                const SizedBox(height: 20),
          
                MaterialButton(
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
                )
                  
              ],
            ),
          ),
        ),
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