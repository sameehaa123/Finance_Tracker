import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class AuthController {

Future<String> login( String email, String password) async {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
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

      return role;
      }


// user registration
      Future<void> register(String email, String password, String role) async {
  // 1. Create auth user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save extra user data (role) to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'email': cred.user!.email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
}

}

