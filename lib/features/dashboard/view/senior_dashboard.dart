// // import 'package:flutter/material.dart';
// // import 'dashboard_screen.dart';
// //
// // class SeniorDashboard extends StatelessWidget {
// //   const SeniorDashboard({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Senior Citizen Dashboard"),
// //       ),
// //       body: const Dashboard(),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'add_expense.dart';
// import 'expense_list.dart';
// import 'ai_suggestions_screen.dart';
// import '../widgets/common_dashboard_appbar.dart';
// import '../services/theme_service.dart';
//
// class SeniorDashboard extends StatefulWidget {
//   const SeniorDashboard({super.key});
//
//   @override
//   State<SeniorDashboard> createState() => _SeniorDashboardState();
// }
//
// class _SeniorDashboardState extends State<SeniorDashboard> {
//   final user = FirebaseAuth.instance.currentUser!;
//   double total = 0;
//
//   // ✅ Bar chart data
//   List<String> categories = [];
//   List<double> values = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchExpenses();
//   }
//
//   // ✅ FIXED & SAFE FETCH
//   Future<void> fetchExpenses() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('expenses')
//         .where('userId', isEqualTo: user.uid)
//         .get();
//
//     double sum = 0;
//     Map<String, double> map = {};
//
//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//
//       double amt = 0;
//       try {
//         amt = (data['amount'] ?? 0).toDouble();
//       } catch (_) {
//         amt = double.tryParse(data['amount'].toString()) ?? 0;
//       }
//
//       final cat = data['category'] ?? 'Other';
//
//       sum += amt;
//       map[cat] = (map[cat] ?? 0) + amt;
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//     final limit = prefs.getDouble('monthlyLimit');
//
//     if (limit != null && sum > limit && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("⚠ You have exceeded your monthly limit!"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//
//     if (mounted) {
//       setState(() {
//         total = sum;
//         categories = map.keys.toList();
//         values = map.values.toList();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = ThemeService.isDark.value;
//     final accent = const Color(0xFF00897B);
//
//     return Scaffold(
//       appBar: commonDashboardAppBar(
//         context: context,
//         title: "Senior Dashboard",
//       ),
//
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: isDark ? const Color(0xFF0B1220) : Colors.white,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               // ✅ TITLE
//               Text(
//                 "Category Wise Spending",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // ✅ BAR CHART (SENIOR FRIENDLY)
//               SizedBox(
//                 height: 260,
//                 child: categories.isEmpty
//                     ? Center(
//                   child: Text(
//                     "No data yet",
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: isDark ? Colors.white70 : Colors.black54,
//                     ),
//                   ),
//                 )
//                     : BarChart(
//                   BarChartData(
//                     gridData: FlGridData(show: true),
//                     titlesData: FlTitlesData(show: false),
//                     borderData: FlBorderData(show: false),
//                     barGroups: List.generate(categories.length, (i) {
//                       return BarChartGroupData(
//                         x: i,
//                         barRods: [
//                           BarChartRodData(
//                             toY: values[i],
//                             width: 26, // ✅ thick bars for seniors
//                             color: accent,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ],
//                       );
//                     }),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // ✅ BIG TOTAL
//               Text(
//                 "TOTAL SPENT",
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: isDark ? Colors.white70 : Colors.black54,
//                 ),
//               ),
//
//               const SizedBox(height: 6),
//
//               Text(
//                 "AED ${total.toStringAsFixed(2)}",
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : accent,
//                 ),
//               ),
//
//               const SizedBox(height: 28),
//
//               // ✅ BIG ACCESSIBLE BUTTONS
//               bigButton("➕ ADD EXPENSE", () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
//                 ).then((_) => fetchExpenses());
//               }),
//
//               const SizedBox(height: 14),
//
//               bigButton("📋 VIEW EXPENSES", () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) => const ListExpensesScreen()),
//                 );
//               }),
//
//               const SizedBox(height: 14),
//
//               bigButton("🤖 AI SUGGESTIONS", () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AiSuggestionsScreen(
//                       total: total,
//                       categoryTotals:
//                       {for (int i = 0; i < categories.length; i++) categories[i]: values[i]},
//                     ),
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ✅ BIG BUTTON FOR SENIORS
//   Widget bigButton(String text, VoidCallback onTap) {
//     return SizedBox(
//       width: double.infinity,
//       height: 62,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF00897B),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//         ),
//         onPressed: onTap,
//         child: Text(
//           text,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'add_expense.dart';
// import 'expense_list.dart';
// import 'ai_suggestions_screen.dart';
// import '../widgets/common_dashboard_appbar.dart';
// import '../services/theme_service.dart';
//
// class SeniorDashboard extends StatefulWidget {
//   const SeniorDashboard({super.key});
//
//   @override
//   State<SeniorDashboard> createState() => _SeniorDashboardState();
// }
//
// class _SeniorDashboardState extends State<SeniorDashboard> {
//   final user = FirebaseAuth.instance.currentUser!;
//   double total = 0;
//   Map<String, double> categoryTotals = {};
//
//   // ✅ SAME COLOR PALETTE AS YOUR MAIN DASHBOARD
//   final List<Color> sliceColors = const [
//     Color(0xFF4DB6AC),
//     Color(0xFF81C784),
//     Color(0xFFFFB74D),
//     Color(0xFFE57373),
//     Color(0xFFBA68C8),
//     Color(0xFF64B5F6),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchExpenses();
//   }
//
//   Future<void> fetchExpenses() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('expenses')
//         .where('userId', isEqualTo: user.uid)
//         .get();
//
//     double sum = 0;
//     Map<String, double> map = {};
//
//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//
//       double amt = 0;
//       try {
//         amt = (data['amount'] ?? 0).toDouble();
//       } catch (_) {
//         amt = double.tryParse(data['amount'].toString()) ?? 0;
//       }
//
//       final cat = data['category'] ?? 'Other';
//       sum += amt;
//       map[cat] = (map[cat] ?? 0) + amt;
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//     final limit = prefs.getDouble('monthlyLimit');
//
//     if (limit != null && sum > limit && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("⚠ You have exceeded your monthly limit!"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//
//     if (mounted) {
//       setState(() {
//         total = sum;
//         categoryTotals = map;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = ThemeService.isDark.value;
//     final accent = const Color(0xFF00897B);
//
//     final entries = categoryTotals.entries.toList();
//
//     return Scaffold(
//       appBar: commonDashboardAppBar(
//         context: context,
//         title: "Senior Dashboard",
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: isDark ? const Color(0xFF0B1220) : Colors.white,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               // 🔹 Title
//               Text(
//                 "Category-wise Spending",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // 🔹 Bar chart
//               SizedBox(
//                 height: 260,
//                 child: entries.isEmpty
//                     ? Center(
//                   child: Text(
//                     "No data yet",
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: isDark ? Colors.white70 : Colors.black54,
//                     ),
//                   ),
//                 )
//                     : BarChart(
//                   BarChartData(
//                     gridData: FlGridData(show: true),
//                     titlesData: FlTitlesData(show: false),
//                     borderData: FlBorderData(show: false),
//                     barGroups: List.generate(entries.length, (i) {
//                       final e = entries[i];
//                       final color =
//                       sliceColors[i % sliceColors.length];
//                       return BarChartGroupData(
//                         x: i,
//                         barRods: [
//                           BarChartRodData(
//                             toY: e.value,
//                             width: 26,
//                             color: color,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ],
//                       );
//                     }),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // 🔹 Legend with category + color + amount
//               if (entries.isNotEmpty) ...[
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     "Categories",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Column(
//                   children: List.generate(entries.length, (i) {
//                     final e = entries[i];
//                     final color = sliceColors[i % sliceColors.length];
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 14,
//                             height: 14,
//                             decoration: BoxDecoration(
//                               color: color,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               e.key,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: isDark
//                                     ? Colors.white
//                                     : Colors.black87,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             "AED ${e.value.toStringAsFixed(2)}",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: isDark
//                                   ? Colors.white70
//                                   : Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               ],
//
//               const SizedBox(height: 24),
//
//               // 🔹 Big total
//               Text(
//                 "TOTAL SPENT",
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: isDark ? Colors.white70 : Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 "AED ${total.toStringAsFixed(2)}",
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : accent,
//                 ),
//               ),
//
//               const SizedBox(height: 26),
//
//               // 🔹 Big buttons
//               bigButton("➕ ADD EXPENSE", () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const AddExpenseScreen(),
//                   ),
//                 ).then((_) => fetchExpenses());
//               }),
//
//               const SizedBox(height: 14),
//
//               bigButton("📋 VIEW EXPENSES", () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ListExpensesScreen(),
//                   ),
//                 );
//               }),
//
//               const SizedBox(height: 14),
//
//               bigButton("🤖 AI SUGGESTIONS", () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AiSuggestionsScreen(
//                       total: total,
//                       categoryTotals: categoryTotals, // ✅ pass real map
//                     ),
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget bigButton(String text, VoidCallback onTap) {
//     return SizedBox(
//       width: double.infinity,
//       height: 62,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF00897B),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//         ),
//         onPressed: onTap,
//         child: Text(
//           text,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';

import 'package:ai_poweredfinancetracker/features/reminder/view/widgets/upcoming_bills_banner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/Services/show_popup_service.dart';
import '../../expense/view/add_expense.dart';
import '../../expense/view/expense_list.dart';
import '../../ai/view/ai_suggestions_screen.dart';
import '../widgets/common_dashboard_appbar.dart';

class SeniorDashboard extends StatefulWidget {
  const SeniorDashboard({super.key});

  @override
  State<SeniorDashboard> createState() => _SeniorDashboardState();
}

class _SeniorDashboardState extends State<SeniorDashboard> {
  final user = FirebaseAuth.instance.currentUser!;
  double total = 0;
  Map<String, double> categoryTotals = {};

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
  //   double sum = 0;
  //   final Map<String, double> map = {};
  //
  //   for (var doc in snapshot.docs) {
  //     final data = doc.data();
  //
  //     double amt = 0;
  //     try {
  //       amt = (data['amount'] ?? 0).toDouble();
  //     } catch (_) {
  //       amt = double.tryParse(data['amount'].toString()) ?? 0;
  //     }
  //
  //     final cat = data['category'] ?? 'Other';
  //     sum += amt;
  //     map[cat] = (map[cat] ?? 0) + amt;
  //   }
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final limit = prefs.getDouble('monthlyLimit');
  //
  //   if (limit != null && sum > limit && mounted) {
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
  //       total = sum;
  //       categoryTotals = map;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Use app theme to know if dark mode is ON
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFF00897B);
    final entries = categoryTotals.entries.toList();

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
                  "AED ${total.toStringAsFixed(2)}",
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
                  ).then((_) => fetchExpenses());
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
                        total: total,
                        categoryTotals: categoryTotals,
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
}
