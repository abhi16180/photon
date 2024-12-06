import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/views/receive_ui/progress_page.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../components/constants.dart';
import '../../services/photon_receiver.dart';

class QrReceivePage extends StatefulWidget {
  const QrReceivePage({
    super.key,
  });

  @override
  State<QrReceivePage> createState() => _QrReceivePageState();
}

class _QrReceivePageState extends State<QrReceivePage> {
  _scan(BuildContext context) async {
    if (context.mounted) {
      await Permission.camera.request();
      late String? resp;
      if (context.mounted) {
        resp = await SimpleBarcodeScanner.scanBarcode(context);
      }
      return resp;
    } else {
      throw Exception("Not mounted");
    }
  }
  bool isDenied = false;
  bool hasErr = false;
  late StateSetter innerState;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
      builder: (_, AdaptiveThemeMode mode, __) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: mode.isDark ? Colors.blueGrey.shade900 : null,
              title: const Text(" QR - receive"),
              leading: BackButton(
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              flexibleSpace: mode.isLight
                  ? Container(
                      decoration: appBarGradient,
                    )
                  : null,
            ),
            body: FutureBuilder(
              future: _scan(context),
              builder: (context, AsyncSnapshot snap) {
                if (snap.connectionState == ConnectionState.done) {
                  handleQrReceive(snap.data);
                  return StatefulBuilder(
                    builder: (BuildContext context, sts) {
                      innerState = sts;
                      return hasErr
                          ? const Center(
                              child: Text(
                                'Wrong QR code or \n Devices are not connected to same network',
                                textAlign: TextAlign.justify,
                              ),
                            )
                          : isDenied
                              ? const Center(
                                  child: Text('Sender denied,please retry'),
                                )
                              : const Center(
                                  child: Text("Waiting for sender to approve"),
                                );
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: mode.isDark ? Colors.blueGrey.shade900 : null,
              onPressed: () async {
                setState(() {
                  hasErr = isDenied = false;
                });
              },
              label: const Text('Retry'),
              icon: const Icon(
                Icons.refresh,
                color: Color.fromARGB(255, 75, 231, 81),
              ),
            ));
      },
    );
  }

  handleQrReceive(link) async {
    try {
      String host = Uri.parse(link).host;
      int port = Uri.parse(link).port;
      SenderModel senderModel =
          await PhotonReceiver.isPhotonServer(host, port.toString());

      var resp = await PhotonReceiver.isRequestAccepted(
        senderModel,
      );
      if (resp['accepted']) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ProgressPage(
                  senderModel: senderModel,
                  secretCode: resp['code'],
                  dataType: resp['type'],
                );
              },
            ),
          );
        }
      } else {
        // ignore: use_build_context_synchronously
        innerState(() {
          isDenied = true;
        });
      }
    } catch (_) {
      innerState(() {
        hasErr = true;
      });
    }
  }
}
