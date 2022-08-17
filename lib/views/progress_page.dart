import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
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
        backgroundColor: const Color.fromARGB(255, 27, 32, 35),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 19, 18, 21),
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
              return ListView.builder(
                itemCount: snap.data.length,
                itemBuilder: (context, item) {
                  return Obx(
                    () {
                      double progressLineWidth = ((width - 80) *
                          (getInstance.percentage[item] as RxDouble).value /
                          100);

                      return UnconstrainedBox(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () async {
                            openFile(snap.data[item], widget.senderModel!);
                          },
                          child: Card(
                            // color: Colors.blue.shade100,
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(
                              width: width + 60,
                              height: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  getFileIcon(snap.data[item]
                                      .toString()
                                      .split('.')
                                      .last),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, top: 8.0),
                                        child: Text(
                                          snap.data![item],
                                          overflow: TextOverflow.ellipsis,
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
                                        padding: const EdgeInsets.all(0.0),
                                        child: Text(getInstance
                                                .isCancelled[item].value
                                            ? 'Cancelled'
                                            : '${(getInstance.percentage[item] as RxDouble)} %'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  if (getInstance.isCancelled[item].value) ...{
                                    IconButton(
                                      icon: const Padding(
                                        padding: EdgeInsets.all(0),
                                        child: Icon(Icons.refresh),
                                      ),
                                      onPressed: () {
                                        //restart download
                                        getInstance.isCancelled[item].value =
                                            false;
                                        PhotonReceiver.getFile(
                                          snap.data[item],
                                          item,
                                          widget.senderModel!,
                                        );
                                      },
                                    )
                                  } else ...{
                                    IconButton(
                                      icon: const Padding(
                                        padding: EdgeInsets.all(0.0),
                                        child: Icon(Icons.cancel),
                                      ),
                                      onPressed: () {
                                        getInstance.isCancelled[item].value =
                                            true;
                                        getInstance.cancelTokenList[item]
                                            .cancel();
                                      },
                                    )
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
    try {
      String path = (await FileMethods.getSavePath(filepath, senderModel))
          .replaceAll(r'\', '/');
      if (Platform.isAndroid || Platform.isIOS) {
        OpenFile.open(path);
      } else {
        print(path);
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
    } catch (_) {
      print('Error');
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
    //to animate
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
