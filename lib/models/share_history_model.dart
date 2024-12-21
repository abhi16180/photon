class HistoryList {
  List<ShareHistory> historyList;

  HistoryList({required this.historyList});

  factory HistoryList.fromData(List dataList) {
    List<ShareHistory> history =
        dataList.map((map) => ShareHistory.fromMap(map)).toList();
    return HistoryList(historyList: history);
  }
}

class ShareHistory {
  String fileName;
  String filePath;
  DateTime date;
  String type;

  ShareHistory(
      {required this.fileName,
      required this.filePath,
      required this.date,
      required this.type});

  factory ShareHistory.fromMap(Map<dynamic, dynamic> map) {
    var type = "file";
    if (map.keys.contains("type")) {
      type = map["type"];
    }
    ;
    return ShareHistory(
      fileName: map['fileName'],
      filePath: map['filePath'],
      date: map['date'],
      type: type,
    );
  }
}
