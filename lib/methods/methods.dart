import 'package:flutter/material.dart';

import '../services/photon_server/photon_server.dart';

handleSharing(BuildContext context) async {
  
  if ((await PhotonServer.share() == true)) {
    Navigator.pushNamed(context, '/sharepage');
  } else {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Error',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: const Text('No file chosen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              )),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            )
          ],
        );
      },
    );
  }
}
