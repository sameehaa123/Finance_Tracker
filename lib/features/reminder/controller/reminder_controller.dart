import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderController { 
  Future<void> saveReminder({
  required String title,
  required String description,
  required String category,
  required String amount,
  required DateTime selectedDate,
  required TimeOfDay selectedTime,
}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }
final DateTime dueDateTime = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );
  await FirebaseFirestore.instance
      .collection('billReminders')
      .add({
    'userId': user.uid,
    'title': title,
    'category': category,
    'description': description,
    'amount': double.tryParse(amount) ?? 0.0,
    'dueAt': Timestamp.fromDate(dueDateTime),
    'createdAt': FieldValue.serverTimestamp(),
  });

}
Stream<QuerySnapshot> getReminders(String userId) {

  return FirebaseFirestore.instance
      .collection('billReminders')
      .where('userId', isEqualTo: userId)
      .snapshots();

}
Future<void> deleteReminder(String id) async {

  await FirebaseFirestore.instance
      .collection('billReminders')
      .doc(id)
      .delete();

}
}



