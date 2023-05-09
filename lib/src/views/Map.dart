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

  IconData icono = Icons.stop;


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


final TextEditingController latitudController = TextEditingController();
  final TextEditingController longitudController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor:Colors.green,
        child: Icon(icono),
        onPressed: () async {

          final service = FlutterBackgroundService();
          bool isRunning = await service.isRunning();
          if( isRunning ){
            icono = Icons.play_arrow;
            service.invoke("stopService");
          } else {
            icono = Icons.stop;
            service.startService();
          }
          setState(() { });

        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

      body: Stack(
        children:[

          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: currentLocation == null
                  ? const Center(child: Text("Loading"))
                  : _googleMap(),
            ),
          ),

          Positioned(
            child: Container(
              margin: EdgeInsets.only(top: 50.0),
              height: MediaQuery.of(context).size.width * 0.53,
              padding: const EdgeInsets.all(16),
              color: Color.fromARGB(0, 255, 255, 255),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      enabled: false,
                      maxLines: 3,
                      controller: latitudController,
                      decoration: InputDecoration(
                        labelText: 'Lat: ${destination.latitude.toString()}\n\nLong: ${destination.longitude.toString()}',
                        hintText: 'Ingrese su Latitud',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.0),
                        ),
                        filled: true, // Habilitar el relleno del fondo
                        fillColor: Colors.white, // Color del fondo
                      ),
                    ),
                  ),
                ),
                /*
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0),
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        controller: longitudController,
                        decoration: InputDecoration(
                          labelText: currentLocation!.altitude.toString(),
                          hintText: 'Ingrese su Longitud',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.0),
                        ),
                        filled: true, // Habilitar el relleno del fondo
                        fillColor: Colors.white, // Color del fondo
                      ),
                      ),
                    ),
                  ),
                  */

                  /*
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Acción al hacer clic en el botón
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 50.0),
                          backgroundColor: Colors.green,
                        ),
                        child: Text(
                          'Guardar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  */
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }



  _googleMap(){
    return GoogleMap(
                          circles: <Circle>{
                      Circle(
                        circleId: CircleId('circle_1'),
                        center: LatLng(destination.latitude, destination.longitude),
                        radius: 800, // Radio en metros
                        fillColor: Colors.blue.withOpacity(0.2), // Color de relleno
                        strokeColor: Colors.blue, // Color de borde
                        strokeWidth: 2, // Ancho de borde en píxeles
                      ),

                      Circle(
                        circleId: CircleId('circle_2'),
                        center: LatLng(destination.latitude, destination.longitude),
                        radius: 50, // Radio en metros
                        fillColor: Colors.red.withOpacity(0.2), // Color de relleno
                        strokeColor: Colors.red, // Color de borde
                        strokeWidth: 2, // Ancho de borde en píxeles
                      ),
                    },
                      initialCameraPosition: CameraPosition(
                          target: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!),
                          zoom: 15),
                      polylines: {
                        Polyline(
                            polylineId: PolylineId("route"),
                            points: polylineCoordinates,
                            color: Colors.green, // Cambia el color de la línea a azul
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
      String distanciaRecortada = distanciaBuena!.toStringAsFixed(3);

      
      if( distanciaBuena < 1.0 ){
        distanciaRecortada = "${double.parse(distanciaRecortada) * 1000} mts";
      } else {
        distanciaRecortada = "$distanciaRecortada km";
      }

      if( service is AndroidServiceInstance ){
        if( await service.isForegroundService() ){
          service.setForegroundNotificationInfo(
            title: "Standby en segundo plano", 
            content: "Estas a $distanciaRecortada"
          );
        }
      }
      //Operaciones que no son visibles pal usuario

      //----------- Parte para las notificaciones segun la distancia ---------------------
      if( distanciaBuena! > 0.8 && entroDistanciaMedia ) entroDistanciaMedia = false;
      if( distanciaBuena > 0.1 && entroDistanciacorta ) entroDistanciacorta = false;

      if( (distanciaBuena > 0.01 && distanciaBuena < 0.8) && !entroDistanciaMedia ){
        notificacionDistanciaMedia();
        entroDistanciaMedia = true;
      }

      if( distanciaBuena < 0.02 && !entroDistanciacorta ){
        notificacionDistanciaCorta();
        entroDistanciacorta = true;
      }
//-----------------------------------------------------------------------------------
      
      service.invoke("update");
    });

  }
  
}