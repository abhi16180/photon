import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photon/components/dialogs.dart';
import 'package:photon/views/about_page.dart';
import 'package:photon/views/widescreen_home.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controllers/intents.dart';
import 'views/history.dart';
import 'views/mobile_home.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  TextEditingController usernameController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 27, 32, 35),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: const Text(
          'Photon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      drawer: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.backspace): GoBackIntent()
        },
        child: Actions(
          actions: {
            GoBackIntent: CallbackAction<GoBackIntent>(onInvoke: (intent) {
              if (scaffoldKey.currentState!.isDrawerOpen) {
                scaffoldKey.currentState!.openEndDrawer();
              }
              return null;
            })
          },
          child: Drawer(
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
                  leading: const Icon(UniconsSolid.history),
                  title: const Text('Received-history'),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const HistoryPage();
                    }));
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    'assets/icons/licenses.svg',
                    color: Colors.white,
                  ),
                  onTap: () {
                    showLicensePage(
                        context: context,
                        applicationLegalese: 'GPL3 license',
                        applicationVersion: "1.1.0",
                        applicationIcon: Image.asset(
                          'assets/images/splash.png',
                          width: 60,
                        ));
                  },
                  title: const Text('Licenses'),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_rounded),
                  onTap: () async {
                    // String privacyPolicy = await rootBundle
                    //     .loadString('assets/texts/privacy_policy.txt');
                    // ignore: use_build_context_synchronously
                    // privacyPolicyDialog(context, privacyPolicy);
                    launchUrl(
                        Uri.parse(
                            "https://photondev.netlify.app/privacy-policy-page"),
                        mode: LaunchMode.externalApplication);
                  },
                  title: const Text('Privacy policy'),
                ),
                ListTile(
                  title: const Text('About'),
                  leading: const Icon(UniconsLine.info_circle),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const AboutPage();
                    }));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: size.width > 720 ? const WidescreenHome() : const MobileHome(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Help"),
                  content: const Text(
                    """1. Before sharing files make sure that you are connected to wifi or your mobile-hotspot is turned on.\n\n
                    2. While receiving make sure you are connected to the same wifi or hotspot as that of sender.
                    """,
                    textAlign: TextAlign.justify,
                  ),
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close)),
                  ],
                );
              });
        },
        icon: const Text("Help"),
        label: const Icon(Icons.help),
      ),
    );
  }
}
