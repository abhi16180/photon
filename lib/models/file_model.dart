import 'dart:io';

class FileModel {
  String name;
  int size;
  File file;
  FileModel({required this.name, required this.size, required this.file});

  factory FileModel.fromFileData(data) {
    return FileModel(
        name: data['name'], size: data['size'], file: data['file']);
  }
}
