import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
 final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  

Future<UserCredential?> signInWithGoogle() async {
  try {
     googleSignIn.initialize(
      serverClientId:
          "83453219439-i9p56iro8t54hse8u0fmejff6q977r47.apps.googleusercontent.com"
    );
    print("Starting Google Sign-In...");

    final GoogleSignInAccount? googleUser =
        await googleSignIn.authenticate();

    print("Google User: $googleUser");

    if (googleUser == null) {
      print("User cancelled sign in");
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    print("Got authentication");

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return await firebaseAuth.signInWithCredential(credential);
  } catch (e) {
    print("Google Sign-In Error: $e");
    return null;
  }
}

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }
}

     
