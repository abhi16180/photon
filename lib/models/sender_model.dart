// ignore: file_names
class SenderModel {
  String? ip;
  int? port;
  int? filesCount;
  dynamic host;
  dynamic os;
  dynamic version;
  SenderModel(
      {this.ip,
      this.port,
      this.filesCount,
      this.host,
      this.os,
      this.version,
     });
  factory SenderModel.fromJson(json) {
    return SenderModel(
      ip: json['ip'],
      port: json['port'],
      filesCount: json['files-count'],
      host: json['host'],
      os: json['os'],
      version: json['version'],
    
    );
  }
}
