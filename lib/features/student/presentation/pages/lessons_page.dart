import 'package:flutter/material.dart';

class LessonsPage extends StatelessWidget {
  final List<Map<String, String>> lessons = const [
    {'title': 'Vocabulary Essentials', 'subject': 'English Basic', 'time': '15 mins'},
    {'title': 'Computer Safety', 'subject': 'Computer Basic', 'time': '20 mins'},
    {'title': 'Working with Fractions', 'subject': 'Mathematics Basic', 'time': '18 mins'},
    {'title': 'Variables in Programming', 'subject': 'Programming Basic', 'time': '25 mins'},
  ];

  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.play_arrow_rounded),
            ),
            title: Text(lesson['title']!),
            subtitle: Text('${lesson['subject']} • ${lesson['time']}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${lesson['title']}')),
              );
            },
          ),
        );
      },
    );
  }
}
