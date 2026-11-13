import 'package:flutter/material.dart';

class QuizzesPage extends StatelessWidget {
  final List<Map<String, dynamic>> quizzes = const [
    {'title': 'English Quiz 1', 'score': '90%', 'status': 'Ready'},
    {'title': 'Computer Quiz 1', 'score': '85%', 'status': 'Ready'},
    {'title': 'Math Quiz 1', 'score': '92%', 'status': 'Completed'},
    {'title': 'Programming Quiz 1', 'score': '78%', 'status': 'Ready'},
  ];

  const QuizzesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.quiz_rounded, color: Colors.deepPurple),
            title: Text(quiz['title'] as String),
            subtitle: Text('Score: ${quiz['score']}'),
            trailing: Chip(label: Text(quiz['status'] as String)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Starting ${quiz['title']}')),
              );
            },
          ),
        );
      },
    );
  }
}
