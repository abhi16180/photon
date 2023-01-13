import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:photon/models/file_model.dart';

import '../models/sender_model.dart';

class FileMethods {
  //todo implement separate file picker for android to avoid caching
  static Future<List<String?>> pickFiles() async {
    FilePickerResult? files = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.any, withData: false);
    if (files == null) {
      return [];
    } else {
      return files.paths;
    }
  }

  ///This typically relates to cached files that are stored in the cache directory
  ///Works only for android and ios
  static clearCache() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await FilePicker.platform.clearTemporaryFiles();
    }
  }

  static Future<FileModel> extractFileData(path, {bool isApk = false}) async {
    File file = File(path);
    int size = await file.length();
    late String fileName;
    if (isApk) {
      fileName =
          path.split(Platform.pathSeparator)[4].toString().split('.').last;
    } else {
      fileName = path.split(Platform.isWindows ? r'\' : '/').last;
    }

    String type = path.toString().split('.').last;
    return FileModel.fromFileData(
        {'name': fileName, 'size': size, 'file': file, 'extension': type});
  }

  static Future<String> getSavePath(
      String filePath, SenderModel senderModel) async {
    // ignore: unused_local_variable
    String? savePath;
    Directory? directory;
    //extract filename from filepath send by the sender
    String fileName =
        filePath.split(senderModel.os == "windows" ? r'\' : r'/').last;
    directory = await getSaveDirectory();
    savePath = p.join(directory.path, fileName);

    //checking if file can be created at savePath
    try {
      // ignore: unused_local_variable
      var file = await File(savePath).create();
    } catch (_) {
      //renaming the path

      var rnd = Random();

      List newPath = savePath.split('.');
      newPath[0] = newPath[0] + "${rnd.nextInt(1000)}";
      savePath = newPath.join('.');
    }
    return savePath;
  }

//for receiver to display filenames
  static Future<List<String>> getFileNames(SenderModel senderModel) async {
    var resp = await Dio()
        .get('http://${senderModel.ip}:${senderModel.port}/getpaths');
    Map<String, dynamic> filePathMap = jsonDecode(resp.data);
    List<String> fileNames = [];
    if (filePathMap.containsKey('isApk')) {
      if (filePathMap['isApk']) {
        for (String path in filePathMap['paths']) {
          fileNames.add(
              '${path.split("/")[4].split(".").last.split('-').first}.apk');
        }
      }
    } else {
      for (String path in filePathMap['paths']) {
        fileNames
            .add(path.split(senderModel.os == "windows" ? r'\' : r'/').last);
      }
    }
    return fileNames;
  }

  static editDirectoryPath(String path) {
    var box = Hive.box('appData');
    box.put('directoryPath', path);
  }

  static Future<Directory> getSaveDirectory() async {
    late Directory directory;
    var box = Hive.box('appData');
    if (box.get('directoryPath') == null) {
      switch (Platform.operatingSystem) {
        case "android":
          var temp = Directory('/storage/emulated/0/Download/');
          (await temp.exists())
              ? directory = temp
              : directory = await getApplicationDocumentsDirectory();
          break;

        case "ios":
          directory = await path.getApplicationDocumentsDirectory();
          break;

        case "windows":
        case "linux":
        case "macos":
          directory = (await path.getDownloadsDirectory())!;
          break;

        default:
          debugPrint("Unable to get file-save path");
      }
    } else {
      directory = Directory(box.get('directoryPath'));
    }

    var tempDir = directory;
    //check if ends with / or \
    if (directory.path.endsWith(Platform.pathSeparator)) {
      directory = Directory("${directory.path}Photon");
    } else {
      directory = Directory("${directory.path}${Platform.pathSeparator}Photon");
    }

    try {
      await directory.create();
    } catch (e) {
      debugPrint("Unable to create directory at ${directory.path}");
      return tempDir;
    }

    return directory;
  }
}
