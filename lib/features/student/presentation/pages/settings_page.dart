import 'package:flutter/material.dart';

import '../../../../core/services/app_theme_controller.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsPage({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final themeController = AppThemeScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Email notifications'),
          subtitle: const Text('Receive updates on lessons and quizzes.'),
          value: true,
          onChanged: (_) {},
        ),
        SwitchListTile(
          title: const Text('Dark mode'),
          subtitle: const Text('Focus better at night.'),
          value: themeController.isDarkMode,
          onChanged: (enabled) async {
            final saved = await themeController.setDarkMode(enabled);
            if (!saved && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not save dark mode setting.')),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.language_rounded),
          title: const Text('Preferred language'),
          subtitle: const Text('English'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Language preference saved successfully.')),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: onLogout,
        ),
      ],
    );
  }
}
