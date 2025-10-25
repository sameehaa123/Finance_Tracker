import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? expenseId; // null = add, non-null = edit
  final Map<String, dynamic>? expenseData;

  const AddExpenseScreen({Key? key, this.expenseId, this.expenseData})
      : super(key: key);

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
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  Future<void> _openImage(File imageFile) async {
    await OpenFile.open(imageFile.path);
  }

  Future<void> _saveExpense() async {
    final user = FirebaseAuth.instance.currentUser;

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

    String? imagePath = _existingImagePath;
    if (_imageFile != null) {
      imagePath = _imageFile!.path;
    }

    final data = {
      'title': _titleController.text,
      'amount': double.parse(_amountController.text),
      'category': _selectedCategory,
      'date': _dateController.text,
      'imagePath': imagePath ?? '',
      'updatedAt': Timestamp.now(),
      'userId': user?.uid,
    };

    try {
      if (widget.expenseId == null) {
        await FirebaseFirestore.instance.collection('expenses').add({
          ...data,
          'createdAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully')),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(widget.expenseId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated successfully')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      print('Error saving expense: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving expense')),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Expense Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
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
            const SizedBox(height: 15),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Image picker and open image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageFile != null
                    ? GestureDetector(
                  onTap: () => _openImage(_imageFile!),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
                    : _existingImagePath != null &&
                    _existingImagePath!.isNotEmpty
                    ? GestureDetector(
                  onTap: () =>
                      _openImage(File(_existingImagePath!)),
                  child: Image.file(File(_existingImagePath!),
                      fit: BoxFit.cover),
                )
                    : const Center(
                  child: Text(
                    'Tap to add attachment (optional)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveExpense,
                icon: const Icon(Icons.save),
                label: Text(
                    isEditMode ? 'Update Expense' : 'Save Expense'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
