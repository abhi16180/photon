import 'package:flutter/material.dart';
import 'package:photon/receive_page.dart';
import 'package:photon/share_page.dart';

import 'app.dart';

void main() {
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
