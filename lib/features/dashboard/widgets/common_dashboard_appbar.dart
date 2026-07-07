import 'package:flutter/material.dart';
import '../../../services/theme_service.dart';
import '../../settings/view/settings_screen.dart';
import '../../../core/utils/logout_util.dart';

PreferredSizeWidget commonDashboardAppBar({
  required BuildContext context,
  required String title,
}) {
  final isDark = ThemeService.isDark.value;
  final accent = const Color(0xFF00897B);

  return AppBar(
    title: Text(
      'Spendly',
      style: TextStyle(
        color: isDark ? Colors.white : Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    ),
    centerTitle: false,
    backgroundColor: isDark ? Colors.black : accent,
    actions: [
      // 🌙 Dark mode toggle
      ValueListenableBuilder<bool>(
        valueListenable: ThemeService.isDark,
        builder: (context, val, _) {
          return IconButton(
            icon: Icon(val ? Icons.wb_sunny : Icons.dark_mode),
            onPressed: () async => await ThemeService.toggle(),
          );
        },
      ),

      // ⚙ Settings
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),

      // 🚪 Logout
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () async => await appLogout(context),
      ),
    ],
  );
}
