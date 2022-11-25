import "package:receive_sharing_intent/receive_sharing_intent.dart";

handleSharingIntent() async {
  List<SharedMediaFile> fileList = await ReceiveSharingIntent.getInitialMedia();
  if (fileList.length != 0) {
    return true;
  }

  return false;
}
