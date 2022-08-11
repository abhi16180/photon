import 'package:flutter/material.dart';

import 'app.dart';
import 'views/receive_page.dart';
import 'views/share_page.dart';

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
