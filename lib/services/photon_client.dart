import 'dart:io';

import '../methods/methods.dart';

class PhotonClient {
  static scan() async {
    var ip = await getIP();
    if (ip == '') {
      print(await NetworkInterface.list());
      List data = await NetworkInterface.list();
      return [''];
    } else {
      return [ip];
    }
  }
}
