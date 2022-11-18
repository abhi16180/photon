import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photon/methods/methods.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HandleIntentUI extends StatefulWidget {
  const HandleIntentUI({super.key});

  @override
  State<HandleIntentUI> createState() => _HandleIntentUIState();
}

class _HandleIntentUIState extends State<HandleIntentUI> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Share files"),
      ),
      body: FutureBuilder(
        future: ReceiveSharingIntent.getInitialMedia(),
        builder: (context, AsyncSnapshot snap) {
          isLoading = false;
          if (snap.connectionState == ConnectionState.done) {
            List data = snap.data.map((e) => e.path).toList();

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
                    await handleSharing(context, externalIntent: true);
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
