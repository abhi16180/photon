import 'dart:convert';
import 'dart:io';
import 'package:photon/models/server_model.dart';

import 'file_services.dart';
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
      return false;
    }

    _server.listen(
      (HttpRequest request) async {
        if (request.requestedUri.toString() ==
            'http://$_address:4040/photon-server') {
          request.response.write(jsonEncode(serverInf));
          request.response.close();
        } else if (request.requestedUri.toString() ==
            'http://$_address:4040/getpaths') {
          request.response.write(jsonEncode({'paths': fileList}));
          request.response.close();
        } else if (request.requestedUri.toString() ==
            'http://$_address:4040/favicon.ico') {
        } else if (request.requestedUri.toString() ==
            'http://$_address:4040/') {
        } else {
          String filePath = fileList[
              int.parse(request.requestedUri.toString().split('/').last)]!;
          File file = File(filePath);
          int size = await file.length();
          String fileName =
              filePath.split(Platform.isWindows ? r'\' : 'r').last;

          request.response.headers.contentType = ContentType(
            'application',
            'octet-stream',
            charset: 'utf-8',
          );
          request.response.headers.add(
            'Content-Transfer-Encoding',
            'Binary',
          );
          request.response.headers.add(
            'Content-disposition',
            'attachment; filename=$fileName',
          );

          request.response.headers.add(
            'Content-length',
            size,
          );
          try {
            await file.openRead().pipe(request.response);
            request.response.close();
          } catch (_) {}
        }
      },
    );
    return true;
  }

  static share() async {
    if (await getFilesPath()) {
      await assignIP();
      var res= _startServer(_fileList);
      return await res;
    } else {
      return null;
    }
  }

  static closeServer() async {
    try {
      await _server.close();
      print('closed');
    } catch (e) {
      print("Server not yet started");
    }
  }

  //get details about server
  static getServerInfo() {
    var info = {
      'ip': _server.address.address,
      'port': _server.port,
      'host': Platform.localHostname,
      'os': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
    };
    ServerModel serverData = ServerModel.fromJson(info);
    return serverData;
  }

  bool get hasMultipleFiles => _fileList.length > 1 ? true : false;
}
