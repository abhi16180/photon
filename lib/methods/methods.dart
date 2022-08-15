import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../services/photon_sender.dart';

handleSharing(BuildContext context) async {
  if ((await PhotonSender.share(context) == true)) {
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

Future<List<String>> getIP() async {
  //todo handle exception when no ip available
  // String? wifiIP;
  // try {
  //   wifiIP = await NetworkInfo().getWifiIP();
  // } catch (_) {}

  // if (wifiIP != null) {
  //   return [wifiIP.toString()];
  // }
  ///sometimes when device acts as hotspot it will return null
  ///find list of interfaces
  ///assign ip with proper ip-address
  List<NetworkInterface> listOfInterfaces = await NetworkInterface.list();
  List<String> ipList = [];

  for (NetworkInterface netInt in listOfInterfaces) {
    for (InternetAddress internetAddress in netInt.addresses) {
      if (internetAddress.address.toString().startsWith('192.168')) {
        ipList.add(internetAddress.address);
      }
    }
  }
  return ipList;
}

int getRandomNumber() {
  Random rnd;
  try {
    rnd = Random.secure();
  } catch (_) {
    rnd = Random();
  }
  return rnd.nextInt(10000);
}
