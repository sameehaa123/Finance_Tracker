import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseController {
  Future<void> saveExpense({
    required String title,
    required String amount,
    required String date,
    required String? category,
    required File? imageFile,
    required String? existingImagePath,
    String? expenseId,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    String? imagePath = existingImagePath;
    if (imageFile != null) {
      imagePath = imageFile.path;
    }

    final data = {
      'title': title,
      'amount': double.parse(amount),
      'category': category,
      'date': date,
      'imagePath': imagePath ?? '',
      'updatedAt': Timestamp.now(),
      'userId': user?.uid,
    };
    if (expenseId == null) {

      await FirebaseFirestore.instance
          .collection('expenses')
          .add({
        ...data,
        'createdAt': Timestamp.now(),
      });

    } else {

      await FirebaseFirestore.instance
          .collection('expenses')
          .doc(expenseId)
          .update(data);

    }
  }

}