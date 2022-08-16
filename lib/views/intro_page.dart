import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: IntroductionScreen(
        globalBackgroundColor: Colors.black,
        pages: getPages(),
        onDone: () async {
          SharedPreferences prefInst = await SharedPreferences.getInstance();
          prefInst.setBool('isIntroRead', true);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacementNamed('/home');
        },
        onSkip: () async {
          SharedPreferences prefInst = await SharedPreferences.getInstance();
          prefInst.setBool('isIntroRead', true);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacementNamed('/home');
        },
        showSkipButton: true,
        skipOrBackFlex: 0,
        nextFlex: 0,
        showBackButton: false,
        skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(16),
        controlsPadding: kIsWeb
            ? const EdgeInsets.all(12.0)
            : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        dotsContainerDecorator: const ShapeDecoration(
          color: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      )),
    );
  }

  List<PageViewModel> getPages() {
    List<PageViewModel> pages = [
      PageViewModel(
        titleWidget: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Image.asset(
            'assets/images/icon.png',
            width: 128,
            height: 128,
          ),
        ),
        bodyWidget: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 72.0),
            child: Card(
              child: Container(
                height: 200,
                margin: const EdgeInsets.only(top: 60),
                width: MediaQuery.of(context).size.width / 1.2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_rounded, size: 60),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Welcome to Photon ,\n Transfer files seamlessly across your devices.\n(No internet connection is required)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 720
                                  ? 18
                                  : 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      PageViewModel(
        titleWidget: Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Lottie.asset('assets/lottie/cross-platform.json',
                width: 200, height: 200)),
        bodyWidget: Center(
          child: Card(
            child: Container(
              height: 200,
              margin: const EdgeInsets.only(top: 60),
              width: MediaQuery.of(context).size.width / 1.2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Photon is open source cross-platform application.\nSupports High-speed cross-platform data transfer \n',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 720 ? 18 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      PageViewModel(
        titleWidget: Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Lottie.asset('assets/lottie/wifi_intro.json',
                width: 200, height: 200)),
        bodyWidget: Center(
          child: Card(
            child: Container(
              height: 200,
              margin: const EdgeInsets.only(top: 60),
              width: MediaQuery.of(context).size.width / 1.2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Before using make sure that,\nSender and receivers are connected to same wifi router \n OR \n Connected via mobile-hotspot\n',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 720 ? 18 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ];
    return pages;
  }
}
