import 'package:ai_poweredfinancetracker/features/reminder/view/widgets/upcoming_bills_banner.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/Services/show_popup_service.dart';
import '../../expense/view/add_expense.dart';
import '../../expense/view/expense_list.dart';
import '../../ai/view/ai_suggestions_screen.dart';
import '../widgets/common_dashboard_appbar.dart';
import '../controller/dashboard_controller.dart';

class SeniorDashboard extends StatefulWidget {
  const SeniorDashboard({super.key});

  @override
  State<SeniorDashboard> createState() => _SeniorDashboardState();
}

class _SeniorDashboardState extends State<SeniorDashboard> {
  final DashboardController dashboardController = DashboardController();

  // Same palette as your main dashboard
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
   dashboardController.addListener(_refreshScreen);
   dashboardController.fetchExpenses(context);
    checkUpcomingBills(context);

  }
  void _refreshScreen() {
  if (mounted) {
    setState(() {});
  }
}

  @override
  Widget build(BuildContext context) {
    // Use app theme to know if dark mode is ON
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFF00897B);
    final entries = dashboardController.categoryTotals.entries.toList();

    return Scaffold(
      appBar: commonDashboardAppBar(
        context: context,
        title: "Senior Dashboard",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // 🔹 Match your main dashboard background style
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "Senior Dashboard",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : accent,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const UpcomingBillsBanner(),

                SizedBox(height: 10,),
                // 🔹 Title
                Text(
                  "Category-wise Spending",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Bar chart
                Card(
                  color: isDark ? Colors.white10 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 260,
                      child: entries.isEmpty
                          ? Center(
                        child: Text(
                          "No data yet",
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      )
                          : BarChart(
                        BarChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(entries.length, (i) {
                            final e = entries[i];
                            final color =
                            sliceColors[i % sliceColors.length];
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value,
                                  width: 26,
                                  color: color,
                                  borderRadius:
                                  BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Legend with category + color + amount
                if (entries.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color:
                        isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(entries.length, (i) {
                      final e = entries[i];
                      final color =
                      sliceColors[i % sliceColors.length];
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                e.key,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Text(
                              "AED ${e.value.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],

                const SizedBox(height: 24),

                // 🔹 Big total
                Text(
                  "TOTAL SPENT",
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "AED ${dashboardController.total.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : accent,
                  ),
                ),

                const SizedBox(height: 26),

                // 🔹 Big buttons
                bigButton("➕ ADD EXPENSE", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddExpenseScreen(),
                    ),
                  ).then((_) => dashboardController.fetchExpenses(context));
                }),

                const SizedBox(height: 14),

                bigButton("📋 VIEW EXPENSES", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ListExpensesScreen(),
                    ),
                  );
                }),

                const SizedBox(height: 14),

                bigButton("🤖 AI SUGGESTIONS", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AiSuggestionsScreen(
                        total: dashboardController.total,
                        categoryTotals: dashboardController.categoryTotals,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bigButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00897B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  @override
void dispose() {
  dashboardController.removeListener(_refreshScreen);
  super.dispose();
}
}
