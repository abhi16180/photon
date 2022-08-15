import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/components/components.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/views/progress_page.dart';
import '../services/photon_receiver.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  Future<List<SenderModel>> _scan() async {
    try {
      List<SenderModel> resp = await PhotonReceiver.scan();
      return resp;
    } catch (_) {}
    return [];
  }

  GetIt getIt = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
      ),
      body: FutureBuilder(
        future: _scan(),
        builder: (context, AsyncSnapshot snap) {
          if (snap.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: snap.data.length == 0
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (snap.data.length == 0) ...{
                  Center(
                    child: Text(
                      'No device found\nMake sure sender & receiver are connected through mobile hotspot\nOR\nSender and Receivers are connected to same wifi\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            MediaQuery.of(context).size.width > 720 ? 20 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.refresh_rounded,
                          size: 80,
                        )),
                  ),
                  Center(
                    child: Text(
                      'Re-Scan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            MediaQuery.of(context).size.width > 720 ? 20 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
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
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Receive'),
                                    content: const Text(
                                        'Do you want to receive files from this sender?'),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Go back')),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return ProgressPage(
                                                    senderModel:
                                                        snap.data[index]
                                                            as SenderModel);
                                              },
                                            ),
                                          );
                                        },
                                        child: const Text('Yes'),
                                      )
                                    ],
                                  );
                                });
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            elevation: 5,
                            // color: Platform.isWindows
                            //     ? Colors.grey.shade300
                            //     : null,
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
                        height: 100,
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     setState(() {});
      //   },
      //   child: const Text('Retry'),
      // ),
    );
  }
}
