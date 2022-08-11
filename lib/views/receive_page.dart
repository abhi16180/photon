import 'package:flutter/material.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive'),
      ),
    );
  }
}
