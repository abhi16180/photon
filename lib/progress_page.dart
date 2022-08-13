import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/services/photon_receiver.dart';
import 'models/sender_model.dart';

class ProgressPage extends StatefulWidget {
  final SenderModel senderModel;
  const ProgressPage({
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
    PhotonReceiver.receive(widget.senderModel);
  }

  final percentageController = PercentageController();
  double percentage = 0.0;
  List percentageList = [];

  @override
  Widget build(BuildContext context) {
    var getInstance = GetIt.I<PercentageController>();
    getInstance.percentage =
        RxList.generate(widget.senderModel.filesCount!, (i) {
      return RxDouble(0.0);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Receiving'),
      ),
      body: ListView.builder(
          itemCount: widget.senderModel.filesCount,
          itemBuilder: (context, item) {
            percentageList.add(0.0);
            return Obx(
              () {
                percentageList[item] =
                    (getInstance.percentage[item] as RxDouble).value;

                // return LinearProgressIndicator(
                //   value: (getInstance.percentage[item] as RxDouble).value,
                //   color: Colors.cyan,
                // );
                print((getInstance.percentage[item] as RxDouble).value);
                return UnconstrainedBox(
                  child: AnimatedContainer(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(microseconds: 100),
                      height: 10,
                      width: (getInstance.percentage[item] as RxDouble).value),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(onPressed: () {
        percentageList[0]++;
      }),
    );
  }
}

class ProgressLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    var paint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 5;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
