import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/services/file_services.dart';
import '../controllers/controllers.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

class PhotonReceiver {
  static late int _secretCode;
  static late Map<String, dynamic> filePathMap;
  static final Box _box = Hive.box('appData');
  static late int id;
  static int totalTime = 0;

  ///to get network address [assumes class C address]
  static List<String> getNetAddress(List<String> ipList) {
    List<String> netAdd = [];
    for (String ip in ipList) {
      var ipToList = ip.split('.');
      ipToList.removeLast();
      netAdd.add(ipToList.join('.'));
    }
    return netAdd;
  }

  ///tries to establish socket connection
  static Future<Map<String, dynamic>> _connect(String host, int port) async {
    try {
      var socket = await Socket.connect(host, port)
          .timeout(const Duration(milliseconds: 2500));
      socket.destroy();
      return {"host": host, 'port': port};
    } catch (_) {
      return {};
    }
  }

  ///check if ip & port pair represent photon-server
  static isPhotonServer(String ip, String port) async {
    var dio = Dio();
    try {
      var resp = await dio.get('http://$ip:$port/photon-server');
      Map<String, dynamic> senderInfo = jsonDecode(resp.data);
      return SenderModel.fromJson(senderInfo);
    } catch (_) {
      return null;
    }
  }

  ///scan presence of photon-server[driver func]
  static Future<List<SenderModel>> scan() async {
    List<Future<Map<String, dynamic>>> list = [];
    List<SenderModel> photonServers = [];
    List<String> netAddresses = getNetAddress(await getIP());
    for (int i = 2; i < 255; i++) {
      //scan all of the wireless interfaces available
      for (String netAddress in netAddresses) {
        Future<Map<String, dynamic>> res = _connect('$netAddress.$i', 4040);
        list.add(res);
      }
    }

    for (var ele in list) {
      Map<String, dynamic> item = await ele;
      if (item.containsKey('host')) {
        Future<dynamic> resp;
        if ((resp = (isPhotonServer(
                item['host'].toString(), item['port'].toString()))) !=
            null) {
          photonServers.add(await resp);
        }
      }
    }
    list.clear();
    return photonServers;
  }

  static isRequestAccepted(SenderModel senderModel) async {
    String username = _box.get('username');
    var avatar = await rootBundle.load(_box.get('avatarPath'));
    var resp = await http.get(
        Uri.parse('http://${senderModel.ip}:${senderModel.port}/get-code'),
        headers: {
          'receiver-name': username,
          'os': Platform.operatingSystem,
          'avatar': avatar.buffer.asUint8List().toString()
          // 'avatar': avatar.buffer.asUint8List().toString()s
        });
    id = Random().nextInt(10000);
    var senderRespData = jsonDecode(resp.body);
    return senderRespData;
  }

  static sendBackReceiverRealtimeData(SenderModel senderModel,
      {fileIndex = -1, isCompleted = true}) {
    http.post(
      Uri.parse('http://${senderModel.ip}:4040/receiver-data'),
      headers: {
        "receiverID": id.toString(),
        "os": Platform.operatingSystem,
        "hostName": _box.get('username'),
        "currentFile": '${fileIndex + 1}',
        "isCompleted": '$isCompleted',
      },
    );
  }

  static receive(SenderModel senderModel, int secretCode) async {
    PercentageController getInstance =
        GetIt.instance.get<PercentageController>();
    //getting hiveObj

    String filePath = '';
    totalTime = 0;
    try {
      var resp = await Dio()
          .get('http://${senderModel.ip}:${senderModel.port}/getpaths');
      filePathMap = jsonDecode(resp.data);
      _secretCode = secretCode;

      for (int fileIndex = 0;
          fileIndex < filePathMap['paths']!.length;
          fileIndex++) {
        //if a file is cancelled once ,it should not be automatically fetched without user action
        if (getInstance.isCancelled[fileIndex].value == false) {
          getInstance.fileStatus[fileIndex].value = Status.downloading.name;

          if (filePathMap.containsKey('isApk')) {
            if (filePathMap['isApk']) {
              // when sender sends apk files
              // this case is not true when sender sends apk from generic file selection
              filePath =
                  '${filePathMap['paths'][fileIndex].toString().split("/")[4].split("-").first}.apk';
            } else {
              filePath = filePathMap['paths'][fileIndex];
            }
          } else {
            filePath = filePathMap['paths'][fileIndex];
          }

          await getFile(filePath, fileIndex, senderModel);
        }
      }
      // sends after last file is sent

      sendBackReceiverRealtimeData(senderModel);
      getInstance.isFinished.value = true;
      getInstance.totalTimeElapsed.value = totalTime;
    } catch (e) {
      debugPrint('$e');
    }
  }

  static getFile(
    String filePath,
    int fileIndex,
    SenderModel senderModel,
  ) async {
    Dio dio = Dio();
    PercentageController getInstance = GetIt.I<PercentageController>();
    //creates instance of cancelToken and inserts it to list
    getInstance.cancelTokenList.insert(fileIndex, CancelToken());
    String savePath = await FileMethods.getSavePath(filePath, senderModel);
    Stopwatch stopwatch = Stopwatch();
    int? prevBits;
    int? prevDuration;
    //for handling speed update frequency
    int count = 0;

    try {
      //sends post request every time receiver requests for a file
      sendBackReceiverRealtimeData(senderModel,
          fileIndex: fileIndex, isCompleted: false);
      stopwatch.start();

      getInstance.fileStatus[fileIndex].value = "downloading";
      await dio.download(
        'http://${senderModel.ip}:4040/$_secretCode/$fileIndex',
        savePath,
        deleteOnError: true,
        cancelToken: getInstance.cancelTokenList[fileIndex],
        onReceiveProgress: (received, total) {
          if (total != -1) {
            count++;
            getInstance.percentage[fileIndex].value =
                (double.parse((received / total * 100).toStringAsFixed(0)));
            if (prevBits == null) {
              prevBits = received;
              prevDuration = stopwatch.elapsedMicroseconds;
              getInstance.minSpeed.value = getInstance.maxSpeed.value =
                  ((prevBits! * 8) / prevDuration!);
            } else {
              prevBits = received - prevBits!;
              prevDuration = stopwatch.elapsedMicroseconds - prevDuration!;
            }
          }
          //used for reducing speed update frequency
          if (count % 10 == 0) {
            getInstance.speed.value = (prevBits! * 8) / prevDuration!;
            //calculate min and max speeds
            if (getInstance.speed.value > getInstance.maxSpeed.value) {
              getInstance.maxSpeed.value = getInstance.speed.value;
            } else if (getInstance.speed.value < getInstance.minSpeed.value) {
              getInstance.minSpeed.value = getInstance.speed.value;
            }

            // update estimated time
            getInstance.estimatedTime.value = getEstimatedTime(
                received * 8, total * 8, getInstance.speed.value);
            //update time elapsed
          }
        },
      );
      totalTime = totalTime + stopwatch.elapsed.inSeconds;
      stopwatch.reset();
      getInstance.speed.value = 0.0;
      //after completion of download mark it as true
      getInstance.isReceived[fileIndex].value = true;
      storeHistory(_box, savePath);
      getInstance.fileStatus[fileIndex].value = "downloaded";
    } catch (e) {
      getInstance.speed.value = 0;
      getInstance.fileStatus[fileIndex].value = "cancelled";
      getInstance.isCancelled[fileIndex].value = true;

      if (!CancelToken.isCancel(e as DioError)) {
        debugPrint("Dio error");
      } else {
        debugPrint(e.toString());
      }
    }
  }
}
