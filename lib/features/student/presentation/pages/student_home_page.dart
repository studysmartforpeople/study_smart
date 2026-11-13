import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/stat_card.dart';

class StudentHomePage extends StatelessWidget {
  final User user;

  const StudentHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.indigo,
                child: Text(
                  (user.displayName ?? 'S').substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back,', style: TextStyle(color: Colors.black54)),
                    Text(
                      user.displayName ?? 'Student',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Your learning streak is growing!', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text('4-day streak', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text('Keep going to unlock your next milestone.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: const [
              StatCard(title: 'Total Subjects', value: '4', color: Colors.indigo),
              StatCard(title: 'Completed Lessons', value: '12', color: Colors.green),
              StatCard(title: 'Learning Progress', value: '72%', color: Colors.orange),
              StatCard(title: 'Quiz Scores', value: '88%', color: Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recommended lessons', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._recommendedLessons.map(
            (lesson) => Card(
              child: ListTile(
                leading: const Icon(Icons.play_circle_fill_rounded, color: Colors.indigo),
                title: Text(lesson['title'] as String),
                subtitle: Text(lesson['subject'] as String),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<Map<String, String>> _recommendedLessons = [
  {'title': 'English Basics - Vocabulary Practice', 'subject': 'English Basic'},
  {'title': 'Computer Basics - Internet Safety', 'subject': 'Computer Basic'},
  {'title': 'Mathematics Basics - Fractions Review', 'subject': 'Mathematics Basic'},
  {'title': 'Programming Basics - Variables and Data Types', 'subject': 'Programming Basic'},
];
