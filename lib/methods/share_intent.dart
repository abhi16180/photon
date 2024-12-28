import "package:receive_sharing_intent/receive_sharing_intent.dart";

List<String> textFileExtensions = [
  "txt", // Plain text
  "html", "htm", // HTML
  "css", // CSS
  "js", // JavaScript
  "csv", // CSV
  "md", // Markdown
  "xml", // XML
  "rtf", // Rich Text
  "sgml", // SGML
  "tsv", // Tab-separated values
  "mml", // MathML
  "n3", // Notation3
  "vtt", // Web Video Text Tracks
  "ttl", // Turtle
  "yaml", "yml", // YAML
  "appcache" // Cache manifest
];

handleSharingIntent() async {
  List<SharedMediaFile> initialMediaList =
      await ReceiveSharingIntent.instance.getInitialMedia();
  if (initialMediaList.isEmpty) {
    return (false, "");
  }
  late SharedMediaType type;
  for (var sharedMediaFile in initialMediaList) {
    type = sharedMediaFile.type;
    if (type == SharedMediaType.text) {
      if (!isRawText(sharedMediaFile)) {
        type = SharedMediaType.file;
      }
    }
    break;
  }
  return (true, type == SharedMediaType.text ? "raw_text" : "file");
}

isRawText(SharedMediaFile sharedMediaFile) {
  var extn = sharedMediaFile.path.split(".").last;
  return (!textFileExtensions.contains(extn));
}
