import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/components/dialogs.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/services/photon_sender.dart';

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
          backgroundColor: const Color.fromARGB(255, 27, 32, 35),
          appBar: AppBar(
            backgroundColor: Colors.blueGrey.shade900,
            title: const Text('Share'),
            leading: BackButton(onPressed: () {
              sharePageAlertDialog(context);
            }),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/lottie/share.json',
                    width: width > 720 ? 200 : 128,
                  ),
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
                    elevation: 8,
                    // color: Platform.isWindows ? Colors.grey.shade300 : null,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
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
            ),
          )),
      onWillPop: () async {
        willPop = await sharePageWillPopDialog(context);
        return willPop;
      },
    );
  }
}
