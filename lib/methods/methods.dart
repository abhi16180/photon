import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import '../controllers/controllers.dart';

String formatTime(int seconds) {
  List<String> timeList = Duration(seconds: seconds).toString().split(':');
  String hr = double.parse(timeList[0]).toStringAsFixed(0);
  String min = double.parse(timeList[1]).toStringAsFixed(0);
  String sec = double.parse(timeList[2]).toStringAsFixed(0);
  if (seconds > 3600) {
    return '$hr hr $min mins $sec s';
  }

  if (seconds > 60) {
    return '$min min, $sec s';
  }
  return '$sec seconds';
}

Future<List<String>> getIP() async {
  // todo handle exception when no ip available
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

getReceiverIP(ipList) {
  return ipList[0];
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

getStatusWidget(RxString status, idx) {
  switch (status.value) {
    case "waiting":
      return const Text("Waiting");
    case "downloading":
      return Text(
          '${GetIt.I.get<PercentageController>().percentage[idx].value}');
    case "cancelled":
      return const Text("Cancelled");
    case "error":
      return const Text("Error");
    case "downloaded":
      return const Text("Completed");
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
  var box = await Hive.openBox('appData');
  return box.get('fileInfo');
}

clearHistory() async {
  Hive.openBox('appData').then((box) => box.delete('fileInfo')).catchError((e) {
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

processReceiversData(Map<String, dynamic> newReceiverData) {
  var inst = GetIt.I.get<ReceiverDataController>();
  inst.receiverMap.addAll(
    {
      "${newReceiverData["receiverID"]}": {
        "hostName": newReceiverData["hostName"],
        "os": newReceiverData["os"],
        "currentFileName": newReceiverData["currentFileName"],
        "currentFileNumber": newReceiverData["currentFileNumber"],
        "filesCount": newReceiverData['filesCount'],
        "isCompleted": newReceiverData["isCompleted"],
      }
    },
  );
}

getEstimatedTime(receivedBits, totalBits, currentSpeed) {
  ///speed in [mega bits  x * 10^6 bits ]
  double estBits = (totalBits - receivedBits) / 1000000;
  int estTimeInInt = (estBits ~/ currentSpeed);
  int mins = 0;
  int seconds = 0;
  int hours = 0;
  hours = estTimeInInt ~/ 3600;
  mins = (estTimeInInt % 3600) ~/ 60;
  seconds = ((estTimeInInt % 3600) % 60);
  if (hours == 0) {
    if (mins == 0) {
      return 'About $seconds seconds left';
    }
    return 'About $mins m and $seconds s left';
  }
  return 'About $hours h $mins m $seconds s left';
}
