import 'package:flutter/material.dart';

import '../../../../core/services/app_theme_controller.dart';
import '../../../../core/utils/firebase_error_message.dart';
import '../../data/learning_language.dart';
import '../../data/preferred_language_repository.dart';

class SettingsPage extends StatelessWidget {
  final String userId;
  final VoidCallback onLogout;
  final PreferredLanguageRepository languageRepository;

  const SettingsPage({
    super.key,
    required this.userId,
    required this.onLogout,
    this.languageRepository = const PreferredLanguageRepository(),
  });

  Future<void> _selectLanguage(
    BuildContext context,
    LearningLanguage currentLanguage,
  ) async {
    final selectedLanguage = await showDialog<LearningLanguage>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferred language'),
        content: RadioGroup<LearningLanguage>(
          groupValue: currentLanguage,
          onChanged: (language) => Navigator.of(context).pop(language),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<LearningLanguage>(
                value: LearningLanguage.english,
                title: Text('English'),
              ),
              RadioListTile<LearningLanguage>(
                value: LearningLanguage.khmer,
                title: Text('ខ្មែរ'),
              ),
            ],
          ),
        ),
      ),
    );
    if (selectedLanguage == null || selectedLanguage == currentLanguage) return;

    try {
      await languageRepository.setLanguage(
        userId: userId,
        language: selectedLanguage,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Learning language saved: '
            '${selectedLanguage.isKhmer ? 'ខ្មែរ' : 'English'}.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            firebaseErrorMessage(error, action: 'Saving preferred language'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = AppThemeScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Dark mode'),
          subtitle: const Text('Focus better at night.'),
          value: themeController.isDarkMode,
          onChanged: (enabled) async {
            final saved = await themeController.setDarkMode(enabled);
            if (!saved && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not save dark mode setting.'),
                ),
              );
            }
          },
        ),
        StreamBuilder<LearningLanguage>(
          stream: languageRepository.watch(userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text('Preferred language'),
                subtitle: Text(
                  firebaseErrorMessage(
                    snapshot.error!,
                    action: 'Loading preferred language',
                  ),
                ),
              );
            }
            final language = snapshot.data;
            return ListTile(
              leading: const Icon(Icons.language_rounded),
              title: const Text('Preferred language'),
              subtitle: Text(
                language == null
                    ? 'Loading…'
                    : language.isKhmer
                    ? 'ខ្មែរ'
                    : 'English',
              ),
              trailing: language == null
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded),
              onTap: language == null
                  ? null
                  : () => _selectLanguage(context, language),
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
