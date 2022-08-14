import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/services/photon_receiver.dart';
import 'models/sender_model.dart';
import 'services/file_services.dart';

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
    PhotonReceiver.receive(widget.senderModel!);
  }

  final percentageController = PercentageController();
  List percentageList = [];

  @override
  Widget build(BuildContext context) {
    var getInstance = GetIt.I<PercentageController>();
    var width = MediaQuery.of(context).size.width > 720
        ? MediaQuery.of(context).size.width / 1.8
        : MediaQuery.of(context).size.width / 1.12;
    getInstance.percentage = RxList.generate(
      widget.senderModel!.filesCount!,
      (i) {
        return RxDouble(0.0);
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' Receiving',
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
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
                    double progressLineWidth = (width - 24) *
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
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
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                    '${(getInstance.percentage[item] as RxDouble)}'),
                              ),
                            ],
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
