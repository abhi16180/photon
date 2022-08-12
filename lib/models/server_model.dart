// ignore: file_names
class ServerModel {
  String? ip;
  int? port;
  dynamic host;
  dynamic os;
  dynamic version;
  ServerModel({this.ip, this.port, this.host, this.os, this.version});
  factory ServerModel.fromJson(json) {
    return ServerModel(
        ip: json['ip'],
        port: json['port'],
        host: json['host'],
        os: json['os'],
        version: json['version']);
  }
}
