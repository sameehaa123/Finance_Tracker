// import 'package:flutter/material.dart';
// import 'dashboard_screen.dart'; // your existing dashboard widget
//
// class StudentDashboard extends StatelessWidget {
//   const StudentDashboard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Student Dashboard"),
//       ),
//       body: Column(
//         children: const [
//           Expanded(
//             child: Dashboard(), // embeds your existing dashboard
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:ai_poweredfinancetracker/features/reminder/view/widgets/upcoming_bills_banner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/Services/show_popup_service.dart';
import '../../expense/view/add_expense.dart';
import '../../expense/view/expense_list.dart';
import '../../ai/view/ai_suggestions_screen.dart';
import '../widgets/common_dashboard_appbar.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final user = FirebaseAuth.instance.currentUser!;
  double total = 0;
  Map<String, double> categoryTotals = {};

  final List<Color> sliceColors = const [
    Color(0xFF4DB6AC),
    Color(0xFF81C784),
    Color(0xFFFFB74D),
    Color(0xFFE57373),
    Color(0xFFBA68C8),
    Color(0xFF64B5F6),
  ];

  @override
  void initState() {
    super.initState();
    fetchExpenses();
    checkUpcomingBills(context);
  }
  Future<void> fetchExpenses() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('userId', isEqualTo: user.uid)
        .get();

    double totalAmount = 0;
    Map<String, double> catTotals = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      double amount = 0;
      try {
        amount = (data['amount'] ?? 0).toDouble();
      } catch (_) {
        amount = double.tryParse(data['amount'].toString()) ?? 0;
      }
      final cat = data['category'] ?? 'Other';
      totalAmount += amount;
      catTotals[cat] = (catTotals[cat] ?? 0) + amount;
    }

    // 🔹 Load monthly & category limits
    final prefs = await SharedPreferences.getInstance();
    final monthlyLimit = prefs.getDouble('monthlyLimit');

    // check monthly total
    if (monthlyLimit != null && totalAmount > monthlyLimit && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠ You have exceeded your monthly limit!"),
          backgroundColor: Colors.red,
        ),
      );
    }

    // check per-category limits
    final raw = prefs.getString('categoryLimits');
    if (raw != null && raw.isNotEmpty && mounted) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final limits = decoded.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
      );

      for (final entry in catTotals.entries) {
        final cat = entry.key;
        final spent = entry.value;
        final limit = limits[cat];

        if (limit != null && spent > limit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "⚠ You exceeded the limit for $cat (AED ${spent.toStringAsFixed(2)} > AED ${limit.toStringAsFixed(2)})",
              ),
              backgroundColor: Colors.orange,
            ),
          );
          break; // show one warning at a time
        }
      }
    }

    if (mounted) {
      setState(() {
        total = totalAmount;
        categoryTotals = catTotals;
      });
    }
  }

  // Future<void> fetchExpenses() async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('expenses')
  //       .where('userId', isEqualTo: user.uid)
  //       .get();
  //
  //   double totalAmount = 0;
  //   Map<String, double> catTotals = {};
  //
  //   for (var doc in snapshot.docs) {
  //     final data = doc.data();
  //     double amount = 0;
  //     try {
  //       amount = (data['amount'] ?? 0).toDouble();
  //     } catch (_) {
  //       amount = double.tryParse(data['amount'].toString()) ?? 0;
  //     }
  //
  //     final cat = data['category'] ?? 'Other';
  //     totalAmount += amount;
  //     catTotals[cat] = (catTotals[cat] ?? 0) + amount;
  //   }
  //
  //   // 🔹 Monthly limit check from SharedPreferences
  //   final prefs = await SharedPreferences.getInstance();
  //   final limit = prefs.getDouble('monthlyLimit');
  //
  //   if (limit != null && totalAmount > limit && mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("⚠ You have exceeded your monthly limit!"),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  //
  //   if (mounted) {
  //     setState(() {
  //       total = totalAmount;
  //       categoryTotals = catTotals;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Use theme brightness (dark / light)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFF00897B);

    return Scaffold(
      appBar: commonDashboardAppBar(
        context: context,
        title: "Student Dashboard",
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
            colors: [Color(0xFF081427), Color(0xFF17233A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : const LinearGradient(
            colors: [Color(0xFFA8E6CF), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            child: ListView(
              children: [
                // 🔹 Donut chart card
                Card(
                  color: isDark ? Colors.white10 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Student Dashboard",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : accent,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const UpcomingBillsBanner(),
                        SizedBox(height: 10,),

                        Text(
                          "Spending Overview",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 40),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ListExpensesScreen(),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 250,
                            child: categoryTotals.isEmpty
                                ? const Center(
                              child: Text("No data yet"),
                            )
                                : PieChart(
                              PieChartData(
                                centerSpaceRadius: 60,
                                sectionsSpace: 2,
                                startDegreeOffset: -90,
                                sections: categoryTotals.entries
                                    .map((e) {
                                  final idx = categoryTotals.keys
                                      .toList()
                                      .indexOf(e.key);
                                  final color = sliceColors[
                                  idx % sliceColors.length];
                                  return PieChartSectionData(
                                    color: color,
                                    value: e.value,
                                    radius: 80,
                                    title: '',
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          "AED ${total.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Total Spent",
                          style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 8,
                          children: categoryTotals.entries.map((entry) {
                            final idx = categoryTotals.keys
                                .toList()
                                .indexOf(entry.key);
                            final color =
                            sliceColors[idx % sliceColors.length];
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 AI Suggestions button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: categoryTotals.isEmpty
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AiSuggestionsScreen(
                            total: total,
                            categoryTotals: categoryTotals,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text(
                      "View AI Suggestions",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                SizedBox(height: 100,)
              ],
            ),
          ),
        ),
      ),

      // 🔹 Center FAB for adding expenses
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'plus',
        backgroundColor: accent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          ).then((_) => fetchExpenses());
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
