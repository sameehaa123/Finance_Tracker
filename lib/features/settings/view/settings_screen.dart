import 'package:ai_poweredfinancetracker/features/reminder/view/bill_reminders_list_screen.dart';
import 'package:flutter/material.dart';

import '../../reminder/view/add_bill_reminder_screen.dart';
import '../controller/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController settingsController = SettingsController();
  final TextEditingController _monthlyLimitController =
  TextEditingController();
  final TextEditingController _categoryLimitController =
  TextEditingController();

  // 🔹 Predefined category options (dropdown)
  final List<String> _categoryOptions = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Others',
  ];
  String? _selectedCategory;

  Map<String, double> _categoryLimits = {};

  @override
void initState() {
  super.initState();
  _loadSettings();
}

Future<void> _loadSettings() async {
  final data = await settingsController.loadSettings();

  final monthlyLimit = data['monthlyLimit'] as double?;
  final categoryLimits =
      data['categoryLimits'] as Map<String, double>;

  if (monthlyLimit != null) {
    _monthlyLimitController.text =
        monthlyLimit.toStringAsFixed(2);
  }

  _categoryLimits = categoryLimits;

  setState(() {});
}
Future<void> _saveMonthlyLimit() async {

  await settingsController.saveMonthlyLimit(
    _monthlyLimitController.text,
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Monthly limit saved'),
    ),
  );

}
Future<void> _addOrUpdateCategoryLimit() async {

  if (_selectedCategory == null ||
      _selectedCategory!.isEmpty ||
      _categoryLimitController.text.trim().isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please choose a category and enter a limit',
        ),
      ),
    );
    return;
  }

  final limit = double.tryParse(
        _categoryLimitController.text.trim(),
      ) ??
      0.0;

  if (limit <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please enter a valid positive limit',
        ),
      ),
    );
    return;
  }

  _categoryLimits =
      await settingsController.saveCategoryLimit(
    category: _selectedCategory!,
    amount: _categoryLimitController.text,
    categoryLimits: _categoryLimits,
  );

  _categoryLimitController.clear();

  setState(() {});

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Category limit saved'),
    ),
  );
}


  Future<void> _removeCategoryLimit(String category) async {

  _categoryLimits =
      await settingsController.removeCategoryLimit(
    category: category,
    categoryLimits: _categoryLimits,
  );

  setState(() {});

}

  @override
  void dispose() {
    _monthlyLimitController.dispose();
    _categoryLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFF00897B);
    final media = MediaQuery.of(context);

    return Scaffold(
      // we keep this transparent so the gradient is visible everywhere
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: accent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity, // 🔹 force full-screen gradient
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
          // keep both top & bottom inside safe area, gradient is already behind
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              // 🔹 make sure content fills at least the visible height
              constraints: BoxConstraints(
                minHeight: media.size.height -
                    media.padding.top -
                    kToolbarHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔹 Monthly limit card
                  Card(
                    color: isDark ? Colors.white10 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Spending Limit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                              isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _monthlyLimitController,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Limit in AED',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _saveMonthlyLimit,
                              child: const Text('Save Monthly Limit'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 🔹 Category limits card
                  Card(
                    color: isDark ? Colors.white10 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category Spending Limits',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                              isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedCategory,
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _categoryOptions.map((c) {
                                    return DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedCategory = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _categoryLimitController,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Limit',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _addOrUpdateCategoryLimit,
                              child: const Text(
                                  'Add / Update Category Limit'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_categoryLimits.isNotEmpty)
                            Column(
                              children: _categoryLimits.entries.map((e) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    e.key,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Limit: AED ${e.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _removeCategoryLimit(e.key),
                                  ),
                                );
                              }).toList(),
                            )
                          else
                            Text(
                              'No category limits set yet.',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 🔹 Bill reminder section
                  Card(
                    color: isDark ? Colors.white10 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        'Bill Payment Reminders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Add due date, time and description for upcoming bills.',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddBillReminderScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Card(
                    color: isDark ? Colors.white10 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        'View Bill Reminders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BillRemindersListScreen()),
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
  

