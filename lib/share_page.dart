import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/models/Server_model.dart';
import 'package:photon/services/photon_server/photon_server.dart';
import 'package:unicons/unicons.dart';

import 'app.dart';

class SharePage extends StatefulWidget {
  const SharePage({Key? key}) : super(key: key);

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  ServerModel serverModel = PhotonServer.getServerInfo();
  PhotonServer photonServer = PhotonServer();
  late double width;
  late double height;
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Share'),
          leading: BackButton(onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Server alert'),
                    content: const Text(
                        'Would you like to terminate the current session'),
                    actions: [
                      ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Stay')),

                      ///[it wont rebuild alert dialog ,try different approach]

                      isloading
                          ? Lottie.asset('assets/lottie/load_exit.json',
                              width: 25, height: 25)
                          : ElevatedButton(
                              onPressed: () async {
                                await PhotonServer.closeServer();
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => const App()),
                                    (route) => false);
                              },
                              child: const Text('Terminate'),
                            )
                    ],
                  );
                });
          }),
        ),
        body: Center(
          child: Column(
            children: [
              Lottie.asset('assets/lottie/share.json'),
              Text(
                '${photonServer.hasMultipleFiles ? 'Your files are ready to be shared' : 'Your file is ready to be shared'}\nAsk receiver to tap on receive button',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width > 720 ? 18 : 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  height: width > 720 ? 200 : 120,
                  width: width > 720 ? width / 2 : width / 1.4,
                  color: Colors.yellow,
                  child: Center(
                    child: Wrap(
                      direction: Axis.vertical,
                      children: infoList(serverModel),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  infoList(ServerModel serverModel) {
    var iconList = [
      const Icon(
        UniconsLine.location_point,
      ),
      const Icon(
        UniconsLine.process,
      ),
      if (Platform.isAndroid) ...{
        Icon(
          Icons.android,
          color: Colors.greenAccent.shade400,
        )
      } else if (Platform.isIOS) ...{
        Icon(
          Icons.apple,
          color: Colors.blueGrey.shade300,
        )
      } else if (Platform.isWindows) ...{
        Icon(
          Icons.laptop_windows,
          color: Colors.blue.shade400,
        )
      } else if (Platform.isMacOS) ...{
        Icon(
          Icons.laptop_mac,
          color: Colors.blueGrey.shade300,
        )
      } else if (Platform.isLinux) ...{
        Icon(
          UniconsLine.linux,
          color: Colors.blueGrey.shade300,
        )
      },
      const Icon(
        UniconsLine.info_circle,
      )
    ];
    var serverDataList = [
      {'type': 'IP'.padRight(12), 'value': serverModel.ip},
      {'type': 'Port'.padRight(10), 'value': serverModel.port},
      {'type': 'Os'.padRight(11), 'value': serverModel.os},
      {'type': 'Version', 'value': serverModel.version}
    ];
    List<Widget> data = [];
    for (int i = 0; i < iconList.length; i++) {
      data.add(Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconList[i],
            const SizedBox(
              width: 20,
            ),
            RichText(
                text: TextSpan(
              text: serverDataList[i]['type'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis),
              children: [
                TextSpan(
                    text: serverDataList[i]['value'].toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic)),
              ],
            ))
          ],
        ),
      ));
    }
    data.insert(
      0,
      Text(
        'Receiver can discover you as,',
        style: TextStyle(fontSize: width > 720 ? 20 : 16),
        textAlign: TextAlign.center,
      ),
    );
    return data;
  }
}
