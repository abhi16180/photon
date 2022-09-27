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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: FutureBuilder(
          future: _future(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.done) {
              return ListView(
                children: [
                  ListTile(
                      title: Text(snap.data.toString()),
                      trailing: IconButton(
                        onPressed: () async {
                          var resp =
                              await FilePicker.platform.getDirectoryPath();
                          if (resp != null) {
                            FileMethods.editDirectoryPath(resp);
                          }
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.edit,
                        ),
                      ))
                ],
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
