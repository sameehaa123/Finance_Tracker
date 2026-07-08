import 'package:ai_poweredfinancetracker/features/reminder/view/widgets/upcoming_bills_banner.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import '../../../core/Services/show_popup_service.dart';
import '../../expense/view/add_expense.dart';
import '../../expense/view/expense_list.dart';
import '../../ai/view/ai_suggestions_screen.dart';
import '../widgets/common_dashboard_appbar.dart';
import '../controller/dashboard_controller.dart';

class ProfessionalDashboard extends StatefulWidget {
  const ProfessionalDashboard({super.key});

  @override
  State<ProfessionalDashboard> createState() =>
      _ProfessionalDashboardState();
}

class _ProfessionalDashboardState extends State<ProfessionalDashboard> {
  final DashboardController dashboardController = DashboardController();

  // Same palette as main dashboard
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
    dashboardController.fetchExpenses(context);
    dashboardController.addListener(_refreshScreen);
    checkUpcomingBills(context);
 }

 void _refreshScreen() {
  if (mounted) {
    setState(() {});
  }
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFF00897B);
    final entries = dashboardController.categoryTotals.entries.toList();

    return Scaffold(
      appBar: commonDashboardAppBar(
        context: context,
        title: "Professional Dashboard",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // Same gradient style as main & senior dashboard
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
                  "Professional Dashboard",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : accent,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const UpcomingBillsBanner(),

                const SizedBox(height: 12),
                SizedBox(height: 10,),
                // 🔹 KPI row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _kpiCard(
                      context,
                      label: "Total Spent",
                      value: "AED ${dashboardController.total.toStringAsFixed(2)}",
                      isDark: isDark,
                    ),
                    _kpiCard(
                      context,
                      label: "Categories",
                      value: dashboardController.categoryTotals.length.toString(),
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Card with bar chart
                Card(
                  color: isDark ? Colors.white10 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Category-wise Breakdown",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 260,
                          child: entries.isEmpty
                              ? Center(
                            child: Text(
                              "No data yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          )
                              : BarChart(
                            BarChartData(
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                drawVerticalLine: false,
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= entries.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final label =
                                          entries[index].key;
                                      return Padding(
                                        padding:
                                        const EdgeInsets.only(top: 4),
                                        child: Text(
                                          label.length > 6
                                              ? "${label.substring(0, 6)}…"
                                              : label,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black87,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups:
                              List.generate(entries.length, (i) {
                                final e = entries[i];
                                final color =
                                sliceColors[i % sliceColors.length];
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value,
                                      width: 18,
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 🔹 Legend
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
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.key,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Text(
                              "AED ${e.value.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 14,
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

                const SizedBox(height: 22),

                // 🔹 AI button + expenses navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.list),
                      label: const Text("View Expenses"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                        isDark ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: isDark
                              ? Colors.white54
                              : Colors.black26,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ListExpensesScreen(),
                          ),
                        );
                      },
                    ),

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text("AI Suggestions"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AiSuggestionsScreen(
                              total: dashboardController.total,
                              categoryTotals: dashboardController.categoryTotals,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),

      // 🔹 FAB to add expense
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          ).then((_) => dashboardController.fetchExpenses(context));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _kpiCard(
      BuildContext context, {
        required String label,
        required String value,
        required bool isDark,
      }) {
    return Expanded(
      child: Card(
        color: isDark ? Colors.white10 : Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
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

