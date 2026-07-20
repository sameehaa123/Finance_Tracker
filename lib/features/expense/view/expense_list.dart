import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/theme_service.dart';
import '../controller/expense_controller.dart';
import 'add_expense.dart';

class ListExpensesScreen extends StatelessWidget {
  const ListExpensesScreen({super.key});

  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    ExpenseController expenseController = ExpenseController();
    final isDark = ThemeService.isDark.value;
    final accent = const Color(0xFF00897B);
    final backgroundGradient = isDark
        ? [Color(0xFF081427), Color(0xFF17233A)]
        : [Color(0xFFA8E6CF), Colors.white];
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? Colors.white10 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Expenses'),
        backgroundColor: accent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: expenseController.getExpenses(user.uid),
           builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Something went wrong',
                      style: TextStyle(color: textColor)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final expenses = snapshot.data!.docs;
            if (expenses.isEmpty) {
              return Center(
                child: Text(
                  'No expenses found.\nTap + to add your first one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: subTextColor),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final doc = expenses[index];
                final data = doc.data() as Map<String, dynamic>;

                return Card(
                  color: cardColor,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: data['imagePath'] != null &&
                        data['imagePath'].toString().isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                      Image.file(
                      File(data['imagePath']),
                        width: 50,
                        height: 50,
                      fit: BoxFit.cover,
                      ),
                    )
                        : Icon(Icons.receipt_long, color: accent, size: 28),
                    title: Text(
                      data['title'] ?? 'Untitled',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      '${data['category']} • ${data['date']}',
                      style: TextStyle(color: subTextColor),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: accent),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddExpenseScreen(
                                  expenseId: doc.id,
                                  expenseData: data,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: cardColor,
                                title: Text(
                                  'Delete Expense',
                                  style: TextStyle(color: textColor),
                                ),
                                content: Text(
                                  'Are you sure you want to delete this expense?',
                                  style: TextStyle(color: subTextColor),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: accent),
                                      )),
                                  TextButton(
                                    onPressed: () async {
                                  Navigator.pop(context);
             try {
                     ExpenseController expenseController = ExpenseController();
                     await expenseController.deleteExpense(doc.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
               content: Text('Expense deleted'),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete expense'),
        ),
      );
    }
  }
},
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${data['title']} → AED ${data['amount'].toString()}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
