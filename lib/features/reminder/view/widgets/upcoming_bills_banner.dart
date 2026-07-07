import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpcomingBillsBanner extends StatefulWidget {
  const UpcomingBillsBanner({super.key});

  @override
  State<UpcomingBillsBanner> createState() => _UpcomingBillsBannerState();
}

class _UpcomingBillsBannerState extends State<UpcomingBillsBanner> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 🔹 Update "now" every minute so banner refreshes automatically
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _buildBadgeLabel(DateTime due) {
    final today = DateTime(_now.year, _now.month, _now.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    final diff = dueDay.difference(today).inDays;

    if (diff == 0) return "Today";
    if (diff == 1) return "Tomorrow";
    if (diff < 0) return "Overdue";
    return "In $diff days";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('billReminders')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;

        // Filter bills: from yesterday up to next 7 days
        final from = _now.subtract(const Duration(days: 1));
        final to = _now.add(const Duration(days: 7));

        final upcoming = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final ts = data['dueAt'];
          if (ts is! Timestamp) return false;
          final due = ts.toDate();
          return due.isAfter(from) && due.isBefore(to);
        }).toList();

        if (upcoming.isEmpty) {
          // nothing relevant now -> hide banner
          return const SizedBox.shrink();
        }

        // Sort nearest first
        upcoming.sort((a, b) {
          final da = (a['dueAt'] as Timestamp).toDate();
          final db = (b['dueAt'] as Timestamp).toDate();
          return da.compareTo(db);
        });

        // show at most 3 bills
        final visible = upcoming.take(3).toList();

        return Card(
          color: isDark ? Colors.white10 : Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Upcoming Bills",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Column(
                  children: visible.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Bill';
                    final amount = (data['amount'] ?? 0).toDouble();
                    final ts = data['dueAt'] as Timestamp;
                    final due = ts.toDate();

                    final badge = _buildBadgeLabel(due);

                    final dateStr =
                        "${due.day.toString().padLeft(2, '0')}/"
                        "${due.month.toString().padLeft(2, '0')} "
                        "${due.hour.toString().padLeft(2, '0')}:"
                        "${due.minute.toString().padLeft(2, '0')}";

                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            amount > 0
                                ? "AED ${amount.toStringAsFixed(2)}"
                                : dateStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badge == "Overdue"
                                  ? Colors.red.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: badge == "Overdue"
                                    ? Colors.red
                                    : Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
