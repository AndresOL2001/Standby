import 'package:flutter/material.dart';

import '../ui/input_decorations.dart';

class RegistroUsuario extends StatelessWidget {
  const RegistroUsuario({super.key});

  @override
  Widget build(BuildContext context) {

    String variable = "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: const Key("registrar"),
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
                  onChanged: ( value ) => variable = value,
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
                  onChanged: ( value ) => variable = value,
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
                  onChanged: ( value ) => variable = value,
                  validator: ( value ) {
                      String pattern = r'^[a-zA-Z]+$';
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
                  onChanged: ( value ) => variable = value,
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
                  onChanged: ( value ) => variable = value,
                  validator: ( value ) {
                      String pattern = r'^[a-zA-Z]+$';
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
                    hintText: 'Contraseña',
                    labelText: '****',
                    prefixIcon: Icons.lock
                  ),
                  onChanged: ( value ) => variable = value,
                  validator: ( value ) {
                    return ( value != null && value.length >= 6 ) 
                    ? null
                    : 'La contraseña debe de ser de 6 caracteres';
                  },
                ),
          
                const SizedBox(height: 20),
          
                ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        fixedSize: const Size(double.maxFinite, 50),
                        textStyle: const TextStyle(fontSize: 20)
                      ),
                      onPressed: (){}, 
                      child: const Text("Registrar")
                )
                  
              ],
            ),
          ),
        ),
      ),
    );
  }
}