import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/services/photon_sender.dart';
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

  getSharingOptions() {
    List<Map<String, dynamic>> sharingOptions = [
      {
        "type": "Folder",
        "icon": SvgPicture.asset(
          "assets/icons/folder.svg",
          colorFilter: ColorFilter.linearToSrgbGamma(),
          height: 60,
        ),
      },
      {
        "type": "Files",
        "icon": SvgPicture.asset(
          "assets/icons/files.svg",
          colorFilter: ColorFilter.srgbToLinearGamma(),
          height: 60,
        ),
      },
      {
        "type": "Text",
        "icon": SvgPicture.asset(
          "assets/icons/texts.svg",
          colorFilter: ColorFilter.linearToSrgbGamma(),
          height: 60,
        ),
      },
    ];
    if (Platform.isAndroid) {
      sharingOptions.add({
        "type": "Apps",
        "icon": SvgPicture.asset(
          "assets/icons/apps.svg",
          colorFilter: ColorFilter.mode(Colors.white38, BlendMode.srcATop),
          height: 60,
        ),
      });
    }
    return sharingOptions;
  }

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
                        backgroundColor:
                            mode.isDark ? Colors.black : Colors.white,
                        context: context,
                        builder: (context) {
                          List<Map<String, dynamic>> sharingOptions =
                              getSharingOptions();
                          return GridView.builder(
                            itemCount: sharingOptions.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: Card(
                                  elevation: 6,
                                  // color: mode.isDark ?Color.fromARGB(205, 10,15,20):Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  child: InkWell(
                                    onTap: () async {
                                      String type = sharingOptions[i]["type"];
                                      switch (type) {
                                        case "Files":
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await PhotonSender.handleSharing();
                                          setState(() {
                                            isLoading = false;
                                          });
                                          break;
                                        case "Folder":
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await PhotonSender.handleSharing(
                                              isFolder: true);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          break;
                                        case "Apps":
                                          shareApps();
                                          break;
                                        case "Text":
                                          shareText();
                                          break;
                                      }
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        sharingOptions[i]["icon"],
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          sharingOptions[i]["type"],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: mode.isDark
                                                  ? const Color.fromARGB(
                                                      205, 117, 255, 122)
                                                  : Colors.blue),
                                        )
                                      ],
                                    ),
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
    if (mounted) {
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
  }
}
