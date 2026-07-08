import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/view/login_screen.dart';

Future<void> appLogout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await FirebaseAuth.instance.signOut();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
  );
}
