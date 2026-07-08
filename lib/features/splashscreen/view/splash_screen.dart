import 'package:ai_poweredfinancetracker/features/auth/view/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bottomnav/view/bottom_nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animate = false;

  @override
  void initState() {
   
    // Start animation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _animate = true;
        });
      }
    });


 
     super.initState();
 initData();
  }

  Future<void> initData() async {
    
    final startScreen = await _getStartScreen();

    // Keep splash visible
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => startScreen,
      ),
    );
  }

  /// Decide which screen to show
  Future<Widget> _getStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogin = prefs.getBool('isLoggedIn') ?? false;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // Not logged in
    if (!savedLogin || firebaseUser == null) {
      return const LoginScreen();
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) {
        return const LoginScreen();
      }

      final data = doc.data() as Map<String, dynamic>;
      final role = (data['role'] ?? 'Student') as String;

      // You can use the role later if needed
      debugPrint("User role: $role");

      return const BottomNavScreen();
    } catch (e) {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: AnimatedScale(
          scale: _animate ? 1 : 0.4,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: _animate ? 1 : 0,
            duration: const Duration(milliseconds: 900),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 120,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Spendly",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}