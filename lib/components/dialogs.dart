import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as ulaunch;

import '../app.dart';
import '../services/photon_sender.dart';

void privacyDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Privacy policy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                """This app doesn't collect any sort of data and doesn't track / log user activity. All libraries used in this application are open-source. Please refer to license section  for more info. Source code of this application is available on github.
                              Since no data is collected from app's side,data handling and data-security purely depends upon the user. Make sure that you are connected to trusted wifi or hotspot while sharing the files.(Developer is not responsible).
                              """,
                textAlign: TextAlign.justify,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
                onPressed: () async {
                  await ulaunch.launchUrl(Uri.parse(
                      'https://github.com/abhi16180/photon-file-transfer'));
                },
                child: const Text('Source-code')),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Okay'))
          ],
        );
      });
}

progressPageAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Alert'),
        content: const Text('Make sure that transfer is completed !'),
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
                  '/home', (Route<dynamic> route) => false);
            },
            child: const Text('Go back'),
          )
        ],
      );
    },
  );
}

progressPageWillPopDialog(context) async {
  bool willPop = false;
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
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home', (Route<dynamic> route) => false);
            },
            child: const Text('Go back'),
          )
        ],
      );
    },
  );
  return willPop;
}

sharePageAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Server alert'),
        content: const Text('Would you like to terminate the current session'),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Stay')),
          ElevatedButton(
            onPressed: () async {
              await PhotonSender.closeServer(context);
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const App()),
                  (route) => false);
            },
            child: const Text('Terminate'),
          )
        ],
      );
    },
  );
}

sharePageWillPopDialog(context) async {
  bool willPop = false;
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Server alert'),
        content:
            const Text('Would you like to terminate the current session ?'),
        actions: [
          ElevatedButton(
              onPressed: () {
                willPop = false;
                Navigator.of(context).pop();
              },
              child: const Text('Stay')),
          ElevatedButton(
            onPressed: () async {
              await PhotonSender.closeServer(context);
              willPop = true;
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              // Navigator.of(context).pushAndRemoveUntil(
              //     MaterialPageRoute(builder: (context) => const App()),
              //     (route) => false);
            },
            child: const Text('Terminate'),
          )
        ],
      );
    },
  );
  return willPop;
}

senderRequestDialog(BuildContext context, String username, String os) async {
  bool allowRequest = false;
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request from receiver'),
          content: Text(
              "$username ($os) is requesting for files. Would you like to share with them ?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                allowRequest = false;
                Navigator.of(context).pop();
              },
              child: const Text('Deny'),
            ),
            ElevatedButton(
              onPressed: () {
                allowRequest = true;
                Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            )
          ],
        );
      });

  return allowRequest;
}
