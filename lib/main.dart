import 'package:flutter/material.dart';

import 'package:photon/mobile_view/mobile_home.dart';
import 'package:photon/wide_screen_view/widescreen_home.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const App(),
    ),
  );
}

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
        backgroundColor: Colors.blue,
        title: const Text('Photon'),
      ),
      body: Center(
          child: size.width > 720 ? const WidescreenHome() : MobileHome()),
    );
  }
}
