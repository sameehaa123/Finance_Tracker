import 'package:flutter/material.dart';
import '../controller/reminder_controller.dart';

class AddBillReminderScreen extends StatefulWidget {
  const AddBillReminderScreen({super.key});

  @override
  State<AddBillReminderScreen> createState() =>
      _AddBillReminderScreenState();
}

class _AddBillReminderScreenState extends State<AddBillReminderScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController =
  TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  // 🔹 Category dropdown
  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Other'
  ];
  final String _selectedCategory = 'Food';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (result != null) {
      setState(() {
        _selectedTime = result;
      });
    }
  }

  Future<void> _saveReminder() async {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final amount =
        double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (title.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Please enter title, date and time for the bill.'),
        ),
      );
      return;
    }

    
    setState(() {
      _isSaving = true;
    });

try {
  // Create controller object
  ReminderController reminderController = ReminderController();

  // Call controller method
  await reminderController.saveReminder(
    title: title,
    description: desc,
    category: _selectedCategory,
    amount: _amountController.text.trim(),
    selectedDate: _selectedDate!,
    selectedTime: _selectedTime!,
  );

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill reminder saved')),
    );
    Navigator.pop(context);
  }
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving reminder: $e')),
    );
  }
}


      finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }



  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF00897B);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String dateText =
    _selectedDate == null ? 'Select Date' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    String timeText =
    _selectedTime == null ? 'Select Time' : _selectedTime!.format(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // 🔹 avoid black band
      appBar: AppBar(
        title: const Text('Add Bill Reminder'),
        backgroundColor: accent,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Bill Title (e.g. Internet, Rent)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(dateText),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(timeText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
                    ),
                    onPressed: _saveReminder,
                    child: const Text(
                      'Save Reminder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
