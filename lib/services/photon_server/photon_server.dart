import 'dart:io';
import '../file_methods.dart';
import 'package:network_info_plus/network_info_plus.dart';

class PhotonServer {
  static late HttpServer _server;
  static late String _address;
  static late String _ipVersion;
  static late List<String?> _fileList;
  static getFilesPath() async {
    _fileList = await FileMethods.pickFiles();
    if (_fileList.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  static assignIP() async {
    var wifiIP = await NetworkInfo().getWifiIP();
    if (wifiIP != null) {
      _address = wifiIP.toString();
    } else {
      //sometimes when device acts as hotspot it will return null
      //find list of interfaces
      //assign ip with proper ip-address
      List<NetworkInterface> listOfInterfaces = await NetworkInterface.list();
      for (NetworkInterface netInt in listOfInterfaces) {
        for (InternetAddress internetAddress in netInt.addresses) {
          if (internetAddress.address.toString().startsWith('192.168')) {
            _address = internetAddress.address;
            _ipVersion = internetAddress.type.name;
          }
        }
      }
    }
  }

  static _startServer(List<String?> fileList) async {
    try {
      _server = await HttpServer.bind(_address, 4040);
    } catch (e) {
      print('not working ');
    }
    print('server at ${_server.address}');
    _server.listen((HttpRequest request) {
      if (request.requestedUri.toString() ==
          'http://$_address:4040/photon-server') {
        request.response.write('Hello world');
        request.response.close();
      }
    });
  }

  static share() async {
    if (await getFilesPath()) {
      await assignIP();
      await _startServer(_fileList);
    }
  }

  static closeServer() async {
    try {
      await _server.close();
    } catch (e) {
      print("Server not yet started");
    }
  }
}
