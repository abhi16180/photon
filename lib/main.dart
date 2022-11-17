import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photon/methods/share_intent.dart';
import 'package:photon/views/handle_intent_ui.dart';
import 'package:photon/views/drawer/history.dart';
import 'package:photon/views/intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photon/controllers/controllers.dart';
import 'app.dart';
import 'views/receive_ui/receive_page.dart';
import 'views/share_ui/share_page.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.init((await getApplicationDocumentsDirectory()).path);
  await Hive.openBox('appData');
  GetIt getIt = GetIt.instance;
  SharedPreferences prefInst = await SharedPreferences.getInstance();
  prefInst.get('isIntroRead') ?? prefInst.setBool('isIntroRead', false);
  prefInst.get('isDarkTheme') ?? prefInst.setBool('isDarkTheme', false);
  getIt.registerSingleton<PercentageController>(PercentageController());
  bool externalIntent = false;
  if (Platform.isAndroid) {
    externalIntent = await handleSharingIntent();
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (_) {}
  }
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    AdaptiveTheme(
      light: FlexThemeData.light(
          scheme: FlexScheme.aquaBlue,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 20,
          appBarOpacity: 0.95,
          swapColors: true,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 20,
            blendOnColors: false,
            toggleButtonsRadius: 10.0,
            fabSchemeColor: SchemeColor.inversePrimary,
            chipRadius: 4.0,
            tabBarItemSchemeColor: SchemeColor.onPrimary,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          fontFamily: 'ytf'),
      dark: FlexThemeData.dark(
          scheme: FlexScheme.hippieBlue,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 15,
          appBarStyle: FlexAppBarStyle.background,
          appBarOpacity: 0.90,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 30,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          fontFamily: 'ytf'),
      initial: AdaptiveThemeMode.light,
      builder: (theme, dark) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: dark,
          routes: {
            '/': (context) => AnimatedSplashScreen(
                  splash: 'assets/images/splash.png',
                  nextScreen: prefInst.getBool('isIntroRead') == true
                      ? (externalIntent ? const HandleIntentUI() : const App())
                      : const IntroPage(),
                  splashTransition: SplashTransition.fadeTransition,
                  pageTransitionType: PageTransitionType.fade,
                  backgroundColor: const Color.fromARGB(255, 0, 4, 7),
                ),
            '/home': (context) => const App(),
            '/sharepage': (context) => const SharePage(),
            '/receivepage': (context) => const ReceivePage(),
            '/history': (context) => const HistoryPage()
          },
        );
      },
    ),
  );
}
