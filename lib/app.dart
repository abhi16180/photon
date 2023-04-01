import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:photon/views/drawer/about_page.dart';
import 'package:photon/views/drawer/settings.dart';
import 'package:photon/views/home/widescreen_home.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/constants.dart';
import 'controllers/intents.dart';
import 'views/drawer/history.dart';
import 'views/home/mobile_home.dart';
import 'package:dpad_container/dpad_container.dart';

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

  Box box = Hive.box('appData');
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return ValueListenableBuilder(
      valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
      builder: (_, AdaptiveThemeMode mode, child) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: mode.isDark
              ? const Color.fromARGB(255, 27, 32, 35)
              : Colors.white,
          appBar: AppBar(
            backgroundColor: mode.isDark ? Colors.blueGrey.shade900 : null,
            title: const Text(
              'Photon',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            leading: DpadContainer(
                onClick: () {
                  if (scaffoldKey.currentState!.isDrawerOpen) {
                    scaffoldKey.currentState!.openEndDrawer();
                  }
                },
                child: Icon(Icons.menu),
                onFocus: (_) {}),
            flexibleSpace: mode.isLight
                ? Container(
                    decoration: appBarGradient,
                  )
                : null,
          ),
          drawer: DpadContainer(
            onClick: () {
              if (scaffoldKey.currentState!.isDrawerOpen) {
                scaffoldKey.currentState!.openEndDrawer();
              }
            },
            onFocus: (_) {},
            child: Drawer(
              child: Stack(
                children: [
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          children: [
                            Image.asset(
                              box.get('avatarPath'),
                              width: 90,
                              height: 90,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                box.get('username'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Divider(
                          thickness: 2,
                        ),
                      ),
                      DpadContainer(
                        onClick: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return const HistoryPage();
                              },
                            ),
                          );
                        },
                        onFocus: (_) {},
                        child: ListTile(
                          leading: Icon(
                            UniconsSolid.history,
                            color: mode.isDark ? null : Colors.black,
                          ),
                          title: const Text('History'),
                          onTap: () {},
                        ),
                      ),
                      DpadContainer(
                        onClick: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const SettingsPage();
                          }));
                        },
                        onFocus: (_) {},
                        child: ListTile(
                          leading: Icon(
                            Icons.settings,
                            color: mode.isDark ? null : Colors.black,
                          ),
                          title: const Text("Settings"),
                          onTap: () {},
                        ),
                      ),
                      DpadContainer(
                        onClick: () {
                          showLicensePage(
                              context: context,
                              applicationLegalese: 'GPL3 license',
                              applicationVersion: "1.2.0",
                              applicationIcon: Image.asset(
                                'assets/images/splash.png',
                                width: 60,
                              ));
                        },
                        onFocus: (_) {},
                        child: ListTile(
                          leading: SvgPicture.asset(
                            'assets/icons/licenses.svg',
                            color: mode.isLight ? Colors.black : Colors.white,
                          ),
                          onTap: () {},
                          title: const Text('Licenses'),
                        ),
                      ),
                      DpadContainer(
                        onClick: () {
                          launchUrl(
                              Uri.parse(
                                  "https://photondev.netlify.app/privacy-policy-page"),
                              mode: LaunchMode.externalApplication);
                        },
                        onFocus: (_) {},
                        child: ListTile(
                          leading: Icon(
                            Icons.privacy_tip_rounded,
                            color: mode.isDark ? null : Colors.black,
                          ),
                          onTap: () async {},
                          title: const Text('Privacy policy'),
                        ),
                      ),
                      DpadContainer(
                        onClick: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return const AboutPage();
                              },
                            ),
                          );
                        },
                        onFocus: (_) {},
                        child: ListTile(
                          title: const Text('About'),
                          leading: Icon(UniconsLine.info_circle,
                              color: mode.isDark ? null : Colors.black),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 18,
                    right: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/icon.png',
                              width: 30, height: 30),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Photon v 1.2.0',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          body: Center(
            child:
                size.width > 720 ? const WidescreenHome() : const MobileHome(),
          ),
          floatingActionButton: DpadContainer(
            onClick: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Help"),
                      content: const Text(
                        """1. Before sharing files make sure that you are connected to wifi or your mobile-hotspot is turned on.\n\n2. While receiving make sure you are connected to the same wifi or hotspot as that of sender.""",
                        textAlign: TextAlign.justify,
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    );
                  });
            },
            onFocus: (_) {},
            child: FloatingActionButton.extended(
              backgroundColor:
                  mode.isDark ? Colors.blueGrey.shade900 : Colors.white,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Help"),
                        content: const Text(
                          """1. Before sharing files make sure that you are connected to wifi or your mobile-hotspot is turned on.\n\n2. While receiving make sure you are connected to the same wifi or hotspot as that of sender.""",
                          textAlign: TextAlign.justify,
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.close,
                            ),
                          ),
                        ],
                      );
                    });
              },
              icon: const Text("Help"),
              label: const Icon(Icons.help),
            ),
          ),
        );
      },
    );
  }
}
