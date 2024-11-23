import "package:receive_sharing_intent/receive_sharing_intent.dart";

handleSharingIntent() async {
  List<SharedMediaFile> initialMediaList =
      await ReceiveSharingIntent.instance.getInitialMedia();
  if (initialMediaList.isEmpty) {
    return (false, "");
  }
  SharedMediaType type = SharedMediaType.file;
  for (var sharedMediaFile in initialMediaList) {
    if (sharedMediaFile.type != type) {
      type = sharedMediaFile.type;
    }
  }
  return (true, type == SharedMediaType.file ? "file" : "raw_text");
}
