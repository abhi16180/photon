import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/sender_model.dart';


class PhotonReceiver {
  ///to get network address [assumes class C address]
  static String getNetAddress(String ip) {
    var ipToList = ip.split('.');
    ipToList.removeLast();
    return ipToList.join('.');
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
    String netAddress = getNetAddress(await getIP());

    for (int i = 2; i < 255; i++) {
      for (int port in [4040, 4999, 5000]) {
        Future<Map<String, dynamic>> res = _connect('$netAddress.$i', port);
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
}
