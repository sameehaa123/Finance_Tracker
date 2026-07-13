import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a payment document before opening Razorpay
  Future<String> createPendingPayment({
    required String planName,
    required int amount,
  }) async {
    final user = _auth.currentUser!;

    final docRef = await _firestore.collection('payments').add({
      'userId': user.uid,
      'email': user.email,
      'planName': planName,
      'amount': amount,
      'status': 'Pending',

      // Will be updated after payment
      'paymentId': '',
      'orderId': '',
      'signature': '',

      // Error fields
      'errorCode': '',
      'errorMessage': '',

      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Called when payment succeeds
  Future<void> markPaymentSuccess({
    required String paymentDocId,
    required String paymentId,
    required String orderId,
    required String signature,
    required String planName,
  }) async {
    final user = _auth.currentUser!;

    // Update payment document
    await _firestore.collection('payments').doc(paymentDocId).update({
      'status': 'Success',
      'paymentId': paymentId,
      'orderId': orderId,
      'signature': signature,
      'completedAt': FieldValue.serverTimestamp(),
    });

    // Upgrade the user
    await _firestore.collection('users').doc(user.uid).update({
      'isPremium': true,
      'currentPlan': planName,
    });
  }

  /// Called when payment fails
  Future<void> markPaymentFailed({
    required String paymentDocId,
    required String errorCode,
    required String errorMessage,
  }) async {
    await _firestore.collection('payments').doc(paymentDocId).update({
      'status': 'Failed',
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}