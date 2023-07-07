import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:standby/views/Principal.dart';
import 'package:standby/views/Settings.dart';

import 'package:standby/widgets/custom_navigatorbar.dart';
import 'package:standby/widgets/share_button.dart';

import '../provider/ui_provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
        final uiProvider = Provider.of<UiProvider>(context);

    final currentIndex = uiProvider.selectedMenuOpt;
    return Scaffold(
      body: IndexedStack(
            index: currentIndex,
            children: const <Widget>[
              Principal(),
              SettingsPage(),
            ],
      ),
      bottomNavigationBar: const CustomNavigationBar(),
      floatingActionButton: const ShareButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}