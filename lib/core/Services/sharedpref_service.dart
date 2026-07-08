import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedprefService {
  static final ValueNotifier<String> role = ValueNotifier<String>("");

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    role.value = prefs.getString('userRole') ?? "";
  }

  static Future<void> saveRole(String userRole) async {
    final prefs = await SharedPreferences.getInstance();
    role.value = userRole;
    await prefs.setString('userRole', userRole);
  }

  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole') ?? "";
  }

  static Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    role.value = "";
    await prefs.remove('userRole');
  }
}