import '../../../services/gemini_service.dart';

class AIController{
  String buildPromptFromData(
      double total,
      Map<String, double> categoryTotals,
      ) {
    final buffer = StringBuffer();
    buffer.writeln(
        "You are a friendly financial advisor for a personal finance app called Spendly.");
    buffer.writeln(
        "Based on the user's recent spending, give 5 short, practical suggestions to manage money better.");
    buffer.writeln(
        "Make each suggestion simple, specific, and no more than 20 words.");
    buffer.writeln("");

    buffer.writeln("Total spent: ${total.toStringAsFixed(2)} AED.");

    if (categoryTotals.isNotEmpty) {
      buffer.writeln("Breakdown by category (AED):");
      categoryTotals.forEach((cat, value) {
        buffer.writeln("- $cat: ${value.toStringAsFixed(2)}");
      });
    }

    buffer.writeln(
        "Focus on helping the user save money, control overspending, and build better habits.");
    buffer.writeln("Return ONLY the suggestions as a bullet list.");

    return buffer.toString();
  }
  Future<List<String>> getSuggestions(String prompt) async {

  final rawText = await GeminiService.getSuggestion(prompt);

  final lines = rawText
      .split(RegExp(r'\n|\r'))
      .map((e) => e.replaceAll(RegExp(r'^[\s\-\•0-9\.\)]*'), '').trim())
      .where((e) => e.isNotEmpty)
      .toList();

  return lines;

}
}