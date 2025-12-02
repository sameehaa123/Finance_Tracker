import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> checkUpcomingBills(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final now = DateTime.now();

  final snapshot = await FirebaseFirestore.instance
      .collection('billReminders')
      .where('userId', isEqualTo: user.uid)
      .get();

  // Bills where time is already reached or within next 1 hour
  final upcoming = snapshot.docs.where((doc) {
    final data = doc.data();
    final ts = data['dueAt'];
    if (ts is! Timestamp) return false;
    final due = ts.toDate();

    // 👉 "time reached" or very near: dueAt <= now + 1 hour
    return due.isBefore(now.add(const Duration(hours: 1)));
  }).toList();

  if (upcoming.isEmpty) return;

  final first = upcoming.first.data();
  final title = first['title'] ?? 'Bill';
  final due = (first['dueAt'] as Timestamp).toDate();

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "🔔 Bill due: $title on "
            "${due.day}/${due.month} at "
            "${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}",
      ),
      duration: const Duration(seconds: 6),
    ),
  );
}
