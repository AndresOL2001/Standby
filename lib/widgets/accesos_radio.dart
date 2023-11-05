// ignore_for_file: camel_case_types

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

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
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los datos'));
        } else {
          precioTotal = selectedItems.fold(
              0.0,
              (previousValue, map) =>
                  previousValue + (map['precio'] as double));

          consultaLinksRestantes(Preferences.celularUsuario);

          return Column(children: [
            const SizedBox(height: 25),
            Text(
              "Links restantes: ${Preferences.compartidas}",
              style: const TextStyle(fontSize: 20),
            ),
            (Preferences.compartidas == 0) ? BtnComprarLinks(idUsuario: widget.idUsuario) : const SizedBox(),

            const SizedBox(height: 35),
            _listaAccesos(context, snapshot),
            Text(
              "Precio total: \$ $precioTotal MXN",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            (precioTotal > 0)
                ? _buttonPay(
                    amount: precioTotal,
                    idAccesos: selectedItems,
                    idUsuario: widget.idUsuario)
                : const Text("Selecciona minimo 1 acceso")

          ]);
        }
      },
    );
  }

  Expanded _listaAccesos(
      BuildContext context, AsyncSnapshot<List<AccesoUsuario>> snapshot) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: snapshot.data!
            .map((acceso) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: (!acceso.active)
                    ? CheckboxListTile(
                        value: selectedItems.any((element) =>
                            element["idAcceso"] == acceso.idAcceso),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              selectedItems.add({
                                "idAcceso": acceso.idAcceso,
                                "precio": acceso.precio,
                                'nombre': acceso.nombre
                              });
                            } else {
                              selectedItems.removeWhere((item) =>
                                  item['idAcceso'] == acceso.idAcceso);
                            }
                          });
                        },
                        title: Text(acceso.nombre),
                        subtitle: Text(acceso.direccion),
                        secondary: Text('\$ ${acceso.precio} MXN'),
                      )
                    : accesosDisponibles(acceso, context)))
            .toList(),
      ),
    );
  }

  ListTile accesosDisponibles(AccesoUsuario acceso, BuildContext context) {
    return ListTile(
                      leading: const Icon(Icons.check),
                      title: Text(acceso.nombre),
                      subtitle: Text(acceso.direccion),
                      trailing: TextButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text("Compartir"),
                        onPressed: () {
                          (Preferences.compartidas > 0)
                          ? showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Confirmación"),
                                  // Mensaje
                                  content: const Text(
                                      "¿Estás seguro de que quieres generar un link para compartir el acceso?"),

                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        final idResidencial =
                                            Preferences.idResidencial;
                                        final idUsuario =
                                            Preferences.idUsuario;

                                        //print( "Compartir id Acceso: ${acceso.idAcceso} idResidencial: $idResidencial idUsuario: $idUsuario" );

                                        final authService =
                                            Provider.of<AuthService>(context,
                                                listen: false);

                                        try {
                                          final linkCompartir =
                                              await authService
                                                  .crearLinkCompartir(
                                                      acceso.idAcceso,
                                                      idUsuario,
                                                      idResidencial);
                                          Share.share(
                                              "Direccion: ${acceso.direccion}\nGoogle Maps: https://www.google.com/maps/@${acceso.latitudCaseta},${acceso.longitudCaseta},17z/data=!3m1!4b1 \nLink de acceso: ${linkCompartir!["link"]}");
                                        } catch (e) {
                                          mostrarAlerta(
                                              context, "Epa", e.toString());
                                        }
                                        Preferences.compartidas = Preferences.compartidas-1;
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Si"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Acción al presionar el botón de cancelar
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("No"),
                                    ),
                                  ],
                                );
                              })
                              : showDialog(context: context, 
                                builder: (BuildContext context){
                                  return const AlertDialog(
                                    title: Text("Error"),
                                    content: Text("No cuentas con más enlaces."),
                                  );
                                }
                              );
                        },
                      ));
  }

  Future<List<AccesoUsuario>> consultaAccesos(String idUsuario) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    return await authService.getAccesosUsuario(idUsuario);
  }

  Future<void> consultaLinksRestantes(String celular) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final resp = await authService.getUserInfo(celular);
    final body = jsonDecode(resp!);
    //print("USUARIO ${body['compartidas']}");
    Preferences.compartidas = body['compartidas'];
  }
}

class BtnComprarLinks extends StatelessWidget {

  final String idUsuario;

  BtnComprarLinks({
    required this.idUsuario
  });

  @override
  Widget build(BuildContext context) {
    final stripeService = StripeService();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16.0),
          decoration: const BoxDecoration(
            color: Colors.indigo, // Color de fondo
            borderRadius: BorderRadius.all(Radius.circular(5)),
            shape: BoxShape
                .rectangle, // Opcional: puedes cambiar la forma del fondo
          ),
          child: IconButton(
            onPressed: () async {

              try {
                await stripeService.makePaymentLinks(
                    context: context,
                    amount: '${(50 * 100).floor()}',
                    numericAmount: 30.0,
                    currency: "MXN",
                    idUsuario: idUsuario);
              } catch (e) {
                mostrarAlerta(context, "Epa", e.toString());
              }

            },
            icon: const Icon(Icons.shopping_bag_outlined),
            color: Colors.white, // Color del icono
          ),
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class _buttonPay extends StatelessWidget {
  final double amount;
  final List<Map<String, dynamic>> idAccesos;
  final String idUsuario;

  _buttonPay({
    required this.amount,
    required this.idAccesos,
    required this.idUsuario,
  });

  final stripeService = StripeService();

  Map<String, dynamic>? paymentIntent;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: ElevatedButton(
            onPressed: () async {
              try {
                await stripeService.makePaymentLinks(
                    context: context,
                    amount: '${(amount * 100).floor()}',
                    numericAmount: amount,
                    currency: "MXN",
                    idUsuario: idUsuario);
              } catch (e) {
                mostrarAlerta(context, "Epa", e.toString());
              }
            },
            child: const Text(
              "Pagar",
              style: TextStyle(fontSize: 16),
            )),
      ),
    );
  }
}
