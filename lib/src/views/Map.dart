// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:standby/main.dart';

import 'package:standby/services/NotificationsServices.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<Map> createState() => MapState();

}

class MapState extends State<Map> with WidgetsBindingObserver{
  final Completer<GoogleMapController> _controller = Completer();
  double _distance = 0;
  LatLng destination = LatLng(29.100337673256437, -110.99760613426835);
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  static bool entroDistanciaMedia = false;
  static bool entroDistanciacorta = false;

  String estadoService = "Stop";


//Obtenemos ubicacion en tiempo real
  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      calculateDistance(currentLocation!.latitude!, currentLocation!.longitude!, destination.latitude, destination.longitude);
      setState(() {});
    });
  }

  //Calculamos distancia entre los 2 puntos
    Future<void> calculateDistance(lat1, lon1, lat2, lon2) async {
      //distance = 0;
      var p = 0.017453292519943295;
      var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
            cos(lat1 * p) * cos(lat2 * p) * 
            (1 - cos((lon2 - lon1) * p))/2;
      _distance =  12742 * asin(sqrt(a));


      var sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setDouble('distanceee', _distance);
      setState(() {});
    }

    //Trazamos camino
  void getPolyPoints() async {
    polylineCoordinates = [];
    await Future.delayed(const Duration(seconds: 4));

    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyCNmpD_f-vJFakrjcL0X5ugzf9tKjZOM6I",
        PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        PointLatLng(destination.latitude, destination.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) =>
            polylineCoordinates.add(LatLng(point.latitude, point.longitude)),
      );
      calculateDistance(currentLocation!.latitude!, currentLocation!.longitude!, destination.latitude, destination.longitude);
      setState(() {});
    }

  }

//Constructor
  @override
  initState() {
    getCurrentLocation();
    getPolyPoints();
    initializeService();
    WidgetsBinding.instance.addObserver(this); //Para el ciclo de vida de la app
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); //Para cerrar el observador del ciclo de vida
    super.dispose();
  }

  //metodo para ver el estado de vida
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Aquí puedes interactuar con el estado del ciclo de vida de la aplicación.
    //print("El estado del ciclo de vida de la aplicación cambió a: $state");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Stand By v0.3.4",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Stack(children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: 400,
              child: currentLocation == null
              ? const Center(child: Text("Loading"))
              : _googleMap(),
            ),
            ListTile(title: Text("Manten presionado el marcador mas lejano para moverlo a tu proximo destino - Te encuentras a $_distance km de distancia.")),

            Positioned(
              bottom: 50,
              right: 20,
              child: ElevatedButton(
                child: const Text("Foreground"),
                onPressed: (){
                  FlutterBackgroundService().invoke('setAsForeground');
                },
              )
            ),

            Positioned(
              bottom: 50,
              left: 20,
              child: ElevatedButton(
                child: const Text("Background"),
                onPressed: () async {
                  //FlutterBackgroundService().invoke('setAsBackground');
                  await initializeService();
                },
              )
            ),

            Positioned(
              bottom: 20,
              left: 150,
              child: ElevatedButton(
                child: Text("$estadoService"),
                onPressed: () async{
                  final service = FlutterBackgroundService();
                  bool isRunning = await service.isRunning();
                  if( isRunning ){
                    estadoService = "Start";
                    service.invoke("stopService");
                  } else {
                    estadoService = "Stop";
                    service.startService();
                  }

                  setState(() { });

                },
              )
            ),

          ]
        )
    );
  }

  _googleMap(){
    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!),
                          zoom: 15),
                      polylines: {
                        Polyline(
                            polylineId: PolylineId("route"),
                            points: polylineCoordinates,
                            width: 6)
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId("currentLocation"),
                          position: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!),
                        ),
                        Marker(
                          markerId: MarkerId("destination"),
                          position: destination,
                          draggable: true,
                          onDragEnd: (value){
                            destination = value;
                            getPolyPoints();
                          },
                        ),
                      },
                      onMapCreated: (mapController) {
                        _controller.complete(mapController);
                      },
                    );
  }

  
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

      double? distanciaBuena = sharedPreferences.getDouble("distanceee");

      if( service is AndroidServiceInstance ){
        if( await service.isForegroundService() ){
          service.setForegroundNotificationInfo(
            title: "Prueba", 
            content: "Estas a $distanciaBuena km"
          );
        }
      }
      //Operaciones que no son visibles pal usuario

      //----------- Parte para las notificaciones segun la distancia ---------------------
      if( distanciaBuena! > 0.35 && entroDistanciaMedia ) entroDistanciaMedia = false;
      if( distanciaBuena > 0.1 && entroDistanciacorta ) entroDistanciacorta = false;

      if( (distanciaBuena > 0.01 && distanciaBuena < 0.35) && !entroDistanciaMedia ){
        notificacionDistanciaMedia();
        entroDistanciaMedia = true;
      }

      if( distanciaBuena < 0.01 && !entroDistanciacorta ){
        notificacionDistanciaCorta();
        entroDistanciacorta = true;
      }
//-----------------------------------------------------------------------------------
      
      service.invoke("update");
    });

  }
  
}