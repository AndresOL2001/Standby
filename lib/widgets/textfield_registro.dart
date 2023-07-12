import 'package:flutter/material.dart';

import '../ui/input_decorations.dart';

class TextFieldRegistro extends StatelessWidget {

  final bool obscureText;
  final TextInputType tipoTexto;
  final String textoHint;
  final String textoLabel;
  final IconData icono;
  final String? initialValue;
  final Function funcionOnChange;
  final String patron;
  final String mensajeError;

  const TextFieldRegistro({
    super.key, 
    required this.obscureText, 
    required this.tipoTexto, 
    required this.textoHint, 
    required this.textoLabel, 
    required this.icono, 
    this.initialValue,
    required this.funcionOnChange, 
    required this.patron, 
    required this.mensajeError
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      autocorrect: false,
      keyboardType: tipoTexto,
      decoration: InputDecorations.authInputDecoration(
        hintText: textoHint,
        labelText: textoLabel,
        prefixIcon: icono
      ),
      initialValue: initialValue,
      onChanged: ( value ) => funcionOnChange(value),
      validator: ( value ) {
          RegExp regExp  = RegExp(patron);
          
          return regExp.hasMatch(value ?? '')
            ? null
            : mensajeError;
      },
    );
  }
}