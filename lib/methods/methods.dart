import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_it/get_it.dart';

import '../controllers/controllers.dart';
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

generatePercentageList(len) {
  var getInstance = GetIt.I<PercentageController>();
  getInstance.percentage = RxList.generate(len, (index) {
    return RxDouble(0.0);
  });
  getInstance.isCancelled = RxList.generate(len, (index) {
    return RxBool(false);
  });
}

Widget getFileIcon(String extn) {
  switch (extn) {
    case 'pdf':
      return SvgPicture.asset(
        'assets/icons/pdffile.svg',
        width: 30,
        height: 30,
      );
    case 'html':
      return const Icon(
        Icons.html,
        size: 30,
      );
    case 'mp3':
      return const Icon(
        Icons.audio_file,
        size: 30,
      );
    case 'jpeg':
      return const Icon(
        Icons.image,
        size: 30,
      );
    case 'mp4':
      return const Icon(
        Icons.video_collection_rounded,
        size: 30,
      );
    default:
      return const Icon(
        Icons.file_present,
        size: 30,
      );
  }
}
