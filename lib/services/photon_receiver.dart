import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/sender_model.dart';

import 'package:photon/services/file_services.dart';

import '../controllers/controllers.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

class PhotonReceiver {
  static Map<String, dynamic>? filePathMap;

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
          'receiver-name': 'Name',
          'os': Platform.operatingSystem,
        });
    var senderRespData = jsonDecode(resp.body);

    return senderRespData;
  }

  static receive(SenderModel senderModel, int secretCode) async {
    try {
      var resp = await Dio()
          .get('http://${senderModel.ip}:${senderModel.port}/getpaths');
      filePathMap = jsonDecode(resp.data);

      for (int i = 0; i < filePathMap!['paths']!.length; i++) {
        await receiveFile(senderModel.ip, filePathMap!['paths']![i], i,
            senderModel, secretCode);
      }
    } catch (_) {
      print('Refused to connect');
    }
  }

  static receiveFile(
      ip, filePath, fileIndex, SenderModel senderModel, int secretCode) async {
    Dio dio = Dio();
    var getInstance = GetIt.I<PercentageController>();
    String finalPath = await FileMethods.getSavePath(filePath, senderModel);
    try {
      print('http://$ip:4040/${secretCode.toString()}/${fileIndex.toString()}');
      await dio.download(
        'http://$ip:4040/${secretCode.toString()}/${fileIndex.toString()}',
        finalPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // print("${(received / total * 100).toStringAsFixed(0)}%");
            getInstance.percentage[fileIndex].value =
                (double.parse((received / total * 100).toStringAsFixed(0)));
          }
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
