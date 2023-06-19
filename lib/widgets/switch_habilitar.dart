import 'package:flutter/material.dart';

import '../shared_preferences/shared_preferences.dart';

class SwtichHabilitar extends StatefulWidget {
  const SwtichHabilitar({super.key});

  @override
  State<SwtichHabilitar> createState() => _SwtichHabilitarState();
}

class _SwtichHabilitarState extends State<SwtichHabilitar> {

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: Preferences.isAvailable, 
      onChanged: (value){
        Preferences.isAvailable = value;
        setState(() { });
      }
    );
  }
}