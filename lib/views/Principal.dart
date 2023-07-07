import 'dart:async';
import 'dart:io';

import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _Principal();
}

class _Principal extends State<Principal> with WidgetsBindingObserver{

  StreamSubscription<ActivityEvent>? activityStreamSubscription;
  List<ActivityEvent> _events = [];
  ActivityRecognition activityRecognition = ActivityRecognition();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
    _events.add(ActivityEvent.unknown());
  }

  @override
  void dispose() {
    activityStreamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("$state");
  }

  void _init() async {
    // Android requires explicitly asking permission
    if (Platform.isAndroid) {
      if (await Permission.activityRecognition.request().isGranted) {
        _startTracking();
      }
    }

    // iOS does not
    else {
      _startTracking();
    }
  }

  void _startTracking() {
    activityStreamSubscription = activityRecognition
        .activityStream(runForegroundService: true)
        .listen(onData, onError: onError);
  }

  void onData(ActivityEvent activityEvent) {
    setState(() {
      _events.add(activityEvent);
    });
  }

  void onError(Object error) {
    print('ERROR - $error');
  }

      Icon _activityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.WALKING:
        return const Icon(Icons.directions_walk);
      case ActivityType.IN_VEHICLE:
        return const Icon(Icons.car_rental);
      case ActivityType.ON_BICYCLE:
        return const Icon(Icons.pedal_bike);
      case ActivityType.ON_FOOT:
        return const Icon(Icons.directions_walk);
      case ActivityType.RUNNING:
        return const Icon(Icons.run_circle);
      case ActivityType.STILL:
        return const Icon(Icons.cancel_outlined);
      case ActivityType.TILTING:
        return const Icon(Icons.redo);
      default:
        return const Icon(Icons.device_unknown);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      child: Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
                itemCount: _events.length,
                itemBuilder: (_, int idx) {
                  final activity = _events[idx];
                  return ListTile(
                        leading: _activityIcon(activity.type),
                        title: Text(
                            '${activity.type.toString().split('.').last} (${activity.confidence}%)'),
                        trailing: Text(activity.timeStamp
                            .toString()
                            .split(' ')
                            .last
                            .split('.')
                            .first),
                      );
                },
    
              ),
          ),
       ),
    );
   
  }

}

/*
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
*/

/*
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
*/