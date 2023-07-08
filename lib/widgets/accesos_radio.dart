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

  //Acceso selectedValue = accesos.first;
  static List<Acceso>? selectedValues = [];

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
        List<dynamic>? accesos = snapshot.data!;
        List<dynamic>? selectedValues = [];

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: ( BuildContext context, int index) {
            return CheckboxListTile(
              value: snapshot.data![index].isSelected, 
              onChanged: (value) {
                          snapshot.data![index].isSelected = value;
                            snapshot.data![index].isSelectedd = value!;
                      },
                      title: Text(snapshot.data![index].nombre),
                      subtitle: Text(snapshot.data![index].direccion),
                      secondary: Text('\$ ${snapshot.data![index].precio} MXN'),
            );
          }
        );

        //return Text("Hola");

        // return ListView(
        //   padding: const EdgeInsets.symmetric(vertical: 16),
        //   children: accesos!
        //       .map((acceso) => Container(
        //             margin: const EdgeInsets.only(bottom: 16),
        //             child: CheckboxListTile(
        //               value: selectedValues.contains(acceso),
        //               onChanged: (value) {
        //                   print(value);
        //                   if (value!) {
        //                     selectedValues.add(acceso);
        //                   } else {
        //                     selectedValues.removeWhere((item) => item.idAcceso == acceso['idAcceso']);
        //                   }
        //               },
        //               title: Text(acceso.nombre),
        //               subtitle: Text(acceso.direccion),
        //               secondary: Text('\$ ${acceso.precio} MXN'),
        //             ),
        //           ))
        //       .toList(),
        // );

      }
    },
  );
}

  Future<List<Acceso>> consultaAccesos(String idResidencial) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    return await authService.getAccesos(idResidencial);
  }
}