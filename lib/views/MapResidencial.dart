import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:standby/model/acceso.dart';

class MapResidencial extends StatefulWidget {
  
  const MapResidencial({super.key});

  @override
  State<MapResidencial> createState() => _MapResidencialState();
}

class _MapResidencialState extends State<MapResidencial> {

  final Completer<GoogleMapController> _controller = Completer();
  LocationData currentLocation = LocationData.fromMap({
      "latitude": 29.094597,
      "longitude": -110.954259
  });

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic>? datosResidencial = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final List<Acceso> listaAccesos = datosResidencial!["listaAccesos"];

    Set<Circle> circleSet = generacionGeovallas(datosResidencial, listaAccesos);

    return Scaffold(
      body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          // ignore: unnecessary_null_comparison
          child: currentLocation == null
              ? const Center(child: Text("Loading"))
              : _googleMap(datosResidencial, circleSet),
              //: Center(child: Text("${listaAccesos}"))
        ),
    );
  }



  _googleMap(datosResidencial, circleSet){
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
              onDragEnd: (value){
                currentLocation = LocationData.fromMap({
                    "latitude": value.latitude,
                    "longitude": value.longitude
                });
              },
            )
          },
          onMapCreated: (mapController) {
            _controller.complete(mapController);
          },
        );
    }

Set<Circle> generacionGeovallas(Map<String, dynamic> datosResidencial, List<Acceso> listaAccesos) {
  //Geovalla residencial
  Set<Circle> circleSet = <Circle>{
    Circle(
      circleId: const CircleId('geovalla_residencial'),
      center: LatLng(
        double.parse(datosResidencial["latitudResidencial"]),
        double.parse(datosResidencial["longitudResidencial"]),
      ),
      radius: 10, // Radio en metros
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
      radius: 3, // Radio en metros
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
    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      setState(() {});
    });
  }

}//fin clase