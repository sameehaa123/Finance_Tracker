
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/theme_service.dart';
import '../../auth/view/login_screen.dart';
import '../../expense/view/add_expense.dart';
import '../../expense/view/expense_list.dart'; // <-- import your expense list screen
import '../../ai/view/ai_suggestions_screen.dart'; // <-- NEW: AI suggestions screen
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);
  await prefs.clear();
  await FirebaseAuth.instance.signOut();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
  );
}

class _DashboardState extends State<Dashboard> {
  final user = FirebaseAuth.instance.currentUser!;
  double total = 0;
  Map<String, double> categoryTotals = {};

  @override
  void initState() {
    super.initState();
    fetchExpenses();
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
      String cat = data['category'] ?? 'Other';
      totalAmount += amount;
      catTotals[cat] = (catTotals[cat] ?? 0) + amount;
    }

    setState(() {
      total = totalAmount;
      categoryTotals = catTotals;
    });
  }

  final List<Color> sliceColors = [
    const Color(0xFF4DB6AC),
    const Color(0xFF81C784),
    const Color(0xFFFFB74D),
    const Color(0xFFE57373),
    const Color(0xFFBA68C8),
    const Color(0xFF64B5F6),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark.value;
    final accent = const Color(0xFF00897B);

    return Scaffold(
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
          child: Column(
            children: [
              // 🔹 Top bar
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Spendly',
                        style: TextStyle(
                          color: isDark ? Colors.white : accent,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    // 🔹 Theme toggle
                    ValueListenableBuilder<bool>(
                      valueListenable: ThemeService.isDark,
                      builder: (context, val, _) {
                        return IconButton(
                          icon: Icon(val ? Icons.wb_sunny : Icons.dark_mode),
                          color: val ? Colors.white : accent,
                          onPressed: () async {
                            await ThemeService.toggle();
                            setState(() {});
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      color: isDark ? Colors.white : accent,
                      onPressed: () async => await _logout(context),
                    ),
                  ],
                ),
              ),

              // 🔹 Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 8),
                  child: Column(
                    children: [
                      // Donut chart card
                      Card(
                        color: isDark ? Colors.white10 : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Spending Overview",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 40), // space before chart
                              GestureDetector(
                                onTap: () {
                                  // Navigate to Expense List Screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const ListExpensesScreen(),
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
                              const SizedBox(height: 40), // space after chart
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
                                          borderRadius:
                                          BorderRadius.circular(4),
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
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔹 Single add button
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
