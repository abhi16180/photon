import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:photon/controllers/controllers.dart';

import '../methods/methods.dart';

class Dashboard extends StatelessWidget {
  final AdaptiveThemeMode mode;
  final double width;
  final PercentageController getInstance;
  const Dashboard(
      {super.key,
      required this.mode,
      required this.width,
      required this.getInstance});

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Card(
          elevation: mode.isDark ? 5 : 10,
          color: mode.isDark
              ? const Color.fromARGB(255, 25, 24, 24)
              : const Color.fromARGB(255, 255, 255, 255),
          child: SizedBox(
            height: 180,
            width: width + 60,
            child: Obx(() {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (getInstance.isFinished.isFalse) ...{
                      const Text(
                        "Current speed",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 102, 245, 107),
                          ),
                          children: [
                            TextSpan(
                              text: getInstance.speed.value.toStringAsFixed(2),
                            ),
                            const TextSpan(
                              text: ' mbps',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Min ${(getInstance.minSpeed.value).toStringAsFixed(2)} mbps",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Max ${(getInstance.maxSpeed.value).toStringAsFixed(2)}  mbps",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    } else ...{
                      Expanded(
                        flex: 2,
                        child: Lottie.asset('assets/lottie/fire.json'),
                      ),
                      Expanded(
                          flex: 1,
                          child: Text(
                            'Time taken, ${formatTime(getInstance.totalTimeElapsed.value)}',
                          ))
                    }
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
