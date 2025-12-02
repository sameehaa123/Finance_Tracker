// import 'package:ai_poweredfinancetracker/Screens/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:ai_poweredfinancetracker/Screens/login_screen.dart';
// import 'Screens/student_dashboard.dart';
// import 'services/theme_service.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await ThemeService.init();
//   runApp(const SpendlyApp());
// }
//
// class SpendlyApp extends StatelessWidget {
//   const SpendlyApp({super.key});
//
//
//
//   Future<bool> _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedLogin = prefs.getBool('isLoggedIn') ?? false;
//     final firebaseUser = FirebaseAuth.instance.currentUser;
//     return savedLogin && firebaseUser != null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final lightTheme = ThemeData(
//       brightness: Brightness.light,
//       primaryColor: const Color(0xFF00897B),
//       fontFamily: 'Poppins',
//       colorScheme: ColorScheme.fromSwatch().copyWith(
//         primary: const Color(0xFF00897B),
//         secondary: const Color(0xFFA8E6CF),
//       ),
//       scaffoldBackgroundColor: Colors.transparent,
//       appBarTheme: const AppBarTheme(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Color(0xFF00695C),
//         titleTextStyle: TextStyle(
//           color: Color(0xFF00695C),
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//         centerTitle: true,
//       ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: Color(0xFF00897B),
//       ),
//     );
//
//     final darkTheme = ThemeData(
//       brightness: Brightness.dark,
//       fontFamily: 'Poppins',
//       colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
//         primary: const Color(0xFF2BBBAD),
//         secondary: const Color(0xFF6CC5A1),
//       ),
//       scaffoldBackgroundColor: const Color(0xFF0B1220),
//       appBarTheme: const AppBarTheme(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.white,
//         titleTextStyle: TextStyle(
//           color: Colors.white,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//         centerTitle: true,
//       ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: Color(0xFF2BBBAD),
//       ),
//     );
//
//     return ValueListenableBuilder<bool>(
//       valueListenable: ThemeService.isDark,
//       builder: (context, isDark, _) {
//         return MaterialApp(
//           title: 'Spendly',
//           debugShowCheckedModeBanner: false,
//           theme: lightTheme,
//           darkTheme: darkTheme,
//           themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
//           home: FutureBuilder<bool>(
//             future: _checkLoginStatus(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Scaffold(
//                   body: Center(child: CircularProgressIndicator()),
//                 );
//               }
//               final isLoggedIn = snapshot.data!;
//               return Container(
//                 decoration: BoxDecoration(
//                   gradient: isDark
//                       ? const LinearGradient(
//                     colors: [Color(0xFF081427), Color(0xFF17233A)],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   )
//                       : const LinearGradient(
//                     colors: [Color(0xFFA8E6CF), Colors.white],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: isLoggedIn ? const Dashboard() : const LoginScreen(),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:ai_poweredfinancetracker/Screens/student_dashboard.dart';
import 'package:ai_poweredfinancetracker/Screens/professional_dashboard.dart';
import 'package:ai_poweredfinancetracker/Screens/senior_dashboard.dart';
import 'package:ai_poweredfinancetracker/Screens/login_screen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ThemeService.init();
  runApp(const SpendlyApp());
}

class SpendlyApp extends StatelessWidget {
  const SpendlyApp({super.key});

  /// Decide which screen to show at startup:
  /// - not logged in  -> LoginScreen
  /// - logged in      -> Dashboard based on Firestore "role"
  Future<Widget> _getStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogin = prefs.getBool('isLoggedIn') ?? false;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // Not logged in at all
    if (!savedLogin || firebaseUser == null) {
      return const LoginScreen();
    }

    try {
      // Fetch user data from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) {
        // Fallback: no user doc -> force login again
        return const LoginScreen();
      }

      final data = doc.data() as Map<String, dynamic>;
      final role = (data['role'] ?? 'Student') as String;

      if (role == 'Professional') {
        return const ProfessionalDashboard();
      } else if (role == 'Senior Citizen') {
        return const SeniorDashboard();
      } else {
        // default / Student
        return const StudentDashboard();
      }
    } catch (e) {
      // If anything fails, go to login
      return const LoginScreen();
    }
  }

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
          home: FutureBuilder<Widget>(
            future: _getStartScreen(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final startScreen = snapshot.data!;

              return Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                    colors: [Color(0xFF081427), Color(0xFF17233A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                      : const LinearGradient(
                    colors: [Color(0xFFA8E6CF), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: startScreen,
              );
            },
          ),
        );
      },
    );
  }
}
