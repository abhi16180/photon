import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";
import 'package:photon/services/file_services.dart';
import 'package:photon/theme_config/theme_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences pref;
  _future() async {
    pref = await SharedPreferences.getInstance();
    return await FileMethods.getSaveDirectory();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return ValueListenableBuilder(
        valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
        builder: (_, AdaptiveThemeMode mode, __) {
          return Scaffold(
              backgroundColor:
                  mode.isDark ? const Color.fromARGB(255, 27, 32, 35) : null,
              appBar: AppBar(
                backgroundColor: mode.isDark ? Colors.blueGrey.shade900 : null,
                title: const Text("Settings"),
              ),
              body: FutureBuilder(
                future: _future(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.done) {
                    return Center(
                      child: Container(
                        color: w > 720
                            ? mode.isDark
                                ? Colors.grey.shade900
                                : null
                            : null,
                        width: w > 720 ? w / 1.4 : w,
                        child: Center(
                          child: ListView(
                            children: [
                              ListTile(
                                title: const Text("Save path"),
                                subtitle: Text(snap.data.toString()),
                                trailing: IconButton(
                                  onPressed: () async {
                                    var resp = await FilePicker.platform
                                        .getDirectoryPath();
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
                              ListTile(
                                title: const Text('Switch theme'),
                                trailing: Switch(
                                  value: pref.getBool('isDarkTheme')!,
                                  onChanged: (val) {
                                    setState(() {
                                      if (pref.getBool('isDarkTheme') == true) {
                                        AdaptiveTheme.of(context).setDark();
                                      } else {
                                        AdaptiveTheme.of(context).setLight();
                                      }
                                      pref.setBool('isDarkTheme', val);
                                    });
                                  },
                                ),
                              ),
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
        });
  }
}
