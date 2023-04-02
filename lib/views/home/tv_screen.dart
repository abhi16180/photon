import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/methods/handle_share.dart';
import '../../services/photon_sender.dart';
import 'package:dpad_container/dpad_container.dart';

class TvScreenHome extends StatefulWidget {
  const TvScreenHome({Key? key}) : super(key: key);

  @override
  State<TvScreenHome> createState() => _TvScreenHomeState();
}

class _TvScreenHomeState extends State<TvScreenHome> {
  bool isLoading = false;
  Box box = Hive.box('appData');
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
        builder: (_, AdaptiveThemeMode mode, __) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isLoading) ...{
                  DpadContainer(
                      onClick: () async {
                        {
                          setState(() {
                            isLoading = true;
                          });
                          await PhotonSender.handleSharing();
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: Card(
                        color: mode.isDark
                            ? const Color.fromARGB(255, 18, 23, 26)
                            : const Color.fromARGB(255, 241, 241, 241),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: InkWell(
                          onTap: () async {},
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset(
                                'assets/lottie/rocket-send.json',
                                width: size.width / 4,
                                height: size.height / 4,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Share',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      onFocus: (_) {}),
                  SizedBox(
                    width: size.width / 10,
                  ),
                  DpadContainer(
                      onClick: () {
                        HandleShare(context: context).onNormalScanTap();
                      },
                      child: Card(
                        color: mode.isDark
                            ? const Color.fromARGB(255, 18, 23, 26)
                            : const Color.fromARGB(255, 241, 241, 241),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        child: InkWell(
                          onTap: () {},
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset('assets/lottie/receive-file.json',
                                  width: size.width / 4,
                                  height: size.height / 4),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Receive',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      onFocus: (_) {})
                } else ...{
                  Center(
                    child: SizedBox(
                      width: size.width / 4,
                      height: size.height / 4,
                      child: Lottie.asset('assets/lottie/setting_up.json',
                          width: 40, height: 40),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Please wait, file(s) are being fetched',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                }
              ],
            ),
          );
        });
  }
}
