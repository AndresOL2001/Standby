import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_stripe/flutter_stripe.dart' as fs;

import '../model/stripe_custom_response.dart';

class StripeService{

  //singleton
  StripeService._privateConstructor();
  static final StripeService _instance = StripeService._privateConstructor();
  factory StripeService() => _instance;

  final String _paymentApiUrl = 'https://api.stripe.com/v1/payment_intents';
  static const String _secretKey = 'sk_test_51NgIgBDxEzW2L8puqgMtlsnoyd0BQWO7J3BArBj56Sl0LlBphTgQQ0yjM5m0OzlsV8lc38nyGAAwb6LNYogLxtAj00R4WPWxZN';
  final String _apiKey = 'pk_test_51NgIgBDxEzW2L8puKidxqRts08Lv8LUeRjdpOYolNBs7NJwtbIWEZUc1HPlalvodu6goeh6z0eCypyMsuuM7rQoH00wH1tUFZj';

  Map<String, dynamic>? paymentIntent;

  void init(){
    fs.Stripe.publishableKey = _apiKey;
  }

  Future pagarConTarjetaExistente({
    required String amount,
    required String currency,
    required fs.Card card
  }) async{
    
  }

  Future pagarApplePayGooglePay({
    required String amount,
    required String currency
  }) async{

  }

  crearPaymentIntent({
    required String amount,
    required String currency
  }) async{

    try{
      // );

      // return PaymentIntentResponse.fromJson(response.data);

      http.Response response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: {
          "amount": amount,
          "currency": currency
        },
        headers: {
          "Authorization":"Bearer sk_test_51NgIgBDxEzW2L8puqgMtlsnoyd0BQWO7J3BArBj56Sl0LlBphTgQQ0yjM5m0OzlsV8lc38nyGAAwb6LNYogLxtAj00R4WPWxZN",
          "Content-Type":"application/x-www-form-urlencoded"
        }
      );

      return jsonDecode(response.body);

    } catch (e) {
      print("ERROR: ${ e.toString() }");
    }
      
  }

  void displayPaymentSheet(){
    try {
      fs.Stripe.instance.presentPaymentSheet();
      fs.Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      print("Errorrr: ${e.toString()}");
    }
  } //fin metodo



  Future<StripeCustomResponse> makePayment({
    required BuildContext context,
    required String amount,
    required double numericAmount,
    required String currency,
    required List<Map<String, dynamic>> idAccesos,
    required String idUsuario
  }) async{
    try {
      paymentIntent = await crearPaymentIntent( amount: amount, currency: currency );

      var gpay = fs.PaymentSheetGooglePay(
        merchantCountryCode: "MX",
        currencyCode: currency,
        testEnv: true
      );
      await fs.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: fs.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "Stand By",
          googlePay: gpay,
        )
      ).then((value) => {});

      //displayPaymentSheet();

      await fs.Stripe.instance.presentPaymentSheet().then(( (value) => {
        idAccesos.forEach((Map<String, dynamic> acceso) {
          final errorMessage = createPago(acceso["idAcceso"], idUsuario, acceso['precio']);
          if( errorMessage != null ){
            print("Error: $errorMessage");
          }
        }),
        Navigator.pushReplacementNamed(context, 'pago_completo', arguments: {
          'listaAccesos': idAccesos,
          'total' : numericAmount
        })
      }));

      return StripeCustomResponse(ok: true);


    } catch (e) {
      print("ERROR ${e.toString()}");
      return StripeCustomResponse(ok: false, msg: e.toString());
    }

  }


  Future<String?> createPago( String idAcceso, String idUsuario, double cantidad ) async{

    final Map<String, dynamic> pago ={
      'idAcceso': idAcceso,
      'idUsuario': idUsuario,
      'cantidad': cantidad
    };

    final url = Uri.parse('http://146.190.52.172/api/pagos');
    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final resp = await http.post(url, headers: headers, body: json.encode(pago));

    if (resp.statusCode == 200) {
      return null;
    } else {
      return resp.body;
    }

  } // fin metodo

  // ----------------------------------------- COOMPRAR LINKS -----------------------------------------

    Future<String?> pagoLinks( String idUsuario ) async{

    final url = Uri.parse('http://146.190.52.172/api/accesos/compartir/comprar/$idUsuario');
    final headers = {"Content-Type": "application/json;charset=UTF-8"};

    final resp = await http.post(url, headers: headers);

    if (resp.statusCode == 200){
      return null;
    } else {
      return resp.body;
    }

  } // fin metodo

  Future<StripeCustomResponse> makePaymentLinks({
    required BuildContext context,
    required String amount,
    required double numericAmount,
    required String currency,
    required String idUsuario
  }) async{
    try {
      paymentIntent = await crearPaymentIntent( amount: amount, currency: currency );

      var gpay = fs.PaymentSheetGooglePay(
        merchantCountryCode: "MX",
        currencyCode: currency,
        testEnv: true
      );
      await fs.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: fs.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "Stand By",
          googlePay: gpay,
        )
      ).then((value) => {});

      //displayPaymentSheet();

      await fs.Stripe.instance.presentPaymentSheet().then(( (value) => {
          pagoLinks(idUsuario),
          print("$idUsuario"),

          showDialog(
            context: context, 
            builder: (BuildContext context){
              return const  AlertDialog(
                title: Text("OK"),
                content: Text("Los links seran agregados en breve."),
              );
            }
          )

      }));

      return StripeCustomResponse(ok: true);


    } catch (e) {
      print("ERROR ${e.toString()}");
      return StripeCustomResponse(ok: false, msg: e.toString());
    }

  }

}