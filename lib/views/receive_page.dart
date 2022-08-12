import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/components/components.dart';
import 'package:photon/models/sender_model.dart';

import '../services/photon_receiver.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  _scan() async {
    try {
      List<SenderModel> resp = await PhotonReceiver.scan();
      return resp;
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive'),
      ),
      body: FutureBuilder(
        future: _scan(),
        builder: (context, AsyncSnapshot snap) {
          if (snap.connectionState == ConnectionState.done) {
            List<SenderModel> data = snap.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (snap.data.length == 0) ...{
                  const Text('No device found')
                } else ...{
                  const Center(
                    child: Text(
                        "Please select the 'sender' from the following list"),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: snap.data.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {},
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            elevation: 5,
                            color: Platform.isWindows
                                ? Colors.grey.shade300
                                : null,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: SizedBox(
                              height: width > 720 ? 200 : 128,
                              width: width > 720 ? width / 2 : width / 1.25,
                              child: Center(
                                child: Wrap(
                                  direction: Axis.vertical,
                                  children: infoList(
                                      snap.data[index], width, height, false),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                }
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (width < 720) ...{
                      const SizedBox(
                        height: 50,
                      ),
                    },
                    const Text(
                      'Scanning ...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Center(
                      child: Lottie.asset('assets/lottie/wifi_scan.json',
                          width: width < 720 ? 400 : width / 2.4,
                          height: width < 720 ? 400 : width / 2.4),
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {});
        },
        child: const Text('Retry'),
      ),
    );
  }
}
