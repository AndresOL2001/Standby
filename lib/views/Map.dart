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
import 'package:standby/shared_preferences/shared_preferences.dart';

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
  LatLng destination = LatLng(29.094597, -110.954259);
  LatLng caseta = LatLng(29.094818, -110.954349);
  List<LatLng> polylineCoordinates = [];
  LocationData currentLocation = LocationData.fromMap({
        "latitude": 29.094597,
        "longitude": -110.954259
      });

  static bool entroEnCasa = false;
  static bool entroEnCaseta = false;
  static bool notificacionEnviada = false;
  IconData icono = Icons.stop;

  //Ver si esta habilitado
  static bool isAvailable = Preferences.isAvailable;

//Obtenemos ubicacion en tiempo real
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
      calculateDistance(currentLocation.latitude!, currentLocation.longitude!, caseta.latitude, caseta.longitude, "caseta");
      calculateDistance(currentLocation.latitude!, currentLocation.longitude!, caseta.latitude, caseta.longitude, "residencial");
      setState(() {});
    });
  }

  //Calculamos distancia entre los 2 puntos
    Future<void> calculateDistance(lat1, lon1, lat2, lon2,valor) async {
      //distance = 0;
      var p = 0.017453292519943295;
      var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
            cos(lat1 * p) * cos(lat2 * p) * 
            (1 - cos((lon2 - lon1) * p))/2;
      _distance =  12742 * asin(sqrt(a));


      var sharedPreferences = await SharedPreferences.getInstance();

      if(valor == "caseta"){
        sharedPreferences.setDouble('distanciaCaseta', _distance);

      } else {
        sharedPreferences.setDouble('distanciaResidencial', _distance);
      }
      setState(() {});
    }

    //Trazamos camino
  void getPolyPoints() async {
    polylineCoordinates = [];
/*     await Future.delayed(const Duration(seconds: 4));
 */
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyCNmpD_f-vJFakrjcL0X5ugzf9tKjZOM6I",
        PointLatLng(currentLocation.latitude!, currentLocation.longitude!),
        PointLatLng(destination.latitude, destination.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) =>
            polylineCoordinates.add(LatLng(point.latitude, point.longitude)),
      );
      await calculateDistance(currentLocation.latitude!, currentLocation.longitude!, caseta.latitude, caseta.longitude, "caseta");
      await calculateDistance(currentLocation.latitude!, currentLocation.longitude!, destination.latitude, destination.longitude, "residencial");
      setState(() {});
    }

  }

//Constructor
  @override
  initState() {
    getCurrentLocation();
    getPolyPoints();

    if( isAvailable ) initializeService();
    
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
        onPressed: isAvailable == false
        ? null 
        : () async {

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

        },
        child: Icon(icono)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

      body: Stack(
        children:[

          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              // ignore: unnecessary_null_comparison
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
                        circleId: CircleId('geovalla_caseta'),
                        center: LatLng(caseta.latitude, caseta.longitude),
                        radius: 5, // Radio en metros
                        fillColor: Colors.blue.withOpacity(0.2), // Color de relleno
                        strokeColor: Colors.blue, // Color de borde
                        strokeWidth: 2, // Ancho de borde en píxeles
                      ),

                      Circle(
                        circleId: CircleId('geovalla_residencial'),
                        center: LatLng(destination.latitude, destination.longitude),
                        radius: 49, // Radio en metros
                        fillColor: Colors.red.withOpacity(0.2), // Color de relleno
                        strokeColor: Colors.red, // Color de borde
                        strokeWidth: 2, // Ancho de borde en píxeles
                      ),
                    },
                      initialCameraPosition: CameraPosition(
                          target: LatLng(currentLocation.latitude!,
                              currentLocation.longitude!),
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
                          position: LatLng(currentLocation.latitude!,
                              currentLocation.longitude!),
                              draggable: true,
                              onDragEnd: (value){
                            currentLocation = LocationData.fromMap({
                            "latitude": value.latitude,
                            "longitude": value.longitude
                          });

                            getPolyPoints();
                          },
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
                         Marker(
                          markerId: MarkerId("userLocation"),
                          position: caseta,
                          draggable: true,
                           onDragEnd: (value){
                            caseta = value;
                            getPolyPoints();
                          },
                        ),
                      },
                      onMapCreated: (mapController) {
                        _controller.complete(mapController);
                      },
                    );
  }

  Future <void> initializeService() async {
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
        double? distanciaCaseta = sharedPreferences.getDouble("distanciaCaseta");
        double? distanciaResidencial = sharedPreferences.getDouble("distanciaResidencial");
        String distanciaRecortada = distanciaCaseta!.toStringAsFixed(3);

        
        if( distanciaCaseta < 1.0 ){
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

      if(distanciaResidencial! <= 0.049){
        entroEnCasa = true;
      }else{
        entroEnCasa = false;
        notificacionEnviada = false;
      }

      if(distanciaCaseta <= 0.005){
        entroEnCaseta = true;
      }else{
        entroEnCaseta = false;
        }

        if(entroEnCasa && entroEnCaseta && notificacionEnviada == false){
          notificacionEnviada = true;
          //print("NOTIFICACION ENVIADA!!");
          mostrarNotificacion("ENTRANDO A LA RESIDENCIAL");
        }else{
          //print("NOTIFICACION NO ENVIADA!!");

        }
      
      // print("Esta en casa:$entroEnCasa");
      // print("Esta en caseta:$entroEnCaseta");


    
  //-----------------------------------------------------------------------------------
        
        service.invoke("update");
      });
  }
}