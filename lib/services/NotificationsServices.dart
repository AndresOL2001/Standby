import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async{
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('icono_notificacion');

  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

}

Future<void> mostrarNotificacion(String mensaje) async{
  
  const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    'channelId', 
    'channelName',
    importance: Importance.max,
    priority: Priority.max
  );

  const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails();

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    iOS: darwinNotificationDetails
  );

  await flutterLocalNotificationsPlugin.show(1, 'StandBy', mensaje, notificationDetails);

}

void notificacionDistanciaMedia(){
  mostrarNotificacion("Estas cerca de llegar a tu destino.");
}

void notificacionDistanciaCorta(){
  mostrarNotificacion("Estas en tu destino.");
}