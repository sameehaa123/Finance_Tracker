import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  String? _existingImageUrl;
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
    // If editing, prefill data
    if (widget.expenseData != null) {
      _titleController.text = widget.expenseData!['title'];
      _amountController.text = widget.expenseData!['amount'].toString();
      _dateController.text = widget.expenseData!['date'];
      _selectedCategory = widget.expenseData!['category'];
      _existingImageUrl = widget.expenseData!['imageUrl'];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref =
      FirebaseStorage.instance.ref().child('expense_attachments/$fileName');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
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

    String? imageUrl = _existingImageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    final data = {
      'title': _titleController.text,
      'amount': double.parse(_amountController.text),
      'category': _selectedCategory,
      'date': _dateController.text,
      'imageUrl': imageUrl ?? '',
      'updatedAt': Timestamp.now(),
      'userId' : user?.uid

    };

    try {
      if (widget.expenseId == null) {
        // ADD
        await FirebaseFirestore.instance.collection('expenses').add({
          ...data,
          'createdAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully')),
        );
      } else {
        // EDIT
        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(widget.expenseId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated successfully')),
        );
      }

      Navigator.pop(context); // go back after save
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
            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Expense Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Category Dropdown
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

            // Date Picker
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

            // Image Picker
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
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : _existingImageUrl != null &&
                    _existingImageUrl!.isNotEmpty
                    ? Image.network(_existingImageUrl!,
                    fit: BoxFit.cover)
                    : const Center(
                  child: Text(
                    'Tap to add attachment (optional)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveExpense,
                icon: const Icon(Icons.save),
                label:
                Text(isEditMode ? 'Update Expense' : 'Save Expense'),
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
