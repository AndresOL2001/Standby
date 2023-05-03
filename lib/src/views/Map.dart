// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:standby/services/NotificationsServices.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<Map> createState() => MapState();
}

class MapState extends State<Map> with WidgetsBindingObserver{
  final Completer<GoogleMapController> _controller = Completer();
  static double distance = 0;
  static LatLng destination = LatLng(29.100337673256437, -110.99760613426835);
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  bool entroDistanciaMedia = false;
  bool entroDistanciacorta = false;

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
    void calculateDistance(lat1, lon1, lat2, lon2){
      distance = 0;
      var p = 0.017453292519943295;
      var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
            cos(lat1 * p) * cos(lat2 * p) * 
            (1 - cos((lon2 - lon1) * p))/2;
      distance =  12742 * asin(sqrt(a));

//----------- Parte para las notificaciones segun la distancia ---------------------
      if( distance > 0.35 && entroDistanciaMedia ) entroDistanciaMedia = false;
      if( distance > 0.1 && entroDistanciacorta ) entroDistanciacorta = false;

      if( (distance > 0.01 && distance < 0.35) && !entroDistanciaMedia ){
        notificacionDistanciaMedia();
        entroDistanciaMedia = true;
      }

      if( distance < 0.01 && !entroDistanciacorta ){
        notificacionDistanciaCorta();
        entroDistanciacorta = true;
      }
//-----------------------------------------------------------------------------------

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
  void initState() {
    getCurrentLocation();
    getPolyPoints();
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
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      mostrarNotificacion("La aplicacion se esta ejecutando en segundo plano");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Stand By v0.0.5",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        body: Stack(children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: 400,
            child: currentLocation == null
            ? const Center(child: Text("Loading"))
            : _googleMap(),
          ),
          ListTile(title: Text("Manten presionado el marcador mas lejano para moverlo a tu proximo destino - Te encuentras a $distance km de distancia."))
        ]));
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

  
}