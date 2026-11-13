import 'package:flutter/material.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final progresses = [
      {'label': 'English', 'value': 0.8},
      {'label': 'Computer', 'value': 0.72},
      {'label': 'Mathematics', 'value': 0.9},
      {'label': 'Programming', 'value': 0.64},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Progress Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...progresses.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item['label']} • ${(item['value'] as double) * 100 ~/ 1}%'),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: item['value'] as double),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
