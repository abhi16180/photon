import 'dart:convert';
import 'dart:io';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/file_model.dart';
import 'package:photon/models/sender_model.dart';

import 'file_services.dart';

class PhotonSender {
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
    String ip = await getIP();
    _address = ip;
  }

  static _startServer(List<String?> fileList) async {
    //todo remove print statements
    late Map<String, Object> serverInf;
    //check if no proper address is assigned

    if (_address == '') {
      return false;
    }
    try {
      _server = await HttpServer.bind(_address, 4040);
      serverInf = {
        'ip': _server.address.address,
        'port': _server.port,
        'host': Platform.localHostname,
        'os': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
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
          try {
            FileModel fileModel = await FileMethods.extractFileData(fileList[
                int.parse(request.requestedUri.toString().split('/').last)]!);

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
              'attachment; filename=${fileModel.name}',
            );

            request.response.headers.add('Content-length', fileModel.size);
            try {
              await fileModel.file.openRead().pipe(request.response);
              request.response.close();
            } catch (_) {}
          } catch (_) {
            request.response.write('Format error');
            request.response.close();
          }
        }
      },
    );
    return true;
  }

  static share() async {
    if (await getFilesPath()) {
      await assignIP();
      var res = _startServer(_fileList);
      return await res;
    } else {
      return null;
    }
  }

  static closeServer() async {
    try {
      await _server.close();
      await FileMethods.clearCache();
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
    SenderModel senderData = SenderModel.fromJson(info);
    return senderData;
  }

  bool get hasMultipleFiles => _fileList.length > 1;
}
