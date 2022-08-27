import 'package:flutter/material.dart';
import 'package:photon/components/snackbar.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/share_history_model.dart';
import 'package:url_launcher/url_launcher.dart' as ulaunch;

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        flexibleSpace: Container(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  clearHistory();
                });
                showSnackBar(context, 'History cleared');
              },
              icon: const Icon(Icons.delete_rounded),
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: getHistory(),
        builder: (context, AsyncSnapshot snap) {
          if (snap.connectionState == ConnectionState.done) {
            late List<ShareHistory> data;

            snap.data == null
                ? data = []
                : data = HistoryList.formData(snap.data).historyList;

            return snap.data == null
                ? const Center(
                    child: Text('File sharing history will appear here'),
                  )
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, item) {
                      return ListTile(
                        leading:
                            getFileIcon(data[item].fileName.split('.').last),
                        onTap: () async {
                          try {
                            await ulaunch
                                .launchUrl(Uri.parse(data[item].filePath));
                          } catch (_) {
                            showSnackBar(context, 'Unable to open the file');
                          }
                        },
                        title: Text(
                          data[item].fileName,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(data[item].date.toString()),
                      );
                    });
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
