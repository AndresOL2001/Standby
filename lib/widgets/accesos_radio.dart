
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/alertas.dart';
import '../model/acceso_usuario.dart';
import '../services/auth_service.dart';

import 'package:standby/services/stripe_service.dart';

class AccesosRadio extends StatefulWidget {
  final String idUsuario;
  
  const AccesosRadio({super.key, required this.idUsuario});
  @override
  State<AccesosRadio> createState() => _AccesosRadio();
}

class _AccesosRadio extends State<AccesosRadio> {

  List<Map<String, dynamic>> selectedItems = [];
  double precioTotal = 0;

  @override
  Widget build(BuildContext context) {
    

    return FutureBuilder<List<AccesoUsuario>>(
      future: consultaAccesos(widget.idUsuario),
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
                "Precio total: \$ $precioTotal MXN",
                style: const TextStyle( fontSize: 16 ),
              ),

              const SizedBox( height: 20 ),

              ( precioTotal > 0 ) 
              ? _buttonPay( amount: precioTotal )
              : const Text("Selecciona minimo 1 acceso")
              

            ]
          );

        }
      },
    );
  }

  SizedBox _listaAccesos(BuildContext context, AsyncSnapshot<List<AccesoUsuario>> snapshot) {
    return SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: snapshot.data!
                    .map((acceso) =>
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: 
                        ( !acceso.active )
                        ? CheckboxListTile(
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
                          )
                        : ListTile(
                          leading: const Icon( Icons.check ),
                          title: Text( acceso.direccion ),
                        )
                      )
                    )
                    .toList(),
              ),
            );
  }

  Future<List<AccesoUsuario>> consultaAccesos(String idUsuario) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    return await authService.getAccesosUsuario(idUsuario);
  }
}

class _buttonPay extends StatelessWidget {

  final double amount;

  _buttonPay({
    required this.amount,
  });

final stripeService = StripeService();

  Map<String, dynamic>? paymentIntent;

  

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Container(
        padding: const EdgeInsets.only( left: 15, right: 15 ),
        child: ElevatedButton(
          onPressed: () async {
              
            try{
              final response = await stripeService.makePayment(
                amount: '${ (amount * 100).floor() }', 
                currency: "MXN"
              );

              if( response.ok ){
                print("Se hizo");
              }
            
            } catch(e){
              mostrarAlerta(context, "Epa", e.toString());
            }
                    
          }, 
          child: const Text("Pagar", style: TextStyle( fontSize: 16 ), )
        ),
      ),
    );
  }
}