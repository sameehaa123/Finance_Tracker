// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'student_dashboard.dart';
// import 'professional_dashboard.dart';
// import 'senior_dashboard.dart';
// import 'register_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   String _selectedRole = 'Student';
//   final List<String> _roles = ['Student', 'Professional', 'Senior Citizen'];
//   bool _isLoading = false;
//
//   Future<void> _login() async {
//     FocusScope.of(context).unfocus();
//     if (_selectedRole.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a role")),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', true);
//
//       // Navigate based on role
//       Widget nextScreen;
//       if (_selectedRole == 'Student') {
//         nextScreen = const StudentDashboard();
//       } else if (_selectedRole == 'Professional') {
//         nextScreen = const ProfessionalDashboard();
//       } else {
//         nextScreen = const SeniorDashboard();
//       }
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => nextScreen),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Login failed: $e")));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final accent = const Color(0xFF00897B);
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFA8E6CF), Colors.white],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Card(
//               elevation: 8,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       "Spendly",
//                       style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: accent),
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: _emailController,
//                       decoration: const InputDecoration(labelText: "Email"),
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: _passwordController,
//                       decoration: const InputDecoration(labelText: "Password"),
//                       obscureText: true,
//                     ),
//                     const SizedBox(height: 10),
// // Role dropdown
//                     DropdownButtonFormField<String>(
//                       value: _selectedRole,
//                       hint: const Text("Select your role"), // default text shown before selection
//                       items: _roles.map((role) {
//                         return DropdownMenuItem(
//                           value: role,
//                           child: Text(role),
//                         );
//                       }).toList(),
//                       onChanged: (val) {
//                         setState(() {
//                           _selectedRole = val!;
//                         });
//                       },
//                       decoration: const InputDecoration(
//                         labelText: "Role",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     _isLoading
//                         ? const CircularProgressIndicator()
//                         : SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _login,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: accent,
//                           foregroundColor: Colors.white, // ensures text is white in both modes
//                           padding: const EdgeInsets.symmetric(vertical: 14.0),
//                         ),
//                         child: const Text(
//                           "Login",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white, // explicitly set text color
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextButton(
//                       onPressed: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => RegisterScreen()),
//                       ),
//                       child: const Text("Create Account"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ⬅️ add this
import 'student_dashboard.dart';
import 'professional_dashboard.dart';
import 'senior_dashboard.dart';
import 'register_screen.dart';

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
      // 1. Sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is null after login");
      }

      // 2. Get user role from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw Exception("User data not found in Firestore");
      }

      final data = doc.data() as Map<String, dynamic>;
      final role = (data['role'] ?? 'Student') as String;

      // 3. Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // 4. Navigate based on role
      Widget nextScreen;
      if (role == 'Student') {
        nextScreen = const StudentDashboard();
      } else if (role == 'Professional') {
        nextScreen = const ProfessionalDashboard();
      } else {
        nextScreen = const SeniorDashboard();
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Login failed: $e")));
      }
    } finally {
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
