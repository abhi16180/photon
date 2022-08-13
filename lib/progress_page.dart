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
        title: const Text(
          ' Receiving',
        ),
        leading: BackButton(onPressed: () {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        }),
      ),
      body: ListView.builder(
          itemCount: widget.senderModel.filesCount,
          itemBuilder: (context, item) {
            percentageList.add(0.0);
            return Obx(
              () {
                percentageList[item] =
                    (getInstance.percentage[item] as RxDouble).value;
                return UnconstrainedBox(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomPaint(
                          painter: ProgressLine(
                              pos: (getInstance.percentage[item] as RxDouble)
                                      .value *
                                  (MediaQuery.of(context).size.width / 100)),
                          child: Container(),
                        ),
                        Text('${(getInstance.percentage[item] as RxDouble)}'),
                      ],
                    ),
                  ),
                ));
              },
            );
          }),
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
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.blue[900]!,
          Colors.blue[500]!,
        ],
      ).createShader(rect)
      ..strokeCap = StrokeCap.round;

    double i = -0.0;
    //to animate
    while (i != pos * 10) {
      i = i + 1;
      canvas.drawLine(const Offset(0, 0), Offset(i, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
