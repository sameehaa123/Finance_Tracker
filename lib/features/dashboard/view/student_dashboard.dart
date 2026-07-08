import 'package:ai_poweredfinancetracker/features/reminder/view/widgets/upcoming_bills_banner.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/Services/show_popup_service.dart';
import '../../expense/view/add_expense.dart';
import '../../expense/view/expense_list.dart';
import '../../ai/view/ai_suggestions_screen.dart';
import '../widgets/common_dashboard_appbar.dart';
import '../controller/dashboard_controller.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
   final DashboardController dashboardController = DashboardController();

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
                            child: dashboardController.categoryTotals.isEmpty
                                ? const Center(
                              child: Text("No data yet"),
                            )
                                : PieChart(
                              PieChartData(
                                centerSpaceRadius: 60,
                                sectionsSpace: 2,
                                startDegreeOffset: -90,
                                sections: dashboardController.categoryTotals.entries
                                    .map((e) {
                                  final idx = dashboardController.categoryTotals.keys
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
                          "AED ${dashboardController.total.toStringAsFixed(2)}",
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
                          children: dashboardController.categoryTotals.entries.map((entry) {
                            final idx = dashboardController.categoryTotals.keys
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
                    onPressed: dashboardController.categoryTotals.isEmpty
                        ? null
                        : () {
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
          ).then((_) => dashboardController.fetchExpenses(context));
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
  @override
void dispose() {
  dashboardController.removeListener(_refreshScreen);
  super.dispose();
}
}
