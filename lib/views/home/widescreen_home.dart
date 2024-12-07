import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/methods/handle_share.dart';
import '../../services/photon_sender.dart';
import '../apps_list.dart';

class WidescreenHome extends StatefulWidget {
  const WidescreenHome({Key? key}) : super(key: key);

  @override
  State<WidescreenHome> createState() => _WidescreenHomeState();
}

class _WidescreenHomeState extends State<WidescreenHome> {
  bool isLoading = false;
  Box box = Hive.box('appData');
  TextEditingController rawTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
        builder: (_, AdaptiveThemeMode mode, __) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isLoading) ...{
                  Card(
                    color: mode.isDark
                        ? const Color.fromARGB(255, 18, 23, 26)
                        : const Color.fromARGB(255, 241, 241, 241),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: InkWell(
                      onTap: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  minWidth:
                                      MediaQuery.of(context).size.width / 4,
                                  color: mode.isDark
                                      ? const Color.fromARGB(205, 117, 255, 122)
                                      : Colors.blue,
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    await PhotonSender.handleSharing(
                                        isFolder: true);

                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.file_open,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Folder',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  minWidth:
                                      MediaQuery.of(context).size.width / 4,
                                  color: mode.isDark
                                      ? const Color.fromARGB(205, 117, 255, 122)
                                      : Colors.blue,
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    await PhotonSender.handleSharing();

                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.file_open,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Files',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                if (Platform.isAndroid || Platform.isIOS) ...{
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    minWidth:
                                        MediaQuery.of(context).size.width / 4,
                                    color: mode.isDark
                                        ? const Color.fromARGB(
                                            205, 117, 255, 122)
                                        : Colors.blue,
                                    onPressed: () async {
                                      if (box.get('queryPackages')) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AppsList()));
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Query installed packages'),
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
                                                    box.put(
                                                        'queryPackages', true);

                                                    Navigator.of(context)
                                                        .popAndPushNamed(
                                                            '/apps');
                                                  },
                                                  child: const Text('Continue'),
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/android.svg',
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Text(
                                          'Apps',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                },
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  minWidth:
                                      MediaQuery.of(context).size.width / 4,
                                  color: mode.isDark
                                      ? const Color.fromARGB(205, 117, 255, 122)
                                      : Colors.blue,
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text("Share text"),
                                              IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                          // icon: const Icon(Icons.text_fields),
                                          content: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            child: TextField(
                                              decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none),
                                              controller: rawTextController,
                                              maxLines: 8,
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                rawTextController.text =
                                                    (await Clipboard.getData(
                                                            'text/plain'))!
                                                        .text
                                                        .toString();
                                                setState(() {});
                                              },
                                              child: const Text(
                                                  "Paste from clipboard"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                PhotonSender.setRawText(
                                                    rawTextController.text);
                                                await PhotonSender
                                                    .handleSharing(
                                                        isRawText: true);
                                              },
                                              child: const Text("Send"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.text_snippet,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Text',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            'assets/lottie/rocket-send.json',
                            width: size.width / 4,
                            height: size.height / 4,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Share',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width / 10,
                  ),
                  Card(
                    color: mode.isDark
                        ? const Color.fromARGB(255, 18, 23, 26)
                        : const Color.fromARGB(255, 241, 241, 241),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    child: InkWell(
                      onTap: () {
                        if (Platform.isAndroid || Platform.isIOS) {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      height: 20,
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset('assets/lottie/receive-file.json',
                              width: size.width / 4, height: size.height / 4),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Receive',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
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
                      child: Lottie.asset('assets/lottie/setting_up.json',
                          width: 40, height: 40),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Please wait, file(s) are being fetched',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                }
              ],
            ),
          );
        });
  }
}
