import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  static late Box _box;

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
    var resp = await http.get(
        Uri.parse('http://${senderModel.ip}:${senderModel.port}/get-code'),
        headers: {
          'receiver-name': Platform.localHostname,
          'os': Platform.operatingSystem,
        });
    var senderRespData = jsonDecode(resp.body);
    return senderRespData;
  }

  static receive(SenderModel senderModel, int secretCode) async {
    //getting hiveObj
    _box = Hive.box('history');
    try {
      var resp = await Dio()
          .get('http://${senderModel.ip}:${senderModel.port}/getpaths');
      filePathMap = jsonDecode(resp.data);
      _secretCode = secretCode;
      for (int i = 0; i < filePathMap['paths']!.length; i++) {
        await getFile(filePathMap['paths'][i], i, senderModel);
      }
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
    Stopwatch s = Stopwatch();
    int? prevBytes;
    int? prevDuration;
    int count = 0;

    try {
      s.start();
      await dio.download(
        'http://${senderModel.ip}:4040/${_secretCode.toString()}/${fileIndex.toString()}',
        savePath,
        deleteOnError: true,
        cancelToken: getInstance.cancelTokenList[fileIndex],
        onReceiveProgress: (received, total) {
          if (total != -1) {
            count++;
            getInstance.percentage[fileIndex].value =
                (double.parse((received / total * 100).toStringAsFixed(0)));
            if (prevBytes == null) {
              prevBytes = received;
              prevDuration = s.elapsedMicroseconds;
              getInstance.minSpeed.value = getInstance.maxSpeed.value =
                  ((prevBytes! * 8) / prevDuration!);
            } else {
              prevBytes = received - prevBytes!;
              prevDuration = s.elapsedMicroseconds - prevDuration!;
            }
          }
          //used for reducing speed update frequency
          if (count % 10 == 0) {
            getInstance.speed.value = (prevBytes! * 8) / prevDuration!;
            if (getInstance.speed.value > getInstance.maxSpeed.value) {
              getInstance.maxSpeed.value = getInstance.speed.value;
            } else if (getInstance.speed.value < getInstance.minSpeed.value) {
              getInstance.minSpeed.value = getInstance.speed.value;
            }
          }
        },
      );
      s.reset();
      getInstance.speed.value = 0.0;
      //after completion of download mark it as true
      getInstance.isReceived[fileIndex].value = true;
      storeHistory(_box, savePath);
    } catch (e) {
      if (!CancelToken.isCancel(e as DioError)) {
        debugPrint(e.toString());
      } else {
        debugPrint('error');
      }
    }
  }
}
