import 'dart:async';

import 'package:flutter/material.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';
import 'package:standby/widgets/side_menu.dart';

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _activityStreamController = StreamController<Activity>();
  StreamSubscription<Activity>? _activityStreamSubscription;

  void _onActivityReceive(Activity activity) {
    _activityStreamController.sink.add(activity);
  }

  void _handleError(dynamic error) {
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      final activityRecognition = FlutterActivityRecognition.instance;

      // Check if the user has granted permission. If not, request permission.
      PermissionRequestResult reqResult;
      reqResult = await activityRecognition.checkPermission();
      if (reqResult == PermissionRequestResult.PERMANENTLY_DENIED) {
        return;
      } else if (reqResult == PermissionRequestResult.DENIED) {
        reqResult = await activityRecognition.requestPermission();
        if (reqResult != PermissionRequestResult.GRANTED) {
          return;
        }
      }

      // Subscribe to the activity stream.
      _activityStreamSubscription = activityRecognition.activityStream
          .handleError(_handleError)
          .listen(_onActivityReceive);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        elevation: 0,
        child: const Icon(Icons.share),
      ),
      drawer: const SideMenu(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    _InfoUser(topico: "Usuario: ", info: Preferences.nombreUsuario),
                    _InfoUser(topico: "No. Serie Activado: ", info: Preferences.direccionUsuario),
                    const _InfoUser(topico: "Plan vigente", info: ""),
                  ],
                ),
              ),

              const _BotonAbrir(),

              StreamBuilder<Activity>(
                stream: _activityStreamController.stream,
                builder: (context, snapshot) {
                  final updatedDateTime = DateTime.now();
                  final content = snapshot.data?.type ?? ActivityType.STILL;

                  return SizedBox(
                    height: 200,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(8.0),
                      children: [
                        Text('•\t\tActivity (updated: $updatedDateTime)'),

                        const SizedBox(height: 10.0),
                  
                        Icon(
                            (content == ActivityType.WALKING || content == ActivityType.UNKNOWN)
                            ? Icons.nordic_walking
                            : (content == ActivityType.STILL || content == ActivityType.IN_VEHICLE)
                              ? Icons.car_rental
                              : Icons.warning
                            ,
                          size: 100,
                        )
                  
                      ]
                    ),
                  );
                }
              )

            ],
          ),
        ),
     ),
   );
   
  }
}

class _BotonAbrir extends StatelessWidget {
  const _BotonAbrir({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        fixedSize: const Size(double.maxFinite, 50),
        textStyle: const TextStyle(fontSize: 20)
      ),
      onPressed: (){}, 
      child: const Text("Abrir")
    );
  }
}

class _InfoUser extends StatelessWidget {

  final String topico;
  final String info;

  const _InfoUser({
    required this.topico,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          topico, 
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold
          ),
        ),
        Expanded(child: Text(info, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)))
      ],
    );
  }
}