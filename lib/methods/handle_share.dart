import 'package:flutter/material.dart';
import 'package:photon/methods/methods.dart';
import '../components/snackbar.dart';
import '../views/receive_ui/qr_scan.dart';
import 'package:open_settings_plus/open_settings_plus.dart';

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
        const OpenSettingsPlusAndroid().wifi();
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
        const OpenSettingsPlusAndroid().wifi();
      }
    });
  }
}
