// ignore: file_names
class SenderModel {
  String? ip;
  int? port;
  dynamic host;
  dynamic os;
  dynamic version;
  SenderModel({this.ip, this.port, this.host, this.os, this.version});
  factory SenderModel.fromJson(json) {
    return SenderModel(
        ip: json['ip'],
        port: json['port'],
        host: json['host'],
        os: json['os'],
        version: json['version']);
  }
}
