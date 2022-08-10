import 'package:flutter/material.dart';
import 'package:photon/services/photon_server/photon_server.dart';

class SharePage extends StatefulWidget {
  const SharePage({Key? key}) : super(key: key);

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share'),
        leading: BackButton(onPressed: () {
          PhotonServer.closeServer();
          Navigator.of(context).pop();
        }),
      ),
    );
  }
}
