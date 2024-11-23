import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/services/photon_sender.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HandleIntentUI extends StatefulWidget {
  final bool? isRawText;
  final String? rawText;
  const HandleIntentUI({super.key, this.isRawText, this.rawText});

  @override
  State<HandleIntentUI> createState() => _HandleIntentUIState();
}

class _HandleIntentUIState extends State<HandleIntentUI> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share ${widget.isRawText! ? 'text' : 'files'}"),
      ),
      body: FutureBuilder(
        future: ReceiveSharingIntent.instance.getInitialMedia(),
        builder: (context, AsyncSnapshot<List<SharedMediaFile>> snap) {
          isLoading = false;
          if (snap.connectionState == ConnectionState.done) {
            if (widget.isRawText!) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(snap.data![0].path),
                ),
              );
            } else {
              List data = snap.data!.map((e) => e.path).toList();
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: getFileIcon(
                        data[i].toString().split('.').last,
                      ),
                      title: Text(
                        data[i].toString().split(Platform.pathSeparator).last,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  });
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: StatefulBuilder(
        builder: (context, sts) {
          return isLoading
              ? const CircularProgressIndicator()
              : FloatingActionButton.extended(
                  icon: const Icon(Icons.arrow_right_rounded),
                  onPressed: () async {
                    sts(() {
                      isLoading = true;
                    });
                    await PhotonSender.handleSharing(
                        externalIntent: true,
                        isRawText: widget.isRawText!,
                        extIntentType: widget.isRawText! ? "raw_text" : "file");
                    sts(() {
                      isLoading = false;
                    });
                  },
                  label: const Text("Share "),
                );
        },
      ),
    );
  }
}
