import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:photon/components/snackbar.dart';

import '../controllers/controllers.dart';
import '../services/photon_sender.dart';

handleSharing(BuildContext context, {bool externalIntent = false}) async {
  if ((await PhotonSender.share(context, externalIntent: externalIntent) ==
      true)) {
    Navigator.pushNamed(context, '/sharepage');
  } else {
    showSnackBar(context, 'No file chosen');
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
  getInstance.isReceived = RxList.generate(len, (index) {
    return RxBool(false);
  });
  getInstance.fileStatus =
      RxList.generate(len, (index) => RxString(Status.waiting.name));
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
        color: Colors.red,
        size: 30,
      );
    case 'mp3':
      return const Icon(
        Icons.audio_file,
        color: Colors.deepPurple,
        size: 30,
      );
    case 'jpeg':
      return SvgPicture.asset(
        'assets/icons/jpeg.svg',
        color: Colors.cyanAccent,
        width: 30,
        height: 30,
      );
    case 'png':
      return SvgPicture.asset(
        'assets/icons/png.svg',
        width: 30,
        height: 30,
      );
    case 'exe':
      return SvgPicture.asset(
        'assets/icons/exe.svg',
        color: Colors.blueAccent,
        width: 30,
        height: 30,
      );
    case 'apk':
      return SvgPicture.asset(
        'assets/icons/android.svg',
        color: Colors.greenAccent.shade400,
        width: 30,
        height: 30,
      );
    case 'dart':
      return SvgPicture.asset(
        'assets/icons/dart.svg',
        width: 30,
        height: 30,
      );
    case 'mp4':
      return const Icon(
        Icons.video_collection_rounded,
        size: 30,
        color: Colors.orangeAccent,
      );

    default:
      return SvgPicture.asset(
        'assets/icons/file.svg',
        width: 30,
        height: 30,
      );
  }
}

storeHistory(Box box, String savePath) {
  if (box.get('fileInfo') == null) {
    box.put('fileInfo', []);
  }
  List fileInfo = box.get('fileInfo') as List;
  fileInfo.insert(
    0,
    {
      'fileName': savePath.split(Platform.pathSeparator).last,
      'date': DateTime.now(),
      'filePath': savePath
    },
  );

  box.put('fileInfo', fileInfo);
}

getHistory() async {
  var box = await Hive.openBox('history');
  return box.get('fileInfo');
}

clearHistory() async {
  Hive.openBox('history').then((box) => box.delete('fileInfo')).catchError((e) {
    debugPrint(e.toString());
  });
}

String getDateString(DateTime date) {
  String day = "${date.day}".padLeft(2, '0');
  String month = "${date.month}";
  String year = "${date.year}";
  String hour = date.hour > 12 ? "${date.hour - 12}" : "${date.hour}";
  String period = TimeOfDay.fromDateTime(date).period.name;
  String minute = "${date.minute}".padLeft(2, '0');
  String dateString = "$day-$month-$year " "$hour-$minute $period";
  return dateString;
}
