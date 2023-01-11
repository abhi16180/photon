// ignore: file_names
import 'package:flutter/foundation.dart';

class SenderModel {
  String? ip;
  int? port;
  int? filesCount;
  dynamic host;
  dynamic os;
  dynamic version;
  Uint8List? avatar;
  SenderModel(
      {this.ip,
      this.port,
      this.filesCount,
      this.host,
      this.os,
      this.version,
      this.avatar});
  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      ip: json['ip'],
      port: json['port'],
      filesCount: json['files-count'],
      host: json['host'],
      os: json['os'],
      version: json['version'],
      avatar: json.containsKey('avatar')
          ? Uint8List.fromList(
              List<int>.from(json['avatar']),
            )
          : null,
    );
  }
}
