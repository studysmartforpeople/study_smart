import 'package:flutter/material.dart';

import '../../../../core/utils/firebase_error_message.dart';
import '../../data/learning_curriculum.dart';
import '../../data/learning_progress_repository.dart';

class SubjectListPage extends StatefulWidget {
  final String userId;
  final LearningProgressRepository progressRepository;

  const SubjectListPage({
    super.key,
    required this.userId,
    this.progressRepository = const LearningProgressRepository(),
  });

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  String? _savingSubjectId;

  Future<void> _toggleSubject(
    LearningProgress progress,
    LearningSubject subject,
  ) async {
    setState(() => _savingSubjectId = subject.id);
    try {
      await widget.progressRepository.setSubjectSelected(
        userId: widget.userId,
        subjectId: subject.id,
        selected: !progress.selectedSubjectIds.contains(subject.id),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            firebaseErrorMessage(error, action: 'Updating selected subjects'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingSubjectId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return StreamBuilder<LearningProgress>(
      stream: widget.progressRepository.watch(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                firebaseErrorMessage(
                  snapshot.error!,
                  action: 'Loading selected subjects',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final progress = snapshot.data!;
        final lessonCount = LearningCurriculum.lessons.length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              'Choose your subjects',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select one or more learning paths. Your lessons and quizzes '
              'will follow your choices.',
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
                      '${progress.selectedSubjectIds.length} selected · '
                      '$lessonCount lessons available',
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
                  itemCount: LearningCurriculum.subjects.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: columns == 1 ? 1.32 : 1.12,
                  ),
                  itemBuilder: (context, index) {
                    final subject = LearningCurriculum.subjects[index];
                    return _SubjectCard(
                      subject: subject,
                      progress: progress,
                      isSaving: _savingSubjectId == subject.id,
                      onTap: () => _toggleSubject(progress, subject),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final LearningSubject subject;
  final LearningProgress progress;
  final bool isSaving;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.progress,
    required this.isSaving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _subjectColor(subject.id);
    final icon = _subjectIcon(subject.id);
    final lessons = LearningCurriculum.lessonsForSubject(subject.id);
    final completedLessons = lessons.where((lesson) {
      final quiz = LearningCurriculum.quizForLesson(lesson.id);
      return quiz != null && progress.passedQuizIds.contains(quiz.id);
    }).length;
    final progressValue = lessons.isEmpty
        ? 0.0
        : completedLessons / lessons.length;
    final isSelected = progress.selectedSubjectIds.contains(subject.id);

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isSelected ? color : scheme.outlineVariant,
          width: isSelected ? 1.5 : 0.7,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isSaving ? null : onTap,
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
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subject.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: color)
                  else
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: scheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subject.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${lessons.length} lessons',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progressValue * 100).round()}% complete',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 7,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.12),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: isSaving ? null : onTap,
                  icon: isSaving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isSelected
                              ? Icons.remove_circle_outline_rounded
                              : Icons.add_rounded,
                        ),
                  label: Text(isSelected ? 'Remove subject' : 'Start learning'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _subjectColor(String subjectId) => switch (subjectId) {
  LearningSubjectIds.englishBasic => Colors.indigo,
  LearningSubjectIds.computerBasic => Colors.teal,
  LearningSubjectIds.mathematicsBasic => Colors.deepOrange,
  LearningSubjectIds.programmingBasic => Colors.deepPurple,
  _ => Colors.blueGrey,
};

IconData _subjectIcon(String subjectId) => switch (subjectId) {
  LearningSubjectIds.englishBasic => Icons.translate_rounded,
  LearningSubjectIds.computerBasic => Icons.computer_rounded,
  LearningSubjectIds.mathematicsBasic => Icons.calculate_rounded,
  LearningSubjectIds.programmingBasic => Icons.code_rounded,
  _ => Icons.menu_book_rounded,
};
