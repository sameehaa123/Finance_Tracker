
import 'package:ai_poweredfinancetracker/core/Services/google_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/Services/sharedpref_service.dart';
import '../../bottomnav/view/bottom_nav.dart';
import '../controller/auth_controller.dart';
import 'register_screen.dart';
import '../../admin/view/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    try {
      // Create controller object
    AuthController authController = AuthController();

    // Call controller login method
    String role = await authController.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    print("ROLE FROM FIRESTORE = $role");

    await SharedprefService.saveRole(role);
    
  
     if (mounted) {

  // Check if logged in user is Admin
  if (role == "Admin") {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDashboard(),
      ),
    );

  } else {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const BottomNavScreen(),
      ),
    );

  }
}
      
    } catch (e) {
      if (!mounted) return;
      String message = e.toString();

      if(message.contains(
        "Your account has been deactivated")) {

          message = "Your account has been deactivated.\nPlease contact support.";
        } else {
          message = message.replaceFirst("Exception: ", "");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red,
          content: Text(message),
           ),
        );
    } 
    finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF00897B);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8E6CF), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Spendly",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                    ),
                    const SizedBox(height: 18),

                    // 🔽 Role dropdown REMOVED – role is now taken from Firestore

                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

Row(
  children: [
    const Expanded(
      child: Divider(
        thickness: 1,
        color: Colors.grey,
      ),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        "OR",
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    const Expanded(
      child: Divider(
        thickness: 1,
        color: Colors.grey,
      ),
    ),
  ],
),

const SizedBox(height: 20),

ElevatedButton.icon(
  onPressed: () async {
    final user = await GoogleAuthService().signInWithGoogle();
    final currentUser = FirebaseAuth.instance.currentUser;


  
if(currentUser != null) {
  if(currentUser.email != null) {
   final user = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

        
        final role = user.data()?['role'] ??"";
        await SharedprefService.saveRole(role);


        final status = user.data()?['status']?? 1;
        if (status == 0) {
          await FirebaseAuth.instance.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor:Colors.red,
            content: Text("Your account has been deativated.",
            ),
            ),
          );
        }

      return;

        }
               if (user.exists) {
          print("User already exists in Firestore");
          final role = user.data()?['role'] ?? 'Student';
          if (role != null) {
            await SharedprefService.saveRole(role);
          }
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .set({
            'email': currentUser.email,
            'name': currentUser.displayName,
            'role': "Student",
            'photo': currentUser.photoURL,
            'status': 1,
            'isPremium': false,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          print("New user added to Firestore");
          await SharedprefService.saveRole("Student");
          
        }

  
  }else{
     
    print("Current user email is null");
  }
 
}


    if (user != null) {
      print( "Google Sign-In successful for user: }");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BottomNavScreen(),
        ),
      );
    }
  },
  icon: Image.asset(
    'assets/images/google_logo.png',
    height: 22,
    width: 22,
  ),
  label: const Text("Google Sign-In For Students"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    minimumSize: const Size(double.infinity, 55),
    side: const BorderSide(color: Colors.grey),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),
const SizedBox(height: 20),



                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text("Create Account"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}
