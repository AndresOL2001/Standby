import 'package:flutter/material.dart';

class ListTileSliver extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Function onTapFunction;

  const ListTileSliver({super.key, 
    required this.icono, 
    required this.titulo, 
    required this.onTapFunction,
  });

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: const EdgeInsets.all(15),
      child: ListTile(
              leading: Icon(icono),
              title: Text(titulo),
              onTap: onTapFunction as void Function(),
            ),
    );
  }
}