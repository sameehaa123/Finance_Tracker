import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class AiSuggestionsScreen extends StatefulWidget {
  final double total;
  final Map<String, double> categoryTotals;

  const AiSuggestionsScreen({
    Key? key,
    required this.total,
    required this.categoryTotals,
  }) : super(key: key);

  @override
  State<AiSuggestionsScreen> createState() => _AiSuggestionsScreenState();
}

class _AiSuggestionsScreenState extends State<AiSuggestionsScreen> {
  bool _isLoading = true;
  String? _error;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _suggestions = [];
    });

    try {
      final prompt = _buildPromptFromData();
      final rawText = await GeminiService.getSuggestion(prompt);

      // Split into bullet-like lines
      final lines = rawText
          .split(RegExp(r'\n|\r'))
          .map((e) => e.replaceAll(RegExp(r'^[\s\-\•0-9\.\)]*'), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();

      setState(() {
        _suggestions = lines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load suggestions: $e";
        _isLoading = false;
      });
    }
  }

  String _buildPromptFromData() {
    final buffer = StringBuffer();
    buffer.writeln(
        "You are a friendly financial advisor for a personal finance app called Spendly.");
    buffer.writeln(
        "Based on the user's recent spending, give 5 short, practical suggestions to manage money better.");
    buffer.writeln(
        "Make each suggestion simple, specific, and no more than 20 words.");
    buffer.writeln("");

    buffer.writeln("Total spent: ${widget.total.toStringAsFixed(2)} AED.");

    if (widget.categoryTotals.isNotEmpty) {
      buffer.writeln("Breakdown by category (AED):");
      widget.categoryTotals.forEach((cat, value) {
        buffer.writeln("- $cat: ${value.toStringAsFixed(2)}");
      });
    }

    buffer.writeln(
        "Focus on helping the user save money, control overspending, and build better habits.");
    buffer.writeln("Return ONLY the suggestions as a bullet list.");

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFF00897B);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Suggestions"),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
        foregroundColor: isDark ? Colors.white : accent,
        elevation: 0,
      ),
      body: Container(
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.red[200] : Colors.red[700],
                fontSize: 14,
              ),
            ),
          ),
        )
            : _suggestions.isEmpty
            ? const Center(
          child: Text("No suggestions available yet."),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 16),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            top: 4, right: 8),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _suggestions[index],
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
