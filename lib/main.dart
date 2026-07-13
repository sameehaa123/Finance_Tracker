import 'package:ai_poweredfinancetracker/core/Services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/Services/gemini_config.dart';

import 'core/theme/theme_service.dart';
import 'features/splashscreen/view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await ThemeService.init();

  await GeminiConfig.load();

  runApp(const SpendlyApp());
}


class SpendlyApp extends StatelessWidget {
  const SpendlyApp({super.key});


  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF00897B),
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: const Color(0xFF00897B),
        secondary: const Color(0xFFA8E6CF),
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF00695C),
        titleTextStyle: TextStyle(
          color: Color(0xFF00695C),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00897B),
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
        primary: const Color(0xFF2BBBAD),
        secondary: const Color(0xFF6CC5A1),
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF2BBBAD),
      ),
    );

    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDark,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Spendly',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
          navigatorKey: NavigationService.navigatorKey,

        );
      },
    );
  }
}
