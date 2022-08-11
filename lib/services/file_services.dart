import 'package:file_picker/file_picker.dart';

class FileMethods {
  static Future<List<String?>> pickFiles() async {
    FilePickerResult? files =
        await FilePicker.platform.pickFiles(allowMultiple: true,type: FileType.any);
    if (files == null) {
      return [];
    } else {
     
      return files.paths;
    }
  }

  static getSaveDirectory() async {}
}
