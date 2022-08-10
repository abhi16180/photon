
import 'package:flutter/material.dart';
import 'package:photon/services/photon_server/photon_server.dart';
import 'package:photon/widescreen_view/widescreen_home.dart';

import 'mobile_view/mobile_home.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Photon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: size.width > 720 ? const WidescreenHome() : const MobileHome(),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.close),
          onPressed: () async {
            await PhotonServer.closeServer();
          }),
    );
  }
}
