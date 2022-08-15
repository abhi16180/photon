import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/file_model.dart';
import 'package:photon/models/sender_model.dart';

import 'file_services.dart';

class PhotonSender {
  static late HttpServer _server;
  static late String _address;
  static late List<String?> _fileList;
  static late int _randomSecretCode;

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
    //todo add option to choose ip from list
    List<String> ip = await getIP();
    _address = ip.first;
  }

  static _startServer(List<String?> fileList, BuildContext context) async {
    //todo remove print statements
    late Map<String, Object> serverInf;

    //check if no proper address is assigned

    if (_address == '') {
      return false;
    }
    try {
      print('object');
      _server = await HttpServer.bind(_address, 4040);

      _randomSecretCode = getRandomNumber();
      serverInf = {
        'ip': _server.address.address,
        'port': _server.port,
        'host': Platform.localHostname,
        'os': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'files-count': _fileList.length,
      };
    } catch (e) {
      return false;
    }
    bool? allowRequest;
    _server.listen(
      (HttpRequest request) async {
        if (request.requestedUri.toString() ==
            'http://$_address:4040/photon-server') {
          request.response.write(jsonEncode(serverInf));
          request.response.close();
        } else if (request.requestedUri.toString() ==
            'http://$_address:4040/get-code') {
          var receiverData = jsonDecode(request.requestedUri.data.toString());
          await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Request from receiver'),
                  content: Text(
                      "${receiverData['receiver-name']} -(${receiverData['os']}) is requesting for files. Would you like to share with them ?"),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        allowRequest = true;
                        Navigator.of(context).pop();
                      },
                      child: const Text('Accept'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        allowRequest = false;
                        Navigator.of(context).pop();
                      },
                      child: const Text('Deny'),
                    )
                  ],
                );
              });

          if (allowRequest == true) {
            request.response.write(
                jsonEncode({'code': _randomSecretCode, 'accepted': true}));
            request.response.close();
          } else {
            request.response.write(
              jsonEncode({'code': -1, 'accepted': false}),
            );
            request.response.close();
          }
        } else if (request.requestedUri.toString() ==
            'http://$_address:4040/getpaths') {
          request.response.write(jsonEncode({'paths': fileList}));
          request.response.close();
        } else if (request.requestedUri.toString() ==
            'http://$_address:4040/favicon.ico') {
        } else if (request.requestedUri.toString() ==
            'http://$_address:4040/') {
        } else {
//uri should be in format http://ip:port/secrecode/file-index
          List requriToList = request.requestedUri.toString().split('/');
          if (int.parse(requriToList[requriToList.length - 2]) ==
              _randomSecretCode) {
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
            } catch (e) {
              request.response.write(e);
              request.response.close();
            }
          } else {
            request.response
                .write('Wrong secret-code.Photon-server denied access');
            request.response.close();
            //todo close the server if code is wrong _server.close();
          }
        }
      },
    );
    return true;
  }

  static share(context) async {
    if (await getFilesPath()) {
      await assignIP();
      var res = _startServer(_fileList, context);
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
      'files-count': _fileList.length,
    };
    SenderModel senderData = SenderModel.fromJson(info);
    return senderData;
  }

  bool get hasMultipleFiles => _fileList.length > 1;
}
