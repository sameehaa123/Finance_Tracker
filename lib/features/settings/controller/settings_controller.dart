import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController {
  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    double? monthlyLimit = prefs.getDouble('monthlyLimit');

    Map<String, double> categoryLimits = {};

    final raw = prefs.getString('categoryLimits');

    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      categoryLimits = decoded.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    }

    return {
      'monthlyLimit': monthlyLimit,
      'categoryLimits': categoryLimits,
    };
  }
  Future<void> saveMonthlyLimit(String value) async {

  final prefs = await SharedPreferences.getInstance();

  final limit = double.tryParse(value.trim()) ?? 0.0;

  await prefs.setDouble('monthlyLimit', limit);

}
Future<Map<String, double>> saveCategoryLimit({
  required String category,
  required String amount,
  required Map<String, double> categoryLimits,
}) async {

  final prefs = await SharedPreferences.getInstance();

  final limit = double.tryParse(amount.trim()) ?? 0.0;

  categoryLimits[category] = limit;

  final encoded = jsonEncode(categoryLimits);

  await prefs.setString(
    'categoryLimits',
    encoded,
  );

  return categoryLimits;
}
Future<Map<String, double>> removeCategoryLimit({
  required String category,
  required Map<String, double> categoryLimits,
}) async {

  final prefs = await SharedPreferences.getInstance();

  categoryLimits.remove(category);

  final encoded = jsonEncode(categoryLimits);

  await prefs.setString(
    'categoryLimits',
    encoded,
  );

  return categoryLimits;

}
}