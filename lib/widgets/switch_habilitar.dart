import 'package:flutter/material.dart';

class SwtichHabilitar extends StatefulWidget {
  const SwtichHabilitar({super.key});

  @override
  State<SwtichHabilitar> createState() => _SwtichHabilitarState();
}

class _SwtichHabilitarState extends State<SwtichHabilitar> {
  bool isActive = true;
  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: isActive, 
      onChanged: (value){
        setState(() { isActive = value; });
      }
    );
  }
}