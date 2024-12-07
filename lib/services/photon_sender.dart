import 'dart:convert';
import 'dart:io';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/file_model.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/models/share_error_model.dart';
import 'package:photon/services/device_service.dart';
import 'package:photon/views/share_ui/share_page.dart';
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
  static late String photonURL;
  static late Uint8List avatar;
  static String _rawText = "";
  static String _parentFolder = "";
  static DeviceService? deviceService;

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
    String extIntentType = "file",
    List<String> fileList = const <String>[],
    bool isRawText = false,
    bool isFolder = false,
  }) async {
    if (externalIntent) {
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
      await assignIP();
      Future<Map<String, dynamic>> res = _startServer(_fileList, context,
          isRawText: extIntentType == "raw_text");
      return await res;
    } else if (isRawText) {
      await assignIP();
      // assign empty list to late init var _fileList
      _fileList = [];
      Future<Map<String, dynamic>> res =
          _startServer(_fileList, context, isRawText: isRawText);
      return await res;
    } else if (isFolder) {
      String? dirPath;
      if (Platform.isAndroid) {
        dirPath = await pickFolderAndroid(context);
      } else {
        dirPath = await FilePicker.platform.getDirectoryPath();
      }
      if (dirPath != null) {
        _parentFolder = dirPath;
        Directory directory = Directory(dirPath);
        List<String> paths = [];
        (await directory.list(recursive: true).toList())
            .whereType<File>()
            .forEach((file) {
          paths.add(file.path);
        });
        _fileList = paths;
        await assignIP();
        Future<Map<String, dynamic>> res = _startServer(_fileList, context,
            isRawText: isRawText, isFolder: isFolder);

        return res;
      } else {
        // Navigator.of(context).pop();
        return {'hasErr': true, 'type': 'file', 'errMsg': "No file chosen"};
      }
    } else {
      // User manually opens photon
      // Selects files
      if (await setFilesPath(fileList: fileList)) {
        await assignIP();
        await storeSentFileHistory(_fileList);
        Map<String, dynamic> res =
            await _startServer(_fileList, context, isApk: fileList.isNotEmpty);
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

  static pickFolderAndroid(BuildContext context) async {
    try {
      var isAllowed = await externalStoragePermissionHandling(context);
      if (!isAllowed) {
        return null;
      }
      Directory? newDirectory = await FolderPicker.pick(
          allowFolderCreation: true,
          context: context,
          rootDirectory: Directory(FolderPicker.rootPath),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))));
      if (newDirectory != null) {
        return newDirectory.path;
      }
      return null;
    } catch (_) {}
  }

  static Future<bool> externalStoragePermissionHandling(
      BuildContext context) async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      return true;
    }
    if (status.isRestricted) {
      status = await Permission.manageExternalStorage.request();
    }
    if (status!.isDenied) {
      status = await Permission.manageExternalStorage.request();
    }
    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content:
            Text('Please add permission for app to manage external storage'),
      ));
    }
    return false;
  }
}
