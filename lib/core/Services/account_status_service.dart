import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountStatusService {

  static StreamSubscription<DocumentSnapshot>? _subscription;
 
  static void startListening({
    required String userId,
    required Function() onBlocked,
  }) {

    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
    .collection("users")
    .doc(userId)
    .snapshots()
    .listen((snapshot) {
      if (!snapshot.exists)return;
      final data = snapshot.data() as Map<String,dynamic>;
      final status = data["status"] ?? 1;
      if(status == 0) {
        onBlocked();
      }
    });

  }

  static void stopListening() {

    _subscription?.cancel();

    _subscription = null;

  }

}