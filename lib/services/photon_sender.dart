import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/file_model.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/models/share_error_model.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:hive/hive.dart';
import '../components/dialogs.dart';
import '../components/snackbar.dart';
import '../main.dart';
import 'file_services.dart';

class PhotonSender {
  static late HttpServer _server;
  static String _address = '';
  static late List<String?> _fileList;
  static late int _randomSecretCode;
  static late String photonLink;
  static late Uint8List avatar;
  static getFilesPath({
    List<String> appList = const <String>[],
    List<String> fileList = const <String>[],
  }) async {
    //flutter specific package
    if (appList.isNotEmpty) {
      _fileList = appList;
      return true;
    }
    _fileList = fileList;
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
    if (ip.isNotEmpty) _address = ip.first;
  }

  static handleSharing({
    bool externalIntent = false,
    List<String> appList = const <String>[],
    List<String> fileList = const <String>[],
  }) async {
    Map<String, dynamic> shareRespMap = await PhotonSender.share(
        nav.currentContext,
        externalIntent: externalIntent,
        appList: appList,
        fileList: fileList);
    ShareError shareErr = ShareError.fromMap(shareRespMap);

    switch (shareErr.hasError) {
      case true:
        // ignore: use_build_context_synchronously
        showSnackBar(nav.currentContext, '${shareErr.errorMessage}');
        break;

      case false:
        // ignore: use_build_context_synchronously
        // Navigator.pushNamed(nav.currentContext!, '/sharepage');
        break;
    }
  }

  static Future<Map<String, dynamic>> _startServer(
      List<String?> fileList, context,
      {bool isApk = false}) async {
    //todo remove print statements
    late Map<String, Object> serverInf;

    //check if no proper address is assigned

    if (_address == '') {
      return {
        'hasErr': true,
        'type': 'ip',
        'errMsg': 'Please connect to wifi or turn on your mobile hotspot'
      };
    }
    try {
      _server = await HttpServer.bind(_address, 4040);
      _randomSecretCode = getRandomNumber();
      Box box = Hive.box('appData');
      String username = box.get('username');
      avatar =
          (await rootBundle.load(box.get('avatarPath'))).buffer.asUint8List();

      serverInf = {
        'ip': _server.address.address,
        'port': _server.port,
        'host': username,
        'os': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'files-count': _fileList.length,
        'avatar': avatar
      };
    } catch (e) {
      return {'hasErr': true, 'type': 'server', 'errMsg': '$e'};
    }

    bool? allowRequest;
    photonLink = 'http://$_address:4040/photon-server';
    _server.listen(
      (HttpRequest request) async {
        if (request.requestedUri.toString() ==
            'http://$_address:4040/photon-server') {
          request.response.write(jsonEncode(serverInf));
          request.response.close();
        } else if (request.requestedUri.toString() ==
            'http://$_address:4040/get-code') {
          String os = (request.headers['os']![0]);
          String username = request.headers['receiver-name']![0];

          allowRequest = await senderRequestDialog(username, os);
          if (allowRequest == true) {
            //appending receiver data
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
          request.response
              .write(jsonEncode({'paths': fileList, 'isApk': isApk}));
          request.response.close();
        } else if (request.requestedUri.toString() ==
            'http://$_address:4040/favicon.ico') {
          request.response.close();
        } else if (request.requestedUri.toString() ==
            "http://$_address:4040/receiver-data") {
          //process receiver data
          processReceiversData({
            "os": request.headers['os']!.first,
            "hostName": request.headers['hostName']!.first,
            'currentFileName':
                int.parse(request.headers['currentFile']!.first) == 0
                    ? ''
                    : fileList[
                            int.parse(request.headers['currentFile']!.first) -
                                1]!
                        .split(Platform.pathSeparator)
                        .last,
            "currentFileNumber": request.headers['currentFile']!.first,
            "receiverID": request.headers['receiverID']!.first,
            "filesCount": fileList.length,
            "isCompleted": request.headers['isCompleted']!.first
          });
        } else {
          //uri should be in format http://ip:port/secretcode/file-index
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

              //to send file size
              request.response.headers.add('Content-length', fileModel.size);

              try {
                //to stream the file
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
    return {
      'hasErr': false,
      'type': null,
      'errMsg': null,
    };
  }

  static Future<Map<String, dynamic>> share(
    context, {
    bool externalIntent = false,
    List<String> appList = const <String>[],
    List<String> fileList = const <String>[],
  }) async {
    if (externalIntent) {
      // When user tries to share files opened / listed on external app
      // Photon will be opened along with intended files' paths.
      List<SharedMediaFile> sharedMediaFiles =
          await ReceiveSharingIntent.getInitialMedia();
      _fileList = sharedMediaFiles.map((e) => e.path).toList();
      await assignIP();
      Future<Map<String, dynamic>> res = _startServer(_fileList, context);
      return await res;
    } else {
      // User manually opens photon
      // Selects files
      if (await getFilesPath(appList: appList, fileList: fileList)) {
        await assignIP();
        await storeSentFileHistory(_fileList);
        Map<String, dynamic> res =
            await _startServer(_fileList, context, isApk: appList.isNotEmpty);
        return res;
      } else {
        return {'hasErr': true, 'type': 'file', 'errMsg': "No file chosen"};
      }
    }
  }

  static closeServer(context) async {
    try {
      await _server.close();
      await FileMethods.clearCache();
    } catch (e) {
      showSnackBar(context, 'Server not started yet');
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
      'avatar': avatar
    };
    SenderModel senderData = SenderModel.fromJson(info);

    return senderData;
  }

  bool get hasMultipleFiles => _fileList.length > 1;
  static String get getPhotonLink => photonLink;
}
