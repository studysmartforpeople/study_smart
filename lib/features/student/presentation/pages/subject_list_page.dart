import 'package:flutter/material.dart';

class SubjectListPage extends StatelessWidget {
  final List<SubjectModel> subjects = [
    SubjectModel('English Basic', 'Build vocabulary, grammar, and reading confidence.', 4, 68),
    SubjectModel('Computer Basic', 'Learn hardware, software, and digital safety basics.', 5, 74),
    SubjectModel('Mathematics Basic', 'Practice arithmetic, fractions, and problem solving.', 3, 82),
    SubjectModel('Programming Basic', 'Start coding with logic, variables, and loops.', 4, 60),
  ];

  SubjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: subjects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(subject.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Chip(label: Text('${subject.lessons} lessons')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(subject.description, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: subject.progress / 100),
                const SizedBox(height: 8),
                Text('${subject.progress}% completed', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SubjectModel {
  final String name;
  final String description;
  final int lessons;
  final int progress;

  const SubjectModel(this.name, this.description, this.lessons, this.progress);
}
