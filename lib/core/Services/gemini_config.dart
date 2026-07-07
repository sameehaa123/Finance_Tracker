import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class GeminiConfig {
  static String apiKey = "";

  static Future<void> load() async {
    final jsonString = await rootBundle.loadString("assets/config.json");
    final Map<String, dynamic> config = jsonDecode(jsonString);

    apiKey = config["gemini_api_key"] ?? "";

    if (apiKey.isEmpty) {
      throw Exception("Gemini Error: API key missing in config.json");
    }
  }
}
