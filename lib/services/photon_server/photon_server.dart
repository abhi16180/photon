import 'dart:convert';
import 'dart:io';
import '../file_methods.dart';
import 'package:network_info_plus/network_info_plus.dart';

class PhotonServer {
  static late HttpServer _server;
  static late String _address;
  static late List<String?> _fileList;

  static getFilesPath() async {
    //flutter specific package
    _fileList = await FileMethods.pickFiles();
    if (_fileList.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  static assignIP() async {
    //todo handle exception when no ip available
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
    
          }
        }
      }
    }
  }

  static _startServer(List<String?> fileList) async {
    //todo remove print statements
    late Map<String, Object> serverInf;
    try {
      _server = await HttpServer.bind(_address, 4040);
      serverInf = {
        'os': {
          'name': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion
        },
        'host': Platform.localHostname,
      
      };
    } catch (e) {
      print('$e ');
    }
    print('server at ${_server.address}');
    _server.listen((HttpRequest request) {
      if (request.requestedUri.toString() ==
          'http://$_address:4040/photon-server') {
        request.response.write(jsonEncode(serverInf));
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
