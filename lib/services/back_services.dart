

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:standby/services/NotificationsServices.dart';

import 'package:standby/src/views/Map.dart';

MapState map = MapState();

Future <void> initializeService() async{
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ), 
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, 
      isForegroundMode: true,
      autoStart: true
    )
  );
}

@pragma('vm-entry-point')
Future<bool> onIosBackground(ServiceInstance service) async{
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm-entry-point')
void onStart(ServiceInstance service) async{
  DartPluginRegistrant.ensureInitialized();
  if( service is AndroidServiceInstance ){

    service.on('setAsForeground').listen((event) { 
      service.setAsForegroundService();
     });
    service.on('setAsBackground').listen((event) { 
      service.setAsBackgroundService();
     });
     
  }//fin if

  service.on('stopService').listen((event) { 
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 5), (timer) async{
    if( service is AndroidServiceInstance ){
      if( await service.isForegroundService() ){
        service.setForegroundNotificationInfo(
          title: "Prueba", 
          content: "Prueba"
        );
      }
    }
    //Operaciones que no son visibles pal usuario
    map.getCurrentLocation();
    final prefs = await SharedPreferences.getInstance();

    mostrarNotificacion("Distancia: ${prefs.getDouble('distance') ?? 0}");

    service.invoke("update");
   });

}