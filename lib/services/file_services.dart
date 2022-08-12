import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:photon/models/file_model.dart';

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

  static getSaveDirectory() async {}
}
