import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photon/services/photon_sender.dart';
import 'package:photon/views/apps_list.dart';
import '../../methods/handle_share.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({Key? key}) : super(key: key);

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  PhotonSender photonSePhotonSender = PhotonSender();
  bool isLoading = false;
  Directory? selectedDirectory;
  Box box = Hive.box('appData');
  TextEditingController rawTextController = TextEditingController();
  List<Map<String, dynamic>> sharingOptions = [
    {
      "type": "Folder",
      "icon": const Icon(
        Icons.folder,
        color: Color.fromARGB(205, 117, 255, 122),
        size: 50,
      ),
    },
    {
      "type": "Files",
      "icon": const Icon(
        Icons.file_copy,
        color: Color.fromARGB(205, 117, 255, 122),
        size: 50,
      ),
    },
    {
      "type": "Text",
      "icon": const Icon(
        Icons.text_snippet,
        color: const Color.fromARGB(205, 117, 255, 122),
        size: 50,
      ),
    },
    {
      "type": "Apps",
      "icon": const Icon(
        Icons.apps,
        color: Color.fromARGB(205, 117, 255, 122),
        size: 50,
      ),
    }
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
        builder: (_, AdaptiveThemeMode mode, __) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isLoading) ...{
                Card(
                  color: mode.isDark
                      ? const Color.fromARGB(255, 18, 23, 26)
                      : const Color.fromARGB(255, 241, 241, 241),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: InkWell(
                    onTap: () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return GridView.builder(
                            itemCount: sharingOptions.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: EdgeInsets.all(10),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  color: Colors.black54,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          String type =
                                              sharingOptions[i]["type"];
                                          switch (type) {
                                            case "Files":
                                              setState(() {
                                                isLoading = true;
                                              });
                                              PhotonSender.handleSharing();
                                              setState(() {
                                                isLoading = false;
                                              });
                                              break;
                                            case "Folder":
                                              shareFolder();
                                              break;
                                            case "Apps":
                                              shareApps();
                                              break;
                                            case "Text":
                                              shareText();
                                              break;
                                          }
                                        },
                                        icon: sharingOptions[i]["icon"],
                                      ),
                                      Text(sharingOptions[i]["type"])
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Column(
                      children: [
                        Lottie.asset(
                          'assets/lottie/rocket-send.json',
                          width: size.width / 1.6,
                          height: size.height / 6,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Share',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Card(
                  color: mode.isDark
                      ? const Color.fromARGB(255, 18, 23, 26)
                      : const Color.fromARGB(255, 241, 241, 241),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: InkWell(
                    onTap: () {
                      if (Platform.isAndroid || Platform.isIOS) {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      HandleShare(context: context)
                                          .onNormalScanTap();
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    minWidth:
                                        MediaQuery.of(context).size.width / 2,
                                    color: mode.isDark
                                        ? const Color.fromARGB(
                                            205, 117, 255, 122)
                                        : Colors.blue,
                                    child: const Text(
                                      'Normal mode',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  MaterialButton(
                                    onPressed: () {
                                      HandleShare(context: context)
                                          .onQrScanTap();
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    minWidth:
                                        MediaQuery.of(context).size.width / 2,
                                    color: mode.isDark
                                        ? const Color.fromARGB(
                                            205, 117, 255, 122)
                                        : Colors.blue,
                                    child: const Text(
                                      'QR code mode',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 50,
                                  ),
                                ],
                              );
                            });
                      } else {
                        Navigator.of(context).pushNamed('/receivepage');
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Lottie.asset(
                          'assets/lottie/receive-file.json',
                          width: size.width / 1.6,
                          height: size.height / 6,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Receive',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              } else ...{
                Center(
                  child: SizedBox(
                    width: size.width / 4,
                    height: size.height / 4,
                    child: Lottie.asset(
                      'assets/lottie/setting_up.json',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Please wait, file(s) are being fetched',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              },
            ],
          );
        });
  }

  shareText() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Share text"),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          // icon: const Icon(Icons.text_fields),
          content: SizedBox(
            width: MediaQuery.of(context).size.width / 1.2,
            child: TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none),
              controller: rawTextController,
              maxLines: 4,
            ),
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  rawTextController.text =
                      (await Clipboard.getData('text/plain'))!.text.toString();
                  setState(() {});
                },
                child: const Text(
                  "Paste from clipboard",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  PhotonSender.setRawText(rawTextController.text);
                  await PhotonSender.handleSharing(isRawText: true);
                },
                child: const Text(
                  "Send",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  shareApps() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Query installed packages'),
          content: const Text(
              'To get installed apps, you need to allow photon to query all installed packages. Would you like to continue ?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Go back'),
            ),
            ElevatedButton(
              onPressed: () {
                box.put('queryPackages', true);

                Navigator.of(context).popAndPushNamed('/apps');
              },
              child: const Text('Continue'),
            )
          ],
        );
      },
    );
  }

  shareFolder() async {
    if (Platform.isAndroid) {
      var extStorage = box.get("manage_ext_storage");
      if (extStorage != null) {
        if (extStorage == true) {
          PhotonSender.handleSharing(isFolder: true);
          return;
        }
      }

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("ManageExternalStorage"),
            content: const Text(
                """To list all real file paths, Photon needs ManageExternalStorage permission. If you don't want to give permission, please go back and pick files instead.
                                                    """),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  return;
                },
                child: Text("Go back"),
              ),
              MaterialButton(
                onPressed: () {
                  box.put("manage_ext_storage", true);
                  PhotonSender.handleSharing(isFolder: true);
                },
                child: Text("Proceed"),
              )
            ],
          );
        },
      );
    } else {
      PhotonSender.handleSharing(isFolder: true);
    }
  }
}
