import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/services/photon_receiver.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../../components/constants.dart';
import '../../components/dashboard.dart';
import '../../components/dialogs.dart';
import '../../components/progress_line.dart';
import '../../methods/methods.dart';
import '../../models/sender_model.dart';
import '../../services/file_services.dart';

class ProgressPage extends StatefulWidget {
  final SenderModel? senderModel;
  final int secretCode;
  final String dataType;
  final String? parentDirectory;

  const ProgressPage({
    Key? key,
    required this.senderModel,
    required this.secretCode,
    required this.dataType,
    this.parentDirectory,
  }) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  StopWatchTimer stopWatchTimer = StopWatchTimer();
  bool willPop = false;
  bool isDownloaded = false;
  bool isLoading = false;
  TextEditingController fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    generatePercentageList(widget.senderModel!.filesCount);
    PhotonReceiver.receive(
      widget.senderModel!,
      widget.secretCode,
      widget.dataType,
      parentDirectory: widget.parentDirectory,
    );
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
    var rawTextController = GetIt.I<RawTextController>();
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
              title: Obx(
                () => Text(
                  widget.dataType == "raw_text"
                      ? rawTextController.rawText.value == ""
                          ? "Receiving"
                          : "Received"
                      : widget.dataType == "folder"
                          ? getInstance.isFinished.value
                              ? "Received folder"
                              : ' Receiving folder'
                          : getInstance.isFinished.value
                              ? "Received"
                              : ' Receiving',
                ),
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
            body: widget.dataType == "raw_text"
                ? Center(
                    child: Obx(
                      () {
                        return rawTextController.rawText.value == ""
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: MediaQuery.of(context).size.width / 1.2,
                                height:
                                    MediaQuery.of(context).size.height / 1.4,
                                child: Center(
                                  child: Flex(
                                    direction: width > 720
                                        ? Axis.horizontal
                                        : Axis.vertical,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          width: 480,
                                          height: 480,
                                          child: Lottie.asset(
                                            'assets/lottie/text_received.json',
                                            width: 480,
                                            height: 480,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: width > 720 ? 1 : 2,
                                        child: Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Card(
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        rawTextController
                                                            .rawText.value,
                                                        textAlign:
                                                            TextAlign.justify,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: width > 720
                                                              ? 15
                                                              : 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: mode.isDark
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 46, 46, 46)
                                                          : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: IconButton(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              61,
                                                              255,
                                                              155),
                                                      onPressed: () async {
                                                        await Clipboard.setData(
                                                          ClipboardData(
                                                              text:
                                                                  rawTextController
                                                                      .rawText
                                                                      .value),
                                                        );
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  "Copied to clipboard"),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      icon: const Icon(Icons
                                                          .copy_all_rounded),
                                                    ),
                                                  ),
                                                ),
                                                const Positioned(
                                                  top: 10,
                                                  child: Text(
                                                    "Your text is here",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              );
                      },
                    ),
                  )
                : FutureBuilder(
                    future: FileMethods.getFileNames(widget.senderModel!),
                    builder: (context, AsyncSnapshot snap) {
                      if (snap.connectionState == ConnectionState.done) {
                        return CustomScrollView(
                          slivers: <Widget>[
                            SliverToBoxAdapter(
                              child: Dashboard(
                                mode: mode,
                                getInstance: getInstance,
                                width: width,
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int item) {
                                  return Focus(
                                    child: Obx(
                                      () {
                                        double progressLineWidth =
                                            ((width - 80) *
                                                (getInstance.percentage[item]
                                                        as RxDouble)
                                                    .value /
                                                100);

                                        return UnconstrainedBox(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                "Please check history for viewing received file",
                                              )));
                                            },
                                            child: Card(
                                              // color: Colors.blue.shade100,
                                              elevation: 2,
                                              clipBehavior: Clip.antiAlias,
                                              child: SizedBox(
                                                width: width + 60,
                                                height: 120,
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
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0,
                                                                  top: 8.0),
                                                          child: SizedBox(
                                                              width:
                                                                  width / 1.4,
                                                              height: 30,
                                                              child: Text(
                                                                snap.data![
                                                                    item],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                        ),
                                                        if (getInstance
                                                                .fileStatus[
                                                                    item]
                                                                .value !=
                                                            "skipped") ...{
                                                          SizedBox(
                                                            width: width - 80,
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(0),
                                                                child:
                                                                    CustomPaint(
                                                                  painter:
                                                                      ProgressLine(
                                                                    pos:
                                                                        progressLineWidth,
                                                                  ),
                                                                  child:
                                                                      Container(),
                                                                )),
                                                          ),
                                                        },
                                                        const SizedBox(
                                                          height: 40,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 20),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            2.5),
                                                                child:
                                                                    getStatusWidget(
                                                                  getInstance
                                                                          .fileStatus[
                                                                      item],
                                                                  item,
                                                                ),
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
                                                                          left:
                                                                              10),
                                                                  child:
                                                                      SizedBox(
                                                                    width:
                                                                        width /
                                                                            1.5,
                                                                    child: Text(
                                                                      getInstance
                                                                          .estimatedTime
                                                                          .value,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize: MediaQuery.of(context).size.width >
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
                                                    if (getInstance
                                                        .isCancelled[item]
                                                        .value) ...{
                                                      IconButton(
                                                        icon: const Padding(
                                                          padding:
                                                              EdgeInsets.all(0),
                                                          child: Icon(
                                                            Icons.refresh,
                                                            semanticLabel:
                                                                'Restart',
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          //restart download
                                                          getInstance
                                                              .isCancelled[item]
                                                              .value = false;
                                                          PhotonReceiver
                                                              .getFile(
                                                            snap.data[item],
                                                            item,
                                                            widget.senderModel!,
                                                          );
                                                        },
                                                      )
                                                    } else if (!getInstance
                                                        .isReceived[item]
                                                        .value) ...{
                                                      IconButton(
                                                        icon: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.0),
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
                                                              .cancelTokenList[
                                                                  item]
                                                              .cancel();
                                                        },
                                                      )
                                                    } else ...{
                                                      Padding(
                                                          padding: EdgeInsets.only(
                                                              left: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width >
                                                                      720
                                                                  ? 18
                                                                  : 10),
                                                          child: Icon(Icons
                                                              .done_rounded))
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
                                childCount: snap.data.length,
                              ),
                            ),
                          ],
                        );
                      } else if (snap.connectionState ==
                          ConnectionState.waiting) {
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
            floatingActionButton: widget.dataType == "raw_text"
                ? FloatingActionButton.extended(
                    label: const Text('Export',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Enter file name to save"),
                            content: TextField(
                              controller: fileNameController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await FileMethods.saveTextFile(
                                      rawTextController.rawText.value,
                                      fileNameController.text);
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "File is saved as ${await FileMethods.getTextFilePath(fileNameController.text)}"),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  "Save",
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.black,
                    ),
                    backgroundColor: mode.isDark
                        ? const Color.fromARGB(230, 80, 255, 124)
                        : Colors.blue,
                  )
                : null,
          );
        },
      ),
      onWillPop: () async {
        willPop = await progressPageWillPopDialog(context);
        return willPop;
      },
    );
  }
}
