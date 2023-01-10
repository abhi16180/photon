import 'package:flutter/material.dart';
import 'package:photon/methods/methods.dart';
import 'package:system_settings/system_settings.dart';
import '../components/snackbar.dart';
import '../views/receive_ui/qr_scan.dart';

class HandleShare {
  BuildContext context;
  HandleShare({required this.context});
  onNormalScanTap() async {
    getIP().then((value) async {
      if (value.isNotEmpty) {
        Navigator.of(context).pushNamed('/receivepage');
      } else {
        Navigator.of(context).pop();
        showSnackBar(
            context, 'Please connect to wifi / hotspot same as that of sender');
        await Future.delayed(
          const Duration(seconds: 2),
        );
        SystemSettings.wifi();
      }
    });
  }

  onQrScanTap() {
    getIP().then((value) async {
      if (value.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const QrReceivePage(),
          ),
        );
      } else {
        Navigator.of(context).pop();
        showSnackBar(
            context, 'Please connect to wifi / hotspot same as that of sender');
        await Future.delayed(
          const Duration(seconds: 2),
        );
        SystemSettings.wifi();
      }
    });
  }
}
