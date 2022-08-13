import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/sender_model.dart';

import 'package:path_provider/path_provider.dart' as path;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

import '../controllers/controllers.dart';
import 'package:get_it/get_it.dart';

class PhotonReceiver {
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
      var socket =
          await Socket.connect(host, port).timeout(const Duration(seconds: 2));
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
      for (String netAddress in netAddresses) {
        Future<Map<String, dynamic>> res = _connect('$netAddress.$i', 4040);
        list.add(res);
      }
    }

    ///todo add sender info along with the list
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

  static receive(SenderModel senderModel) async {
    //  var data = jsonDecode(resp.body);
    var resp = await Dio()
        .get('http://${senderModel.ip}:${senderModel.port}/getpaths');
    var dataMap = jsonDecode(resp.data);

    for (int i = 0; i < dataMap['paths'].length; i++) {
      await receiveFile(senderModel.ip, dataMap['paths'][i], i, senderModel);
    }
  }

  static receiveFile(ip, filePath, i, SenderModel senderModel) async {
    Dio dio = Dio();
    String? finalPath;
    Directory? directory;
    var getInstance = GetIt.I<PercentageController>();
    //extract filename from filepath send by the sender
    String fileName =
        filePath.split(senderModel.os == "windows" ? r'\' : r'/').last;

    switch (Platform.operatingSystem) {
      case "android":
        directory = Directory('/storage/emulated/0/Download/');
        finalPath = p.join(directory.path, fileName);

        break;
      case "ios":
        directory = await path.getApplicationDocumentsDirectory();
        break;
//currently it will create folder photon inside downloads directory if folder' photon' doesn't exist
//implement the same for macOs and linux
      case "windows":
        directory = await path.getDownloadsDirectory();
        finalPath = p.join(directory!.path, fileName);
        break;
      case "linux":
      case "macos":
        directory = await path.getDownloadsDirectory();
        finalPath = p.join(directory!.path, fileName);
        break;
      default:
        print("Error");
    }

    try {
    
      await dio.download(
        'http://$ip:4040/${i.toString()}',
        finalPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // print("${(received / total * 100).toStringAsFixed(0)}%");

            getInstance.percentage[i].value =
                (double.parse((received / total * 100).toStringAsFixed(0)));

            // print(GetIt.I<PercentageController>().percentage[i].value);
          }
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<String?> getPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await path.getApplicationDocumentsDirectory();
      } else if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await path.getExternalStorageDirectory();
        }
      }
    } catch (err) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }
}
