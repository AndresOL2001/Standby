import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';
import 'package:standby/widgets/side_menu.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';


  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print("ESTE ES EL EVENTO $event");
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print("ESTE ES EL ERROR $error");
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print("ESTE ES EL ESTADO $_status");
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() async {
    if (await Permission.activityRecognition.request().isGranted) {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    }
    
    if (!mounted) return;
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

              const SizedBox( height: 10 ),

              Text(
                'Steps Taken',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                _steps,
                style: TextStyle(fontSize: 60),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),

              Icon(
                _status == 'walking'
                    ? Icons.directions_walk
                    : _status == 'stopped'
                        ? Icons.accessibility_new
                        : Icons.error,
                size: 100,
              ),
              Center(
                child: Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                      ? TextStyle(fontSize: 30)
                      : TextStyle(fontSize: 20, color: Colors.red),
                ),
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