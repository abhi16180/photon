import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:photon/models/file_model.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';

import '../models/sender_model.dart';
import 'device_service.dart';

class FileUtils {
  static int filePathRetries = 0;
  static const maxFilePathRetries = 10;
  static SafUtil safUtils = SafUtil();
  static final dio = Dio();

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
      var appDir = (await getTemporaryDirectory()).path;
      Directory(appDir).delete(recursive: true);
    }
  }

  static Future<FileModel> extractFileData(path, {bool isApk = false}) async {
    // if platform is android use SAF
    // for APK fallback to old flow
    if (Platform.isAndroid && !isApk) {
      return await extractFileDataWithSAF(path, isApk: isApk);
    }
    File file = File(path);
    int size = await file.length();
    late String fileName;
    if (isApk) {
      fileName =
          path.split(Platform.pathSeparator)[4].toString().split('-').first;
    } else {
      fileName = path.split(Platform.isWindows ? r'\' : '/').last;
    }

    String type = path.toString().split('.').last;
    return FileModel.fromFileData(
        {'name': fileName, 'size': size, 'file': file, 'extension': type});
  }

  static Future<FileModel> extractFileDataWithSAF(path,
      {bool isApk = false}) async {
    SafDocumentFile? safDoc = await safUtils.documentFileFromUri(path, false);
    int size = safDoc!.length;
    late String fileName;
    if (isApk) {
      fileName = Uri.decodeComponent(safDoc.name).split("/").last;
    } else {
      fileName = safDoc.name;
    }

    String type = path.toString().split('.').last;
    return FileModel.fromFileData(
        {'name': fileName, 'size': size, 'file': safDoc, 'extension': type});
  }

  static Future<String> getSavePath(String filePath, SenderModel senderModel,
      {bool isDirectory = false, String directoryPath = ""}) async {
    String? savePath;
    Directory? directory;
    String fileName =
        filePath.split(senderModel.os == "windows" ? r'\' : r'/').last;
    directory = await getSaveDirectory();
    savePath = p.join(directory.path, fileName);
    if (isDirectory) {
      directoryPath.replaceAll(
          senderModel.os == "windows" ? r'\' : r'/', Platform.pathSeparator);
      savePath = p.join(directory.path, directoryPath, fileName);
    } else {
      savePath = p.join(directory.path, fileName);
    }
    return savePath;
  }

  static Future<String> getSavePathForReceiving(
      String filePath, SenderModel senderModel,
      {bool isDirectory = false, String directoryPath = ""}) async {
    // reset retries
    filePathRetries = 0;
    String? savePath = await getSavePath(filePath, senderModel,
        isDirectory: isDirectory, directoryPath: directoryPath);
    return generateFileNameIfExists(savePath);
  }

  static Future<String> generateFileNameIfExists(String path) async {
    if (filePathRetries >= maxFilePathRetries) {
      throw Exception("unable to generate file name for saving");
    }
    bool exists = await File(path).exists();
    if (exists) {
      List<String> parts = path.split('.');
      parts[0] = "${parts[0]}_copy";
      filePathRetries++;
      return generateFileNameIfExists(parts.join('.'));
    }
    return path;
  }

  //for receiver to display filenames
  static Future<List<String>> getFileNames(
      SenderModel senderModel, token) async {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final SecurityContext scontext = SecurityContext();
        HttpClient client = HttpClient(context: scontext);
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return senderModel.ip == host && port == 4040;
        };
        return client;
      },
    );

    var resp = await dio.get(
        '${DeviceService.protocolFromSender}://${senderModel.ip}:${senderModel.port}/getpaths',
        options: Options(headers: {
          "Authorization": token,
        }));
    Map<String, dynamic> filePathMap = jsonDecode(resp.data);
    List<String> fileNames = [];
    if (filePathMap.containsKey('isApk')) {
      if (filePathMap['isApk']) {
        for (String path in filePathMap['paths']) {
          fileNames.add('${path.split("/")[4].split('-').first}.apk');
        }
      } else {
        for (String path in filePathMap['paths']) {
          fileNames
              .add(path.split(senderModel.os == "windows" ? r'\' : r'/').last);
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

  static saveTextFile(String content, fileName) async {
    Directory dir = await getSaveDirectory();
    final String filePath = p.join(
      dir.path,
      '${fileName.split('.').first}.txt',
    );
    try {
      await File(filePath).writeAsString(content);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getTextFilePath(fileName) async {
    return '${(await getSaveDirectory()).path}${Platform.pathSeparator}$fileName.txt';
  }

  static Future<String> getDirectorySavePath(
      SenderModel senderModel, String directoryPath) async {
    // ignore: unused_local_variable
    String? savePath;
    Directory? directory;
    directory = await getSaveDirectory();
    savePath = p.join(directory.path, directoryPath);
    savePath = savePath.replaceAll(
        senderModel.os == "windows" ? r'\' : r'/', Platform.pathSeparator);

    List temp = savePath.split("");
    temp.removeLast();
    return temp.join("");
  }

  static Future<List<String?>> getDecodedPaths(List<String?> uris,
      {bool isAPK = false}) async {
    if (!Platform.isAndroid || isAPK) {
      return uris;
    }
    List<String> decodedPaths = [];
    for (var item in uris) {
      decodedPaths.add(decodeRealPathFromURI(item!));
    }
    return decodedPaths;
  }

  // pick directory using with SAF
  static Future<SafDocumentFile?> pickDirectoryAndroid() async {
    return await safUtils.pickDirectory(persistablePermission: true);
  }

  // recursively list all the uris in directories and subdirectories
  // within selected folder
  static Future<List<String>> listFilesForPickedDir(SafDocumentFile dir) async {
    List<SafDocumentFile> dirs = [dir];
    List<String> uris = [];
    while (dirs.isNotEmpty) {
      SafDocumentFile last = dirs.removeLast();
      List<SafDocumentFile> entities = await safUtils.list(last.uri);
      for (var entity in entities) {
        if (entity.isDir) {
          dirs.add(entity);
        } else {
          uris.add(entity.uri);
        }
      }
    }
    return uris;
  }

  static decodeRealPathFromURI(String uriString) {
    final uri = Uri.parse(uriString);
    const String splitKey = "primary:";
    final decodedPath = Uri.decodeComponent(uri.path);
    if (decodedPath.contains(splitKey)) {
      final finalPath = decodedPath.split(splitKey).last;
      return finalPath;
    } else {
      throw Exception("This folder is not supported for folder share");
    }
  }
}
