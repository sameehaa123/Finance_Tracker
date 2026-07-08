import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../controller/expense_controller.dart';


class AddExpenseScreen extends StatefulWidget {
  final String? expenseId; // null = add, non-null = edit
  final Map<String, dynamic>? expenseData;

  const AddExpenseScreen({super.key, this.expenseId, this.expenseData});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedCategory;
  File? _imageFile;
  String? _existingImagePath;
  bool _isLoading = false;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expenseData != null) {
      _titleController.text = widget.expenseData!['title'];
      _amountController.text = widget.expenseData!['amount'].toString();
      _dateController.text = widget.expenseData!['date'];
      _selectedCategory = widget.expenseData!['category'];
      _existingImagePath = widget.expenseData!['imagePath'];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage =
      await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  Future<void> _openImage(File imageFile) async {
    await OpenFile.open(imageFile.path);
  }


  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_dateController.text)
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.expenseId != null;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Theme accent color for AppBar and buttons
    final accent = isDarkMode ? Colors.tealAccent : const Color(0xFF00897B);
    final backgroundGradient = isDarkMode
        ? [Colors.grey.shade900, Colors.grey.shade800]
        : [const Color(0xFFA8E6CF), Colors.white];
    final textFieldColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final hintColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Expense' : 'Add Expense',
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: accent),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Expense Title', accent),
              _buildTextField(_titleController, 'Enter title',
                  color: textFieldColor, hintColor: hintColor),
              const SizedBox(height: 16),
              _buildLabel('Amount', accent),
              _buildTextField(_amountController, 'Enter amount',
                  keyboard: TextInputType.number,
                  color: textFieldColor,
                  hintColor: hintColor),
              const SizedBox(height: 16),
              _buildLabel('Category', accent),
              _buildDropdown(textFieldColor),
              const SizedBox(height: 16),
              _buildLabel('Date', accent),
              _buildDatePicker(context, textFieldColor, hintColor),
              const SizedBox(height: 16),
              _buildLabel('Attachment (optional)', accent),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    border: Border.all(color: accent.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imageFile != null
                      ? GestureDetector(
                    onTap: () => _openImage(_imageFile!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      : _existingImagePath != null &&
                      _existingImagePath!.isNotEmpty
                      ? GestureDetector(
                    onTap: () =>
                        _openImage(File(_existingImagePath!)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(_existingImagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      : Center(
                    child: Text(
                      'Tap to add an image',
                      style: TextStyle(
                        color: hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveExpense,
                  icon: Icon(Icons.save, color: Colors.white),
                  label: Text(
                    isEditMode ? 'Update Expense' : 'Save Expense',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _saveExpense() async {
  // Validation stays in View
  if (_titleController.text.isEmpty ||
      _amountController.text.isEmpty ||
      _selectedCategory == null ||
      _dateController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Create controller object
    ExpenseController expenseController = ExpenseController();

    // Call controller method
    await expenseController.saveExpense(
      title: _titleController.text,
      amount: _amountController.text,
      date: _dateController.text,
      category: _selectedCategory,
      imageFile: _imageFile,
      existingImagePath: _existingImagePath,
      expenseId: widget.expenseId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.expenseId == null
                ? 'Expense added successfully'
                : 'Expense updated successfully',
          ),
        ),
      );

        Navigator.pop(context);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  Widget _buildLabel(String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: accent,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboard = TextInputType.text,
        Color color = Colors.white,
        Color hintColor = Colors.grey}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4)
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: TextStyle(color: hintColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4)
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
        decoration: const InputDecoration(border: InputBorder.none),
        items: _categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) => setState(() {
          _selectedCategory = value!;
        }),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, Color color, Color hintColor) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4)
        ],
      ),
      child: TextField(
        controller: _dateController,
        readOnly: true,
        style: TextStyle(color: hintColor),
        decoration: InputDecoration(
          hintText: 'Select date',
          hintStyle: TextStyle(color: hintColor),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: hintColor),
            onPressed: () => _selectDate(context),
          ),
        ),
      ),
    );
  }
}
