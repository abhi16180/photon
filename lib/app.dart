import 'package:flutter/material.dart';
import 'package:photon/components/dialogs.dart';
import 'package:photon/views/widescreen_home.dart';

import 'views/mobile_home.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  TextEditingController usernameController = TextEditingController();

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
                  privacyDialog(context);
                },
                title: const Text('Privacy policy'),
              ),
            ],
          ),
        ),
        body: Center(
          child: size.width > 720 ? const WidescreenHome() : const MobileHome(),
        ));
  }
}
