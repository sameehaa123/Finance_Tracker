import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class DashboardController extends ChangeNotifier {
  final user = FirebaseAuth.instance.currentUser!;
  double total = 0;
  Map<String, double> categoryTotals = {};

  Future<void> fetchExpenses(BuildContext context) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('userId', isEqualTo: user.uid)
        .get();

    double totalAmount = 0;
    Map<String, double> catTotals = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      double amount = double.tryParse(data['amount'].toString()) ?? 0;
      String cat = data['category'] ?? 'Other';
      totalAmount += amount;
      catTotals[cat] = (catTotals[cat] ?? 0) + amount;
    }

    total = totalAmount;
    categoryTotals = catTotals;

    final prefs = await SharedPreferences.getInstance();
    final limit = prefs.getDouble('monthlyLimit');

    if (limit != null && totalAmount > limit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠ Monthly spending limit exceeded!"),
          backgroundColor: Colors.red,
        ),
      );
    }

    notifyListeners();
  }
}
