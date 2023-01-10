import "package:receive_sharing_intent/receive_sharing_intent.dart";

handleSharingIntent() async {
  List<SharedMediaFile> fileList = await ReceiveSharingIntent.getInitialMedia();
  if (fileList.isNotEmpty) {
    return true;
  }

  return false;
}
