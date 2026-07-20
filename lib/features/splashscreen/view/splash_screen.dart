import 'package:ai_poweredfinancetracker/features/admin/view/admin_dashboard.dart';
import 'package:ai_poweredfinancetracker/features/auth/view/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/Services/sharedpref_service.dart';
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


  initData();
     super.initState();

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
  
    await FirebaseAuth.instance.authStateChanges().first;
    final firebaseUser = FirebaseAuth.instance.currentUser;


    // Not logged in
    // if (!savedLogin || firebaseUser == null) {
    //   return const LoginScreen();
    // }

  

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser?.uid)
          .get();

      if (!doc.exists) {
        return const LoginScreen();
      }

      final data = doc.data() as Map<String, dynamic>;
      final role = (data['role'] ?? 'Student') as String;
    

    await SharedprefService.saveRole(role);

      // You can use the role later if needed
      debugPrint("User role: $role");

    if (role == "Admin") {
      return const AdminDashboard();
    } else {
      return const BottomNavScreen();
    }

  } catch (e) {
    return const LoginScreen();  
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
  colors: [
    Color(0xFFA8E6CF),
    Colors.white,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),
    ),
    
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: _animate ? 1 : 0.4,
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: _animate ? 1 : 0,
                duration: const Duration(milliseconds: 900),

          
                   child: Image.asset(
                      'assets/images/Spendly.png',
                      width: 220,
                      height: 220,
                    ),
                ),
              )
          ],
            ),
        ),
      ),
    );
  }
}