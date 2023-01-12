import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/components/snackbar.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/services/photon_receiver.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import '../../components/constants.dart';
import '../../components/dialogs.dart';
import '../../components/progress_line.dart';
import '../../methods/methods.dart';
import '../../models/sender_model.dart';
import '../../services/file_services.dart';

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
  StopWatchTimer stopWatchTimer = StopWatchTimer();
  bool willPop = false;
  bool isDownloaded = false;
  @override
  void initState() {
    super.initState();
    generatePercentageList(widget.senderModel!.filesCount);
    PhotonReceiver.receive(widget.senderModel!, widget.secretCode);
    stopWatchTimer.onStartTimer();
  }

  @override
  void dispose() async {
    super.dispose();
    await stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var getInstance = GetIt.I<PercentageController>();
    var width = MediaQuery.of(context).size.width > 720
        ? MediaQuery.of(context).size.width / 1.8
        : MediaQuery.of(context).size.width / 1.4;

    return WillPopScope(
      child: ValueListenableBuilder(
        valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
        builder: (_, AdaptiveThemeMode mode, __) {
          return Scaffold(
            backgroundColor: mode.isDark
                ? const Color.fromARGB(255, 13, 16, 18)
                : Colors.white,
            appBar: AppBar(
              backgroundColor: mode.isDark ? Colors.blueGrey.shade900 : null,
              title: const Text(
                ' Receiving',
              ),
              flexibleSpace: mode.isLight
                  ? Container(
                      decoration: appBarGradient,
                    )
                  : null,
              leading: BackButton(
                color: Colors.white,
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
                        Focus(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Card(
                              elevation: mode.isDark ? 5 : 10,
                              color: mode.isDark
                                  ? const Color.fromARGB(255, 25, 24, 24)
                                  : const Color.fromARGB(255, 255, 255, 255),
                              child: SizedBox(
                                height: 180,
                                width: width + 60,
                                child: Obx(() {
                                  if (getInstance.isFinished.isTrue) {
                                    getInstance.totalTimeElapsed.value =
                                        stopWatchTimer.secondTime.value;
                                    stopWatchTimer.onStopTimer();
                                  }
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (getInstance.isFinished.isFalse) ...{
                                          const Text(
                                            "Current speed",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 102, 245, 107),
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: getInstance.speed.value
                                                      .toStringAsFixed(2),
                                                ),
                                                const TextSpan(
                                                  text: ' mbps',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "Max ${(getInstance.maxSpeed.value).toStringAsFixed(2)}  mbps",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        } else ...{
                                          Expanded(
                                            flex: 2,
                                            child: Lottie.asset(
                                                'assets/lottie/fire.json'),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                'Time taken, ${formatTime(getInstance.totalTimeElapsed.value)}',
                                              ))
                                        }
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snap.data.length,
                          itemBuilder: (context, item) {
                            return Focus(
                              child: Obx(
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
                                        openFile(snap.data[item],
                                            widget.senderModel!);
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
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            top: 8.0),
                                                    child: SizedBox(
                                                      width: width / 1.4,
                                                      child: Text(
                                                        snap.data![item],
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 2.5),
                                                          child: getStatusWidget(
                                                              getInstance
                                                                      .fileStatus[
                                                                  item],
                                                              item),
                                                        ),
                                                        if (getInstance
                                                                .fileStatus[
                                                                    item]
                                                                .value ==
                                                            "downloading") ...{
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10),
                                                            child: SizedBox(
                                                              width:
                                                                  width / 1.8,
                                                              child: Text(
                                                                getInstance
                                                                    .estimatedTime
                                                                    .value,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      MediaQuery.of(context).size.width >
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
                                                    getInstance
                                                        .isCancelled[item]
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
                                                    padding:
                                                        EdgeInsets.all(0.0),
                                                    child: Icon(
                                                      Icons.cancel,
                                                      semanticLabel:
                                                          'Cancel receive',
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    getInstance
                                                        .isCancelled[item]
                                                        .value = true;
                                                    getInstance
                                                        .cancelTokenList[item]
                                                        .cancel();
                                                  },
                                                )
                                              } else ...{
                                                const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Icon(
                                                        Icons.done_rounded))
                                              },
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                                },
                              ),
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
          );
        },
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
