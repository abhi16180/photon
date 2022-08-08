import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photon'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MaterialButton(
            color: Colors.blue,
            minWidth: 100,
            
            onPressed: () {},
            child: const Center(child: Text('Server')),
          ),
          const SizedBox(
            height: 100,
          ),
          MaterialButton(
            minWidth: 100,
            color: Colors.blue,
            onPressed: () {},
            child: const Center(child: Text('Client')),
          )
        ],
      ),
    );
  }
}
