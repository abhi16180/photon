import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/services/photon_receiver.dart';
import '../models/sender_model.dart';
import '../services/file_services.dart';

class ProgressPage extends StatefulWidget {
  SenderModel? senderModel;
  ProgressPage({
    Key? key,
    required this.senderModel,
  }) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    generateEmptyList();
    PhotonReceiver.receive(widget.senderModel!);
  }

  final percentageController = PercentageController();
  bool willPop = false;
  List percentageList = [];
  generateEmptyList() {
    var getInstance = GetIt.I<PercentageController>();
    getInstance.percentage = RxList.generate(
      widget.senderModel!.filesCount!,
      (i) {
        return RxDouble(0.0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var getInstance = GetIt.I<PercentageController>();
    var width = MediaQuery.of(context).size.width > 720
        ? MediaQuery.of(context).size.width / 1.8
        : MediaQuery.of(context).size.width / 1.12;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            ' Receiving',
          ),
          leading: BackButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Alert'),
                    content:
                        const Text('Make sure that download is completed !'),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Stay')),
                      ElevatedButton(
                        onPressed: () async {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/', (Route<dynamic> route) => false);
                        },
                        child: const Text('Terminate'),
                      )
                    ],
                  );
                },
              );
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
                  percentageList.add(0.0);
                  return Obx(
                    () {
                      double progressLineWidth = (width - 80) *
                          (getInstance.percentage[item] as RxDouble).value /
                          100;

                      return UnconstrainedBox(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          // color: Colors.blue.shade100,
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                              width: width,
                              height: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  getIcon(snap.data[item]
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
                                      CustomPaint(
                                        painter: ProgressLine(
                                          pos: progressLineWidth,
                                        ),
                                        child: Container(),
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                            '${(getInstance.percentage[item] as RxDouble)} %'),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
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
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Alert'),
              content: const Text('Make sure that download is completed !'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      willPop = false;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Stay')),
                ElevatedButton(
                  onPressed: () async {
                    willPop = true;
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: const Text('Go back'),
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

Widget getIcon(String extn) {
  switch (extn) {
    case 'pdf':
      return SvgPicture.asset(
        'assets/icons/pdffile.svg',
        width: 30,
        height: 30,
      );
    case 'html':
      return const Icon(
        Icons.html,
        size: 30,
      );
    case 'mp3':
      return const Icon(
        Icons.audio_file,
        size: 30,
      );
    case 'jpeg':
      return const Icon(
        Icons.image,
        size: 30,
      );
    case 'mp4':
      return const Icon(
        Icons.video_collection_rounded,
        size: 30,
      );
    default:
      return const Icon(
        Icons.file_present,
        size: 30,
      );
  }
}
