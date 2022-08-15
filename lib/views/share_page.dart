import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/services/photon_sender.dart';

import '../app.dart';
import '../components/components.dart';

class SharePage extends StatefulWidget {
  const SharePage({Key? key}) : super(key: key);

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  SenderModel senderModel = PhotonSender.getServerInfo();
  PhotonSender photonSender = PhotonSender();
  late double width;
  late double height;
  bool willPop = false;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return WillPopScope(
      child: Scaffold(
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
                      ElevatedButton(
                        onPressed: () async {
                          await PhotonSender.closeServer();
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
                },
              );
            }),
          ),
          body: Center(
            child: Column(
              children: [
                Lottie.asset('assets/lottie/share.json'),
                Text(
                  '${photonSender.hasMultipleFiles ? 'Your files are ready to be shared' : 'Your file is ready to be shared'}\nAsk receiver to tap on receive button',
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
                  elevation: 5,
                  // color: Platform.isWindows ? Colors.grey.shade300 : null,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: SizedBox(
                    height: width > 720 ? 200 : 128,
                    width: width > 720 ? width / 2 : width / 1.25,
                    child: Center(
                      child: Wrap(
                        direction: Axis.vertical,
                        children: infoList(senderModel, width, height, true),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
      onWillPop: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Server alert'),
              content: const Text(
                  'Would you like to terminate the current session ?'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      willPop = false;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Stay')),
                ElevatedButton(
                  onPressed: () async {
                    await PhotonSender.closeServer();
                    willPop = true;
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // Navigator.of(context).pushAndRemoveUntil(
                    //     MaterialPageRoute(builder: (context) => const App()),
                    //     (route) => false);
                  },
                  child: const Text('Terminate'),
                )
              ],
            );
          },
        );

        return willPop;
      },
    );
  }
}
