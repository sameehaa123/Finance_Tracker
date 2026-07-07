import 'package:flutter/material.dart';
import '../controller/ai_controller.dart';

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
      AIController aiController = AIController();
      final prompt = aiController.buildPromptFromData(
  widget.total,
  widget.categoryTotals,
);
    final lines = await aiController.getSuggestions(prompt);

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
