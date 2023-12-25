import 'dart:io';
import 'dart:isolate';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photon/components/constants.dart';
import 'package:photon/components/dialogs.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/services/photon_sender.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../components/components.dart';

class SharePage extends StatefulWidget {
  final List<String>? fileList;
  final List<String>? appList;

  const SharePage({super.key, this.appList, this.fileList});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  // SenderModel senderModel = PhotonSender.getServerInfo();
  PhotonSender photonSender = PhotonSender();
  late double width;
  late double height;
  bool willPop = false;

  var receiverDataInst = GetIt.I.get<ReceiverDataController>();
  //
  ReceivePort? _receivePort;

  Future<void> _requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return;
    }

    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
      await FlutterForegroundTask.openSystemAlertWindowSettings();
    }

    // Android 12 or higher, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        id: 500,
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
        buttons: [
          const NotificationButton(
            id: 'sendButton',
            text: 'Send',
            textColor: Colors.orange,
          ),
          const NotificationButton(
            id: 'testButton',
            text: 'Test',
            textColor: Colors.grey,
          ),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> _startForegroundTask(
      List<String> appsPath, List<String> filePath) async {
    await FlutterForegroundTask.saveData(key: 'fileList', value: filePath);
    await FlutterForegroundTask.saveData(key: 'appList', value: appsPath);
    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);
    if (!isRegistered) {
      print('Failed to register receivePort!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      print("HERE {}");
      return FlutterForegroundTask.startService(
          notificationTitle: 'Photon file server is running',
          notificationText: 'Tap to return to the app',
          callback: startCallback);
    }
  }

  Future<bool> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) {
      if (data is int) {
        print('eventCount: $data');
      } else if (data is String) {
        if (data == 'onNotificationPressed') {
          Navigator.of(context).pushNamed('/resume-route');
        }
      } else if (data is DateTime) {
        print('timestamp: ${data.toString()}');
      }
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissionForAndroid();
      _initForegroundTask();
      // await PhotonSender.handleSharing(
      //     appList: widget.appList!, fileList: widget.fileList!);
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  //
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return WillPopScope(
      child: ValueListenableBuilder(
          valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
          builder: (_, AdaptiveThemeMode mode, __) {
            return Scaffold(
                backgroundColor: mode.isDark
                    ? const Color.fromARGB(255, 27, 32, 35)
                    : Colors.white,
                appBar: AppBar(
                  backgroundColor:
                      mode.isDark ? Colors.blueGrey.shade900 : null,
                  title: const Text('Share'),
                  leading: BackButton(
                      color: Colors.white,
                      onPressed: () {
                        sharePageAlertDialog(context);
                      }),
                  flexibleSpace: mode.isLight
                      ? Container(
                          decoration: appBarGradient,
                        )
                      : null,
                ),
                body: FutureBuilder(
                    future:
                        _startForegroundTask(widget.appList!, widget.fileList!),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.done) {
                        return SingleChildScrollView(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (width > 720) ...{
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                        'assets/lottie/share.json',
                                        width: 240,
                                      ),
                                      SizedBox(
                                        width: width / 8,
                                      ),
                                      SizedBox(
                                        width: width > 720 ? 200 : 100,
                                        height: width > 720 ? 200 : 100,
                                        child: QrImageView(
                                          size: 180,
                                          eyeStyle: const QrEyeStyle(
                                              color: Colors.black),
                                          data: "PhotonSender.getPhotonLink",
                                          backgroundColor: Colors.white,
                                        ),
                                      )
                                    ],
                                  )
                                } else ...{
                                  Lottie.asset('assets/lottie/share.json',
                                      width: 240),
                                  SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: QrImageView(
                                      eyeStyle:
                                          const QrEyeStyle(color: Colors.black),
                                      data: " PhotonSender.getPhotonLink",
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                },
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Text(
                                //     '${photonSender.hasMultipleFiles ? 'Your files are ready to be shared' : 'Your file is ready to be shared'}\nAsk receiver to tap on receive button',
                                //     style: TextStyle(
                                //       fontWeight: FontWeight.bold,
                                //       fontSize: width > 720 ? 18 : 14,
                                //     ),
                                //     textAlign: TextAlign.center,
                                //   ),
                                // ),
                                const SizedBox(
                                  height: 20,
                                ),

                                //receiver data
                                Obx((() => GetIt.I
                                        .get<ReceiverDataController>()
                                        .receiverMap
                                        .isEmpty
                                    ? Card(
                                        color: mode.isDark
                                            ? const Color.fromARGB(
                                                255, 29, 32, 34)
                                            : const Color.fromARGB(
                                                255, 241, 241, 241),
                                        clipBehavior: Clip.antiAlias,
                                        elevation: 8,
                                        // color: Platform.isWindows ? Colors.grey.shade300 : null,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24)),
                                        child: SizedBox(
                                          height: width > 720 ? 200 : 128,
                                          width: width > 720
                                              ? width / 2
                                              : width / 1.25,
                                          child: const Center(
                                            child: Wrap(
                                              direction: Axis.vertical,
                                              children: [],
                                              //   children: infoList(
                                              //       senderModel,
                                              //       width,
                                              //       height,
                                              //       true,
                                              //       mode.isDark ? "dark" : "bright"),
                                              // ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: width / 1.2,
                                        child: Card(
                                          color: mode.isDark
                                              ? const Color.fromARGB(
                                                  255, 45, 56, 63)
                                              : const Color.fromARGB(
                                                  255, 241, 241, 241),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: receiverDataInst
                                                .receiverMap.length,
                                            itemBuilder: (context, item) {
                                              var keys = receiverDataInst
                                                  .receiverMap.keys
                                                  .toList();

                                              var data =
                                                  receiverDataInst.receiverMap;

                                              return ListTile(
                                                title: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (item == 0) ...{
                                                        const Center(
                                                          child: Text(
                                                              "Sharing status"),
                                                        ),
                                                      },
                                                      const Divider(
                                                        thickness: 2.4,
                                                        indent: 20,
                                                        endIndent: 20,
                                                        color: Color.fromARGB(
                                                            255, 109, 228, 113),
                                                      ),
                                                      Center(
                                                        child: Text(
                                                          "Receiver name : ${data[keys[item]]['hostName']}",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      data[keys[item]][
                                                                  'isCompleted'] ==
                                                              'true'
                                                          ? const Center(
                                                              child: Text(
                                                                "All files sent",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            )
                                                          : Center(
                                                              child: Text(
                                                                  "Sending '${data[keys[item]]['currentFileName']}' (${data[keys[item]]['currentFileNumber']} out of ${data[keys[item]]['filesCount']} files)"),
                                                            )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ))),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }));
          }),
      onWillPop: () async {
        willPop = await sharePageWillPopDialog(context);
        GetIt.I.get<ReceiverDataController>().receiverMap.clear();
        return willPop;
      },
    );
  }
}

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.

  FlutterForegroundTask.setTaskHandler(ServerTaskHandler());
}

class ServerTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    final all = await FlutterForegroundTask.getAllData();
    print(all);
    List<String> fileList =
        await FlutterForegroundTask.getData(key: 'fileList');
    List<String> appList = await FlutterForegroundTask.getData(key: 'appList');

    // You can use the getData function to get the stored data.
    await PhotonSender.handleSharing(appList: appList, fileList: fileList);
  }

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // FlutterForegroundTask.updateService(
    //   notificationTitle: 'MyTaskHandler',
    //   notificationText: 'eventCount: $_eventCount',
    // );

    print('onRepeat');
    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('onDestroy');
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed >> $id');
  }

  // Called when the notification itself on the Android platform is pressed.
  //
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // this function to be called.
  @override
  void onNotificationPressed() {
    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

class ResumeRoutePage extends StatelessWidget {
  const ResumeRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Route'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            Navigator.of(context).pop();
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
