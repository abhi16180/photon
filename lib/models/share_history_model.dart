class HistoryList {
  List<ShareHistory> historyList;

  HistoryList({required this.historyList});

  factory HistoryList.formData(List dataList) {
    List<ShareHistory> history =
        dataList.map((map) => ShareHistory.fromMap(map)).toList();
    return HistoryList(historyList: history);
  }
}

class ShareHistory {
  String fileName;
  String filePath;
  DateTime date;

  ShareHistory(
      {required this.fileName, required this.filePath, required this.date});

  factory ShareHistory.fromMap(map) {
    return ShareHistory(
        fileName: map['fileName'],
        filePath: map['filePath'],
        date: map['date']);
  }
}
