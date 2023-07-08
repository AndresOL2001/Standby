import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/acceso.dart';
import '../services/auth_service.dart';

class AccesosRadio extends StatefulWidget {
  final String idResidencial;
  const AccesosRadio({super.key, required this.idResidencial});

  @override
  State<AccesosRadio> createState() => _AccesosRadio();
}

class _AccesosRadio extends State<AccesosRadio> {

  List<Map<String, dynamic>> selectedItems = [];
  double precioTotal = 0;

  @override
  Widget build(BuildContext context) {
    

    return FutureBuilder<List<Acceso>>(
      future: consultaAccesos(widget.idResidencial),
      builder: (context, snapshot ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los datos'));
        } else {

          precioTotal = selectedItems.fold(0.0, (previousValue, map) => previousValue + (map['precio'] as double));

          return Column(
            children:[ 
              _listaAccesos(context, snapshot),

              Text(
                "Precio total: $precioTotal",
                style: const TextStyle( fontSize: 16 ),
              )
            ]
          );

        }
      },
    );
  }

  SizedBox _listaAccesos(BuildContext context, AsyncSnapshot<List<Acceso>> snapshot) {
    return SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: snapshot.data!
                    .map((acceso) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: CheckboxListTile(
                            value: selectedItems.any((element) => element["idAcceso"] == acceso.idAcceso),
                            onChanged: (value) {
                                setState(() {
                                  if (value!) {
                                    selectedItems.add({ "idAcceso": acceso.idAcceso, "precio" : acceso.precio });
                                  } else {
                                    selectedItems.removeWhere((item) => item['idAcceso'] == acceso.idAcceso);
                                  }
                                });
                            },
                            title: Text(acceso.nombre),
                            subtitle: Text(acceso.direccion),
                            secondary: Text('\$ ${acceso.precio} MXN'),
                          ),
                        ))
                    .toList(),
              ),
            );
  }

  Future<List<Acceso>> consultaAccesos(String idResidencial) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    return await authService.getAccesos(idResidencial);
  }
}