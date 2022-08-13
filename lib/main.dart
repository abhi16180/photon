import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/controllers/controllers.dart';

import 'app.dart';
import 'views/receive_page.dart';
import 'views/share_page.dart';

void main() {
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<PercentageController>(PercentageController());
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'ytf',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const App(),
        '/sharepage': (context) => const SharePage(),
        '/receivepage': (context) => const ReceivePage()
      },
    ),
  );
}
