import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";
import 'package:photon/services/file_services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _future() async {
    return await FileMethods.getSaveDirectory();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: FutureBuilder(
          future: _future(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.done) {
              return Center(
                child: Container(
                  color: Colors.grey.shade900,
                  width: w > 720 ? w / 1.4 : w,
                  child: Center(
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text("Save path"),
                          subtitle: Text(snap.data.toString()),
                          trailing: IconButton(
                            onPressed: () async {
                              var resp =
                                  await FilePicker.platform.getDirectoryPath();
                              setState(() {
                                if (resp != null) {
                                  FileMethods.editDirectoryPath(resp);
                                }
                              });
                            },
                            icon: Icon(
                              Icons.edit_rounded,
                              size: w > 720 ? 38 : 24,
                              semanticLabel: 'Edit path',
                            ),
                          ),
                        ),
                        // ListTile(
                        //   title: const Text("Change font"),
                        //   subtitle: const Text(
                        //     "Current font: ytfoowhy",
                        //   ),
                        //   trailing: IconButton(
                        //     onPressed: () {},
                        //     icon: Icon(
                        //       Icons.edit,
                        //       size: w > 720 ? 38 : 24,
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
