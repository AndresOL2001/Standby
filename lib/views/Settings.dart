import 'package:flutter/material.dart';
import 'package:standby/shared_preferences/shared_preferences.dart';
import '../widgets/custom_sliver_list.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  CustomScrollView(
      slivers: [
        const _CustomSliverAppBar(),

        CustomSliverList()
      ],
    );
  }
}

class _CustomSliverAppBar extends StatelessWidget {
  const _CustomSliverAppBar();

  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 250,
      title: Center( child: Text('Configuración') ),
      flexibleSpace: FlexibleSpaceBar(
        background: _UserInfo(),
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Center(
        child: Stack(
          children: [
            _PurpleBox(),
            _avatarUserInfo(),
          ],
        )
      ),
    );
  }

  Column _avatarUserInfo() { 
    return Column(
      children: [
        _HeaderIcon(),
        const SizedBox( height: 10 ),
        Text(
            "${Preferences.nombreUsuario}\n${Preferences.direccionUsuario}\nPlan activo",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              
            ),
          )
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 30),
        child: const Icon(Icons.person_pin, color: Colors.white, size: 80,),
      ),
    );
  }
}

class _PurpleBox extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      decoration: _purpleBackground(),
      child:  Stack(
        children: [
          Positioned(top: 90, left: 30, child: _Bubble(),),
          Positioned(top: -40, left: -30, child: _Bubble(),),
          Positioned(top: -50, right: -20, child: _Bubble(),),
        ],
      ),
    );
  }

  BoxDecoration _purpleBackground() => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.indigo,
        Color(0xFF303F9F),
        Color(0xFF3F51B5),
        Color(0xFF5C6BC0)
      ]
    )
  );
}

class _Bubble extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: const Color.fromRGBO(255, 255, 255, 0.05)
      ),
    );
  }
}