import "package:receive_sharing_intent/receive_sharing_intent.dart";

handleSharingIntent() async {
  List<SharedMediaFile> fileList = await ReceiveSharingIntent.getInitialMedia();
  String? rawText = await ReceiveSharingIntent.getInitialText();
  if (fileList.isNotEmpty) {
    return (true, "file");
  }
  if (rawText != null) {
    if (rawText.isNotEmpty) {
      return (true, "raw_text");
    }
  }

  return (false, "");
}
