import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/components/components.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/services/file_services.dart';
import 'package:photon/views/progress_page.dart';
import '../controllers/intents.dart';
import '../services/photon_receiver.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  late Directory dir;

  Future<List<SenderModel>> _scan() async {
    dir = await FileMethods.getSaveDirectory();
    try {
      List<SenderModel> resp = await PhotonReceiver.scan();
      return resp;
    } catch (_) {}
    return [];
  }

  GetIt getIt = GetIt.instance;
  //to keep copy of stateful builder context
  //otherwise it will throw error
  late StateSetter sts;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isRequestSent = false;

    return Shortcuts(
      shortcuts: {LogicalKeySet(LogicalKeyboardKey.backspace): GoBackIntent()},
      child: Actions(
        actions: {
          GoBackIntent: CallbackAction<GoBackIntent>(onInvoke: (intent) {
            Navigator.of(context).pop();
            return null;
          })
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 13, 16, 18),
          appBar: AppBar(
            backgroundColor: Colors.blueGrey.shade900,
            title: const Text('Scan'),
          ),
          body: FutureBuilder(
            future: _scan(),
            builder: (context, AsyncSnapshot snap) {
              if (snap.connectionState == ConnectionState.done) {
                return StatefulBuilder(builder: (context, StateSetter c) {
                  sts = c;
                  return Center(
                    child: Column(
                      mainAxisAlignment: snap.data.length == 0
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (snap.data.length == 0) ...{
                          Center(
                            child: Focus(
                              child: Text(
                                'No device found\nMake sure sender & receiver are connected through mobile hotspot\nOR\nSender and Receivers are connected to same wifi\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width > 720
                                          ? 20
                                          : 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {});
                                },
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  semanticLabel: 'Re-scan',
                                  size: 80,
                                )),
                          ),
                          Center(
                            child: Text(
                              'Re-Scan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width > 720
                                        ? 20
                                        : 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        } else if (isRequestSent) ...{
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 2 - 80,
                          ),
                          Center(
                            child: Focus(
                              child: Text(
                                'Waiting for sender to approve,ask sender to approve !',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width > 720
                                          ? 18
                                          : 16,
                                ),
                              ),
                            ),
                          ),
                          Card(
                            child: SizedBox(
                                child: Text(
                              '(Files will be saved at $dir)',
                              textAlign: TextAlign.center,
                            )),
                          )
                        } else ...{
                          const SizedBox(
                            height: 28,
                          ),
                          const Center(
                            child: Focus(
                              child: Text(
                                  "Please select the 'sender' from the following list"),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: snap.data.length,
                            itemBuilder: (c, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () async {
                                      //only rebuild the column
                                      sts(() {
                                        isRequestSent = true;
                                      });

                                      var resp = await PhotonReceiver
                                          .isRequestAccepted(
                                        snap.data[index] as SenderModel,
                                      );

                                      if (resp['accepted']) {
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return ProgressPage(
                                                senderModel: snap.data[index]
                                                    as SenderModel,
                                                secretCode: resp['code'],
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        sts(() {
                                          isRequestSent = false;
                                        });
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Access denied by the sender')));
                                      }
                                    },
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      elevation: 5,
                                      // color: Platform.isWindows
                                      //     ? Colors.grey.shade300
                                      //     : null,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: SizedBox(
                                        height: width > 720 ? 200 : 128,
                                        width: width > 720
                                            ? width / 2
                                            : width / 1.25,
                                        child: Center(
                                          child: Wrap(
                                            direction: Axis.vertical,
                                            children: infoList(snap.data[index],
                                                width, height, false),
                                          ),
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
                    ),
                  );
                });
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
        ),
      ),
    );
  }
}
