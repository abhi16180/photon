import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart' as ulaunch;
import 'views/mobile_home.dart';
import 'views/widescreen_home.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(207, 10, 9, 17),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 11, 33),
        title: const Text(
          'Photon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/icon.png',
                    width: 75,
                    height: 75,
                  ),
                  const Text('Photon')
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              onTap: () {
                showLicensePage(
                    context: context,
                    applicationLegalese: 'MIT license',
                    applicationVersion: 'v1.0.0',
                    applicationIcon: Image.asset(
                      'assets/images/splash.png',
                      width: 60,
                    ));
              },
              title: const Text('Licenses'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_rounded),
              onTap: () {
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
              },
              title: const Text('Privacy policy'),
            ),
          ],
        ),
      ),
      body: Center(
        child: size.width > 720 ? const WidescreenHome() : const MobileHome(),
      ),
    );
  }
}
