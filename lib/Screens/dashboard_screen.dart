import 'package:ai_poweredfinancetracker/Screens/expense_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_expense.dart';
import 'login_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
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
      double amount = (data['amount'] ?? 0).toDouble();
      String cat = data['category'] ?? 'Other';
      totalAmount += amount;
      catTotals[cat] = (catTotals[cat] ?? 0) + amount;
    }

    setState(() {
      total = totalAmount;
      categoryTotals = catTotals;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(onPressed: _logout, icon: Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Total Spent: \$${total.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            categoryTotals.isEmpty
                ? Text("No data yet")
                : Expanded(
              child: GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) =>  ListExpensesScreen()),
                  );
                },
                child: PieChart(
                  PieChartData(
                    sections: categoryTotals.entries.map((entry) {
                      int index = categoryTotals.keys.toList().indexOf(entry.key);
                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: entry.value,
                        title: entry.key,
                        radius: 80,
                        titleStyle: TextStyle(color: Colors.white, fontSize: 14),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen()));
          fetchExpenses(); // Refresh data after adding expense
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
