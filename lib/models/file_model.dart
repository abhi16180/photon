import 'dart:io';

class FileModel {
  String name;
  int size;
  File file;
  String? extn;
  FileModel(
      {required this.name,
      required this.size,
      required this.file,
      required this.extn});

  factory FileModel.fromFileData(data) {
    return FileModel(
        name: data['name'],
        size: data['size'],
        file: data['file'],
        extn: data['extn']);
  }
}
