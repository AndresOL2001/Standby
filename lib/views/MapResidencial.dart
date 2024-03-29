import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:standby/model/acceso.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';

import '../services/NotificationsServices.dart';

class MapResidencial extends StatefulWidget {
  
  const MapResidencial({super.key});

  @override
  State<MapResidencial> createState() => _MapResidencialState();
}

class _MapResidencialState extends State<MapResidencial> {

  static double _distance = 0;
  final Completer<GoogleMapController> _controller = Completer();

  LocationData currentLocation = LocationData.fromMap({
      "latitude": 29.094597,
      "longitude": -110.954259
  });

  static bool notificacionEnviada = false;
  static bool entroEnCasa = false;
  static bool entroEnCaseta = false;

  static late List<Acceso> listaAccesos;

  IconData icono = Icons.stop;
  final service = FlutterBackgroundService();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  initState() {
    getCurrentLocation();
    initializeService();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic>? datosResidencial = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    listaAccesos = datosResidencial!["listaAccesos"];
    final double radioResidencial = datosResidencial["radioResidencial"].toDouble();

    Preferences.latitudResidencial = double.parse(datosResidencial["latitudResidencial"]);
    Preferences.longitudResidencial = double.parse(datosResidencial["longitudResidencial"]);

    Set<Circle> circleSet = generacionGeovallas(datosResidencial, listaAccesos, radioResidencial);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor:Colors.green,
        onPressed: () async {

          bool isRunning = await service.isRunning();
          if( isRunning ){
            icono = Icons.play_arrow;
            service.invoke("stopService");
          } else {
            icono = Icons.stop;
            service.startService();
          }
          setState(() { });

        },
        child: Icon(icono)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          // ignore: unnecessary_null_comparison
          child: currentLocation == null
              ? const Center(child: Text("Loading"))
              : _googleMap(datosResidencial, circleSet, listaAccesos),
              //: Center(child: Text("${listaAccesos}"))
        ),
    );
  }



  _googleMap(datosResidencial, circleSet, List<Acceso> listaAccesos){
      final latitud = double.parse(datosResidencial["latitudResidencial"]);
      final longitud = double.parse(datosResidencial["longitudResidencial"]);

      return GoogleMap(
        myLocationEnabled: true,
        compassEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(latitud,longitud),
          zoom: 12
        ),
        circles: circleSet,
        markers: {
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: LatLng(currentLocation.latitude!,
            currentLocation.longitude!),
            draggable: true,
            onDragEnd: (value) async{
              currentLocation = LocationData.fromMap({
                  "latitude": value.latitude,
                  "longitude": value.longitude
              });

              calcularDistanciaAccesos(listaAccesos);
              await calculateDistance(currentLocation.latitude, currentLocation.longitude, Preferences.latitudResidencial, Preferences.longitudResidencial);
            },
          )
        },
        onMapCreated: (mapController) {
          _controller.complete(mapController);
        },
      );
    }

  void preferencesRadios(double radioResidencial, double radioCaseta) async{
    var sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setDouble('radioResidencial', radioResidencial);
    sharedPreferences.setDouble('radioCaseta', radioCaseta);

    setState(() {});
  }

  Set<Circle> generacionGeovallas(Map<String, dynamic> datosResidencial, List<Acceso> listaAccesos, double radioResidencial) {

    preferencesRadios(radioResidencial, listaAccesos[0].radio.toDouble());

    //Geovalla residencial
    Set<Circle> circleSet = <Circle>{
      Circle(
        circleId: const CircleId('geovalla_residencial'),
        center: LatLng(
          double.parse(datosResidencial["latitudResidencial"]),
          double.parse(datosResidencial["longitudResidencial"]),
        ),
        radius: radioResidencial, // Radio en metros
        fillColor: Colors.red.withOpacity(0.2), // Color de relleno
        strokeColor: Colors.red, // Color de borde
        strokeWidth: 2, // Ancho de borde en píxeles
      ),
    };

    //Geovallas de accesos
    circleSet.addAll(listaAccesos.map((acceso) {
      double latitud = double.parse(acceso.latitudCaseta);
      double longitud = double.parse(acceso.longitudCaseta);

      return Circle(
        circleId: CircleId(acceso.idAcceso),
        center: LatLng(latitud, longitud),
        radius: acceso.radio.toDouble(), // Radio en metros
        fillColor: Colors.blue.withOpacity(0.2), // Color de relleno
        strokeColor: Colors.blue, // Color de borde
        strokeWidth: 2, // Ancho de borde en píxeles
      );
    }));

    return circleSet;
  }

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

    //GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((newLoc) async {
      currentLocation = newLoc;
      calcularDistanciaAccesos(listaAccesos);
      await calculateDistance(currentLocation.latitude, currentLocation.longitude, Preferences.latitudResidencial, Preferences.longitudResidencial);
      //setState(() {});
    });
  }

  Future<void> calculateDistance(lat1, lon1, lat2, lon2) async {
    //distance = 0;
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
          cos(lat1 * p) * cos(lat2 * p) * 
          (1 - cos((lon2 - lon1) * p))/2;
    _distance =  12742 * asin(sqrt(a));

    var sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setDouble('distanciaResidenciall', _distance);
    setState(() {});
  }

  double calcularDistancia(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
          cos(lat1 * p) * cos(lat2 * p) * 
          (1 - cos((lon2 - lon1) * p))/2;
    var distancia = 12742 * asin(sqrt(a));
    distancia = double.parse(distancia.toStringAsFixed(3));
    return distancia * 1000;
  }

  void calcularDistanciaAccesos(List<Acceso> listaAccesos) async{
    List<String> distancias = [];
    var sharedPreferences = await SharedPreferences.getInstance();
    for (int i = 0; i < listaAccesos.length; i++) {
      distancias.add( calcularDistancia(currentLocation.latitude, currentLocation.longitude, double.parse(listaAccesos[i].latitudCaseta), double.parse(listaAccesos[i].longitudCaseta) ).toString() );
    }
    sharedPreferences.setStringList("listaDistancias", distancias);
  }

  @pragma('vm-entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async{
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  Future <void> initializeService() async {
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
   static void onStart(ServiceInstance service) async{
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

      Timer.periodic(const Duration(seconds: 3), (timer) async{

        var sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.reload();

        double? distanciaResidencial = sharedPreferences.getDouble("distanciaResidenciall");
        double distanciaRecortada = double.parse(distanciaResidencial!.toStringAsFixed(3));
        distanciaRecortada = distanciaRecortada * 1000;

        double? radioResidencial = sharedPreferences.getDouble("radioResidencial");
        double? radioCaseta = sharedPreferences.getDouble("radioCaseta");

        List<String>? distancias = sharedPreferences.getStringList("listaDistancias") ?? [];

        // if( distanciaResidencial < 1.0 ){
        //   distanciaRecortada = "${double.parse(distanciaRecortada) * 1000} mts";
        // } else {
        //   distanciaRecortada = "$distanciaRecortada km";
        // }

        if( service is AndroidServiceInstance ){
          if( await service.isForegroundService() ){
            service.setForegroundNotificationInfo(
              title: "Standby en plano", 
              content: "Estas a $distanciaRecortada mts"
            );
          }
        }
      
        //----------- Parte para las notificaciones segun la distancia ---------------------

        for(int i = 0; i < distancias.length ; i++){
          double distanciaCaseta = double.parse(distancias[i]);

          if(distanciaRecortada <= radioResidencial!){
            entroEnCasa = true;
          }else{
            entroEnCasa = false;
            notificacionEnviada = false;
          }

          if(entroEnCasa && notificacionEnviada == false){
            notificacionEnviada = true;
            mostrarNotificacion("ENTRANDO A LA RESIDENCIAL");
          }

        //--------------------------------------------------
          if(distanciaRecortada <= radioResidencial){
            entroEnCasa = true;
          }else{
            entroEnCasa = false;
            notificacionEnviada = false;
          }

          if(distanciaCaseta <= radioCaseta!){
            entroEnCaseta = true;
          } else{
            entroEnCaseta = false;
          }

          if(entroEnCasa && entroEnCaseta && notificacionEnviada == false){
            notificacionEnviada = true;
            //print("NOTIFICACION ENVIADA!!");
            mostrarNotificacion("ENTRANDO A LA RESIDENCIAL");
          }
          
        }//fin for
  //-----------------------------------------------------------------------------------
        
        service.invoke("update");
      });
  }

}//fin clase