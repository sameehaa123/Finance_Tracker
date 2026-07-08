import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controller/reminder_controller.dart';

class BillRemindersListScreen extends StatelessWidget {
  const BillRemindersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ReminderController reminderController = ReminderController();

    // If somehow user is not logged in
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Bill Reminders"),
          backgroundColor: const Color(0xFF00897B),
        ),
        body: Center(
          child: Text(
            "Please log in to view your bill reminders.",
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bill Reminders"),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: StreamBuilder<QuerySnapshot>(
          stream: reminderController.getReminders(user.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // helpful for debugging in console
              debugPrint("BillReminders stream error: ${snapshot.error}");
              return Center(
                child: Text(
                  "Something went wrong loading reminders.",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return Center(
                child: Text(
                  "No bill reminders found.",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              );
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return Center(
                child: Text(
                  "No bill reminders added yet.",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              );
            }

            // 🔹 Sort locally by dueAt (earliest first)
            final sortedDocs = [...docs];
            sortedDocs.sort((a, b) {
              final da = (a['dueAt'] as Timestamp).toDate();
              final db = (b['dueAt'] as Timestamp).toDate();
              return da.compareTo(db);
            });

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDocs.length,
              itemBuilder: (context, i) {
                final doc = sortedDocs[i];
                final data = doc.data() as Map<String, dynamic>;

                final title = data['title'] ?? "Bill";
                final amount = (data['amount'] ?? 0).toDouble();
                final category = data['category'] ?? 'Others';
                final dueAt = (data['dueAt'] as Timestamp).toDate();

                final dateStr =
                    "${dueAt.day.toString().padLeft(2, '0')}/"
                    "${dueAt.month.toString().padLeft(2, '0')}/"
                    "${dueAt.year}  "
                    "${dueAt.hour.toString().padLeft(2, '0')}:"
                    "${dueAt.minute.toString().padLeft(2, '0')}";

                return Card(
                  elevation: 4,
                  color: isDark ? Colors.white10 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    title: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      "$category • $dateStr\nAED ${amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                     onPressed: () async {
                        await reminderController.deleteReminder(doc.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                         content: Text("Reminder deleted"),
                        backgroundColor: Colors.red,
                       ),
                      );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
