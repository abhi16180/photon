import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/file_model.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/models/share_error_model.dart';
import 'package:photon/services/device_service.dart';
import 'package:photon/views/share_ui/share_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:hive/hive.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';
import '../components/dialogs.dart';
import '../components/snackbar.dart';
import '../main.dart';
import 'file_services.dart';

class PhotonSender {
  static late HttpServer _server;
  static String _address = '';
  static late List<String?> _fileList;
  static late int _randomSecretCode;
  static late String photonURL;
  static late Uint8List avatar;
  static String _rawText = "";
  static String _parentFolder = "";
  static DeviceService? deviceService;
  static SafUtil safUtils = SafUtil();

  // only for SAF document files
  static List<String?> _decodedFilePaths = [];

  static const platform = MethodChannel('dev.abhi.photon');

  static void setRawText(txt) {
    _rawText = txt;
  }

  static String getRawText() {
    return _rawText;
  }

  static setFilesPath({List<String> fileList = const <String>[]}) async {
    //flutter specific package
    if (fileList.isNotEmpty) {
      _fileList = fileList;
      return true;
    }
    if (Platform.isAndroid) {
      List<SafDocumentFile>? safDocs = await safUtils.pickFiles();
      if (safDocs != null) {
        _fileList = safDocs.map((item) => item.uri).toList();
        return true;
      }
      return false;
    }
    _fileList = await FileUtils.pickFiles();
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
    String extIntentType = "file",
    List<String> fileList = const <String>[],
    bool isRawText = false,
    bool isFolder = false,
  }) async {
    Navigator.pop(nav.currentContext!);
    Map<String, dynamic> shareRespMap = await PhotonSender.share(
        nav.currentContext,
        externalIntent: externalIntent,
        extIntentType: extIntentType,
        isRawText: isRawText,
        isFolder: isFolder,
        fileList: fileList);
    ShareError shareErr = ShareError.fromMap(shareRespMap);
    switch (shareErr.hasError) {
      case true:
        // ignore: use_build_context_synchronously
        showSnackBar(nav.currentContext, '${shareErr.errorMessage}');
        break;

      case false:
        Navigator.of(nav.currentContext!)
            .push(MaterialPageRoute(builder: (ctx) {
          return SharePage(
            isRawText: isRawText,
            isFolder: isFolder,
          );
        }));
        break;
    }
  }

  static Future<Map<String, dynamic>> share(
    context, {
    bool externalIntent = false,
    String extIntentType = "file",
    List<String> fileList = const <String>[],
    bool isRawText = false,
    bool isFolder = false,
  }) async {
    await assignIP();
    if (externalIntent) {
      // When user tries to share files opened / listed on external app
      // Photon will be opened along with intended files' paths
      return await shareFromExternalIntent(extIntentType, context);
    } else {
      if (isRawText) {
        // assign empty list to late init var _fileList
        _fileList = [];
        Future<Map<String, dynamic>> res =
            _startServer(_fileList, context, isRawText: isRawText);
        return await res;
      } else {
        if (isFolder) {
          String? dirPath;
          List<String> paths = [];
          if (Platform.isAndroid) {
            SafDocumentFile? dir = await FileUtils.pickDirectoryAndroid();
            if (dir != null) {
              paths = await FileUtils.listFilesForPickedDir(dir);
            }
            _fileList = paths;
          } else {
            dirPath = await FilePicker.platform.getDirectoryPath();
            if (dirPath != null) {
              _parentFolder = dirPath;
              Directory directory = Directory(dirPath);
              (await directory.list(recursive: true).toList())
                  .whereType<File>()
                  .forEach((file) {
                paths.add(file.path);
              });
            }
            _fileList = paths;
          }
          if (_fileList.isEmpty) {
            return {
              'hasErr': true,
              'type': 'file',
              'errMsg': "No folder chosen"
            };
          }
          _decodedFilePaths = await FileUtils.getDecodedPaths(_fileList,
              isAPK: fileList.isNotEmpty);
          Future<Map<String, dynamic>> res = _startServer(_fileList, context,
              isRawText: isRawText, isFolder: isFolder);
          return res;
        } else {
          // User manually opens photon
          // Selects files
          if (await setFilesPath(fileList: fileList)) {
            await storeSentFileHistory(_fileList);
            _decodedFilePaths = await FileUtils.getDecodedPaths(_fileList,
                isAPK: fileList.isNotEmpty);
            Map<String, dynamic> res = await _startServer(_fileList, context,
                isApk: fileList.isNotEmpty);
            return res;
          } else {
            return {'hasErr': true, 'type': 'file', 'errMsg': "No file chosen"};
          }
        }
      }
    }
  }

  static Future<Map<String, dynamic>> _startServer(
    List<String?> fileList,
    context, {
    bool isApk = false,
    bool isRawText = false,
    bool isFolder = false,
  }) async {
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
      deviceService = DeviceService.getDeviceService();
      deviceService!.advertise(_address);
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
        'avatar': avatar,
        'type': isRawText ? 'raw_text' : "file",
      };
    } catch (e) {
      return {'hasErr': true, 'type': 'server', 'errMsg': '$e'};
    }

    bool? allowRequest;
    photonURL = 'http://$_address:4040/photon-server';
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
            request.response.write(jsonEncode({
              'code': _randomSecretCode,
              'accepted': true,
              "type": isRawText
                  ? "raw_text"
                  : isFolder
                      ? "folder"
                      : "file",
              "parent_folder": _parentFolder,
            }));
            request.response.close();
          } else {
            request.response.write(
              jsonEncode({'code': -1, 'accepted': false}),
            );
            request.response.close();
          }
        } else if (request.requestedUri.toString() ==
            'http://$_address:4040/getpaths') {
          var paths =
              _decodedFilePaths.isNotEmpty ? _decodedFilePaths : _fileList;
          request.response.write(jsonEncode({'paths': paths, 'isApk': isApk}));

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
        } else if (request.requestedUri.toString() ==
            "http://$_address:4040/$_randomSecretCode/data/type") {
          String type = "file";
          if (isFolder) {
            type = "folder";
          } else if (isRawText) {
            type = "raw_text";
          }
          request.response.write(jsonEncode({"type": type}));
          request.response.close();
        } else if (request.requestedUri.toString() ==
            "http://$_address:4040/$_randomSecretCode/text") {
          request.response.write(jsonEncode({"raw_text": _rawText}));
          request.response.close();
        } else {
          //uri should be in format http://ip:port/secretcode/file-index
          List uriParts = request.requestedUri.toString().split('/');
          if (int.parse(uriParts[uriParts.length - 2]) == _randomSecretCode) {
            try {
              FileModel fileModel = await FileUtils.extractFileData(
                  fileList[int.parse(
                      request.requestedUri.toString().split('/').last)]!,
                  isApk: isApk);
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
                await _streamFileObject(isApk, fileModel, request);
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

  static Future<void> _streamFileObject(
      bool isApk, FileModel fileModel, HttpRequest request) async {
    // On non android devices [macos,linux,windows
    // Uses real path to stream file
    // Uses cached path for apk files
    if (isApk || !Platform.isAndroid) {
      await fileModel.file.openRead().pipe(request.response);
      request.response.close();
      return;
    }
    // On android uses SAF to stream from uri path
    // Does not use caching to speed up the process and prevent
    // potential memory issues
    SafDocumentFile f = fileModel.file as SafDocumentFile;
    var stream = await SafStream().readFileStream(f.uri);
    await request.response.addStream(stream);
    request.response.close();
    return;
  }

  static Future<Map<String, dynamic>> shareFromExternalIntent(
      String extIntentType, context) async {
    // When user tries to share files opened / listed on external app
    // Photon will be opened along with intended files' paths
    if (extIntentType == "file") {
      List<SharedMediaFile> sharedMediaFiles =
          await ReceiveSharingIntent.instance.getInitialMedia();
      _fileList = sharedMediaFiles.map((e) => e.path).toList();
    } else {
      _fileList = [];
      _rawText =
          (await ReceiveSharingIntent.instance.getInitialMedia())[0].path;
    }
    Future<Map<String, dynamic>> res = _startServer(_fileList, context,
        isRawText: extIntentType == "raw_text");
    return await res;
  }

  static closeServer(context) async {
    try {
      await _server.close();
      await FileUtils.clearCache();
      if (deviceService != null) {
        await deviceService!.stopAdvertising();
      }
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

  static String get getPhotonLink => photonURL;
}
