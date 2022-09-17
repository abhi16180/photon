import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/components/snackbar.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/services/photon_receiver.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/dialogs.dart';
import '../methods/methods.dart';
import '../models/sender_model.dart';
import '../services/file_services.dart';
import 'package:open_file/open_file.dart';

class ProgressPage extends StatefulWidget {
  final SenderModel? senderModel;
  final int secretCode;
  const ProgressPage({
    Key? key,
    required this.senderModel,
    required this.secretCode,
  }) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    generatePercentageList(widget.senderModel!.filesCount);
    PhotonReceiver.receive(widget.senderModel!, widget.secretCode);
  }

  bool willPop = false;
  bool isDownloaded = false;
  @override
  Widget build(BuildContext context) {
    var getInstance = GetIt.I<PercentageController>();
    var width = MediaQuery.of(context).size.width > 720
        ? MediaQuery.of(context).size.width / 1.8
        : MediaQuery.of(context).size.width / 1.4;

    return WillPopScope(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 13, 16, 18),
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade900,
          title: const Text(
            ' Receiving',
          ),
          leading: BackButton(
            onPressed: () {
              progressPageAlertDialog(context);
            },
          ),
        ),
        body: FutureBuilder(
          future: FileMethods.getFileNames(widget.senderModel!),
          builder: (context, AsyncSnapshot snap) {
            if (snap.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Card(
                        elevation: 5,
                        color: const Color.fromARGB(255, 25, 24, 24),
                        child: SizedBox(
                          height: 180,
                          width: width + 60,
                          child: Obx(
                            () => Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Current speed",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 102, 245, 107)),
                                    children: [
                                      TextSpan(
                                        text: getInstance.speed.value
                                            .toStringAsFixed(2),
                                      ),
                                      const TextSpan(
                                        text: ' mbps',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Min ${(getInstance.minSpeed.value).toStringAsFixed(2)} mbps",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Max ${(getInstance.maxSpeed.value).toStringAsFixed(2)}  mbps",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                              ],
                            )),
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snap.data.length,
                      itemBuilder: (context, item) {
                        return Obx(
                          () {
                            double progressLineWidth = ((width - 80) *
                                (getInstance.percentage[item] as RxDouble)
                                    .value /
                                100);

                            return UnconstrainedBox(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  openFile(
                                      snap.data[item], widget.senderModel!);
                                },
                                child: Card(
                                  // color: Colors.blue.shade100,
                                  elevation: 2,
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedBox(
                                    width: width + 60,
                                    height: 100,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        getFileIcon(snap.data[item]
                                            .toString()
                                            .split('.')
                                            .last),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0, top: 8.0),
                                              child: SizedBox(
                                                width: width / 1.4,
                                                child: Text(
                                                  snap.data![item],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: width - 80,
                                              child: CustomPaint(
                                                painter: ProgressLine(
                                                  pos: progressLineWidth,
                                                ),
                                                child: Container(),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 40,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 2.5),
                                                    child: getStatusWidget(
                                                        getInstance
                                                            .fileStatus[item],
                                                        item),
                                                  ),
                                                  if (getInstance
                                                          .fileStatus[item]
                                                          .value ==
                                                      "downloading") ...{
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: SizedBox(
                                                        width: width / 1.8,
                                                        child: Text(
                                                          getInstance
                                                              .estimatedTime
                                                              .value,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width >
                                                                    720
                                                                ? 16
                                                                : 12.5,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  }
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        if (getInstance
                                            .isCancelled[item].value) ...{
                                          IconButton(
                                            icon: const Padding(
                                              padding: EdgeInsets.all(0),
                                              child: Icon(
                                                Icons.refresh,
                                                semanticLabel: 'Restart',
                                              ),
                                            ),
                                            onPressed: () {
                                              //restart download
                                              getInstance.isCancelled[item]
                                                  .value = false;
                                              PhotonReceiver.getFile(
                                                snap.data[item],
                                                item,
                                                widget.senderModel!,
                                              );
                                            },
                                          )
                                        } else if (!getInstance
                                            .isReceived[item].value) ...{
                                          IconButton(
                                            icon: const Padding(
                                              padding: EdgeInsets.all(0.0),
                                              child: Icon(
                                                Icons.cancel,
                                                semanticLabel: 'Cancel receive',
                                              ),
                                            ),
                                            onPressed: () {
                                              getInstance.isCancelled[item]
                                                  .value = true;
                                              getInstance.cancelTokenList[item]
                                                  .cancel();
                                            },
                                          )
                                        } else ...{
                                          const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Icon(Icons.done_rounded))
                                        },
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ));
                          },
                        );
                      },
                    )
                  ],
                ),
              );
            } else if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: Card(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: const Text('Something went wrong'),
                  ),
                ),
              );
            }
          },
        ),
      ),
      onWillPop: () async {
        willPop = await progressPageWillPopDialog(context);
        return willPop;
      },
    );
  }

  openFile(String filepath, SenderModel senderModel) async {
    String path = (await FileMethods.getSavePath(filepath, senderModel))
        .replaceAll(r'\', '/');
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        OpenFile.open(path);
      } catch (_) {
        // ignore: use_build_context_synchronously
        showSnackBar(context, 'No corresponding app found');
      }
    } else {
      try {
        launchUrl(
          Uri.parse(
            path,
          ),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to open the file')));
      }
    }
  }

  getStatusWidget(RxString status, idx) {
    switch (status.value) {
      case "waiting":
        return const Text("Waiting");
      case "downloading":
        return Text(
            '${GetIt.I.get<PercentageController>().percentage[idx].value}');
      case "cancelled":
        return const Text("Cancelled");
      case "error":
        return const Text("Error");
      case "downloaded":
        return const Text("Completed");
    }
  }
}

class ProgressLine extends CustomPainter {
  final double pos;
  ProgressLine({required this.pos});

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    var paint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 10
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color.fromARGB(255, 24, 228, 218),
          Color.fromARGB(255, 15, 147, 255),
        ],
      ).createShader(rect)
      ..strokeCap = StrokeCap.round;

    // double i = -0.0;
    // to animate
    // while (i != pos) {
    //   i = i + 1;
    //   canvas.drawLine(const Offset(0, 0), Offset(i, 0), paint);
    // }
    canvas.drawLine(const Offset(10, 24), Offset(pos + 10, 24), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
