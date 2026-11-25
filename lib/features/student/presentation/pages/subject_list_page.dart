import 'package:flutter/material.dart';

class SubjectListPage extends StatelessWidget {
  const SubjectListPage({super.key});

  static const subjects = [
    SubjectModel(
      name: 'English Basic',
      description: 'Build vocabulary, grammar, and reading confidence.',
      lessons: 4,
      progress: 68,
      icon: Icons.translate_rounded,
      color: Colors.indigo,
    ),
    SubjectModel(
      name: 'Computer Basic',
      description: 'Learn hardware, software, and digital safety basics.',
      lessons: 5,
      progress: 74,
      icon: Icons.computer_rounded,
      color: Colors.teal,
    ),
    SubjectModel(
      name: 'Mathematics Basic',
      description: 'Practice arithmetic, fractions, and problem solving.',
      lessons: 3,
      progress: 82,
      icon: Icons.calculate_rounded,
      color: Colors.deepOrange,
    ),
    SubjectModel(
      name: 'Programming Basic',
      description: 'Start coding with logic, variables, and loops.',
      lessons: 4,
      progress: 60,
      icon: Icons.code_rounded,
      color: Colors.deepPurple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lessonCount = subjects.fold<int>(
      0,
      (total, subject) => total + subject.lessons,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text(
          'Explore subjects',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose a learning path and grow your skills step by step.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                color: scheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${subjects.length} learning paths · $lessonCount lessons to explore',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 620 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjects.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 1.65 : 1.32,
              ),
              itemBuilder: (context, index) =>
                  _SubjectCard(subject: subjects[index]),
            );
          },
        ),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;

  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = subject.progress.clamp(0, 100) / 100;

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: subject.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(subject.icon, color: subject.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subject.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: scheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                subject.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${subject.lessons} lessons',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const Spacer(),
                Text(
                  '${subject.progress}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: subject.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                color: subject.color,
                backgroundColor: subject.color.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectModel {
  final String name;
  final String description;
  final int lessons;
  final int progress;
  final IconData icon;
  final Color color;

  const SubjectModel({
    required this.name,
    required this.description,
    required this.lessons,
    required this.progress,
    required this.icon,
    required this.color,
  });
}
