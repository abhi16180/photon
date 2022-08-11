// ignore: file_names
class ServerModel {
  String ip;
  int port;
  dynamic host;
  dynamic os;
  dynamic version;
  ServerModel(
      {required this.ip,
      required this.port,
      required this.host,
      required this.os,
      required this.version});
  factory ServerModel.fromJson(json) {
    return ServerModel(
        ip: json['ip'],
        port: json['port'],
        host: json['host'],
        os: json['os'],
        version: json['version']);
  }
}
