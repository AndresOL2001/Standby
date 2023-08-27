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
    required String amount,
    required String currency,
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
        // TODOOOOO: REGISTRAR QUE EL USUARIO PAGO
        print("Exito papu")
      }));

      return StripeCustomResponse(ok: true);


    } catch (e) {
      print("ERROR ${e.toString()}");
      return StripeCustomResponse(ok: false, msg: e.toString());
    }

  }
}