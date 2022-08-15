import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/controllers/controllers.dart';

import 'app.dart';
import 'views/receive_page.dart';
import 'views/share_page.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() {
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<PercentageController>(PercentageController());
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: FlexThemeData.light(
          scheme: FlexScheme.bahamaBlue,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 20,
          appBarOpacity: 0.95,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 20,
            blendOnColors: false,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          fontFamily: 'ytf'
          // To use the playground font, add GoogleFonts package and uncomment
          // fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
      darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.bahamaBlue,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 15,
          appBarStyle: FlexAppBarStyle.background,
          appBarOpacity: 0.90,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 30,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          fontFamily: 'ytf'
          // To use the playground font, add GoogleFonts package and uncomment
          // fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
      themeMode: ThemeMode.dark,

      initialRoute: '/',
      routes: {
        '/': (context) => const App(),
        '/sharepage': (context) => const SharePage(),
        '/receivepage': (context) => const ReceivePage()
      },
    ),
  );
}
