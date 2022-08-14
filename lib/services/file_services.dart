import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path;

import 'package:photon/models/file_model.dart';

import '../models/sender_model.dart';

class FileMethods {
  //todo implement separate file picker for android to avoid caching
  static Future<List<String?>> pickFiles() async {
    FilePickerResult? files = await FilePicker.platform.pickFiles(
        allowMultiple: true, type: FileType.any, onFileLoading: (status) {});
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

  static Future<FileModel> extractFileData(path) async {
    File file = File(path);
    int size = await file.length();
    String fileName = path.split(Platform.isWindows ? r'\' : '/').last;
    String type = path.toString().split('.').last;
    return FileModel.fromFileData(
        {'name': fileName, 'size': size, 'file': file, 'extension': type});
  }

  static Future<String> getSavePath(
      String filePath, SenderModel senderModel) async {
    // ignore: unused_local_variable
    String? finalPath;
    Directory? directory;
    //extract filename from filepath send by the sender
    String fileName =
        filePath.split(senderModel.os == "windows" ? r'\' : r'/').last;

    switch (Platform.operatingSystem) {
      case "android":
        directory = Directory('/storage/emulated/0/Download/');
        finalPath = p.join(directory.path, fileName);
        break;
      case "ios":
        directory = await path.getApplicationDocumentsDirectory();
        break;
      case "windows":
        directory = await path.getDownloadsDirectory();
        finalPath = p.join(directory!.path, fileName);
        break;
      case "linux":
      case "macos":
        directory = await path.getDownloadsDirectory();
        finalPath = p.join(directory!.path, fileName);
        break;
      default:
        debugPrint("Error");
    }

    return finalPath!;
  }

//for receiver to display filenames
  static Future<List<String>> getFileNames(SenderModel senderModel) async {
    var resp = await Dio()
        .get('http://${senderModel.ip}:${senderModel.port}/getpaths');
    var filePathMap = jsonDecode(resp.data);
    List<String> fileNames = [];
    for (String path in filePathMap['paths']) {
      fileNames.add(path.split(senderModel.os == "windows" ? r'\' : r'/').last);
    }
    return fileNames;
  }
}
