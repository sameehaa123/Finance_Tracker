// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class GeminiService {
//   // 🔑 Put your real API key here
//   static const String _apiKey = "AIzaSyBm6A7KzatSqaxAp2YGMOI5uPR4YuWpDfA";
//
//   // ✅ Use a currently supported model
//   // (Gemini 1.0 & 1.5 are retired; use 2.x instead)
//   static const String _model = "gemini-2.5-flash-lite";
//
//   static Future<String> getSuggestion(String prompt) async {
//     final url = Uri.parse(
//       // ✅ Note: v1beta + new model name
//       "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey",
//     );
//
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         "contents": [
//           {
//             "parts": [
//               {"text": prompt}
//             ]
//           }
//         ]
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return data["candidates"][0]["content"]["parts"][0]["text"] ?? "";
//     } else {
//       // You’ll see this in your error text on the AI screen
//       throw Exception("Gemini error: ${response.statusCode} ${response.body}");
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'gemini_config.dart';

class GeminiService {
  static const String _model = "gemini-2.5-flash-lite";

  static Future<String> getSuggestion(String prompt) async {
    final apiKey = GeminiConfig.apiKey; // ✅ FIXED

    if (apiKey.isEmpty) {
      throw Exception("Gemini Error: API key is missing or not loaded.");
    }

    final baseUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent";

    // ✅ Your required code — replaced URL with queryParameters
    final url = Uri.parse(baseUrl).replace(queryParameters: {"key": apiKey});

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"] ?? "";
    } else {
      throw Exception("Gemini Error: ${response.statusCode} ${response.body}");
    }
  }
}
