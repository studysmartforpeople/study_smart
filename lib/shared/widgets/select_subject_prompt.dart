import 'package:flutter/material.dart';

class SelectSubjectPrompt extends StatelessWidget {
  final String message;
  final VoidCallback? onChooseSubjects;

  const SelectSubjectPrompt({
    super.key,
    required this.message,
    this.onChooseSubjects,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 52, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Choose a subject first',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (onChooseSubjects != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onChooseSubjects,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Choose subjects'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
