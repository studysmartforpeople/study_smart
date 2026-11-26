import 'package:flutter/material.dart';

import '../../../../core/utils/firebase_error_message.dart';
import '../../../../shared/widgets/select_subject_prompt.dart';
import '../../data/learning_curriculum.dart';
import '../../data/learning_language.dart';
import '../../data/learning_progress_repository.dart';
import 'quizzes_page.dart';

class LessonsPage extends StatelessWidget {
  final String userId;
  final LearningProgressRepository progressRepository;
  final LearningLanguage language;
  final VoidCallback? onChooseSubjects;

  const LessonsPage({
    super.key,
    required this.userId,
    this.progressRepository = const LearningProgressRepository(),
    this.language = LearningLanguage.english,
    this.onChooseSubjects,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LearningProgress>(
      stream: progressRepository.watch(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                firebaseErrorMessage(
                  snapshot.error!,
                  action: 'Loading lesson progress',
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
        if (progress.selectedSubjectIds.isEmpty) {
          return SelectSubjectPrompt(
            message:
                'Select a subject to see its lessons and learning content.',
            onChooseSubjects: onChooseSubjects,
          );
        }

        final lessons = LearningCurriculum.lessons
            .where(
              (lesson) =>
                  progress.selectedSubjectIds.contains(lesson.subjectId),
            )
            .toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Your lessons',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Open an unlocked lesson to study, then take its quiz.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            for (final lesson in lessons)
              _LessonCard(
                lesson: lesson,
                unlocked: progress.unlockedLessonIds.contains(lesson.id),
                passed: progress.passedQuizIds.contains(
                  LearningCurriculum.quizForLesson(lesson.id)?.id,
                ),
                userId: userId,
                progressRepository: progressRepository,
                language: language,
              ),
          ],
        );
      },
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonDefinition lesson;
  final bool unlocked;
  final bool passed;
  final String userId;
  final LearningProgressRepository progressRepository;
  final LearningLanguage language;

  const _LessonCard({
    required this.lesson,
    required this.unlocked,
    required this.passed,
    required this.userId,
    required this.progressRepository,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final requiredQuiz = LearningCurriculum.quizUnlockingLesson(lesson.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: unlocked
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          child: Icon(
            unlocked ? Icons.menu_book_rounded : Icons.lock_outline_rounded,
            color: unlocked
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          lesson.titleFor(language),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${lesson.subjectFor(language)} · ${lesson.levelFor(language)} · '
            '${lesson.durationFor(language)}'
            '${passed ? ' · Quiz passed' : ''}',
          ),
        ),
        trailing: Icon(
          unlocked ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
          color: scheme.onSurfaceVariant,
        ),
        onTap: unlocked
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LessonDetailScreen(
                    userId: userId,
                    lesson: lesson,
                    progressRepository: progressRepository,
                    language: language,
                  ),
                ),
              )
            : () {
                final message = requiredQuiz == null
                    ? 'This lesson is locked.'
                    : 'Pass ${LearningCurriculum.quizForLanguage(requiredQuiz, language).title} with '
                          '${LearningCurriculum.passScore}% to unlock it.';
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(message)));
              },
      ),
    );
  }
}

class LessonDetailScreen extends StatelessWidget {
  final String userId;
  final LessonDefinition lesson;
  final LearningProgressRepository progressRepository;
  final LearningLanguage language;

  const LessonDetailScreen({
    super.key,
    required this.userId,
    required this.lesson,
    this.progressRepository = const LearningProgressRepository(),
    this.language = LearningLanguage.english,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final quiz = LearningCurriculum.quizForLesson(lesson.id);
    final localizedQuiz = quiz == null
        ? null
        : LearningCurriculum.quizForLanguage(quiz, language);

    return Scaffold(
      appBar: AppBar(title: Text(lesson.titleFor(language))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            lesson.subjectFor(language),
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.summaryFor(language),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.signal_cellular_alt_rounded, size: 18),
                label: Text(lesson.levelFor(language)),
              ),
              Chip(
                avatar: const Icon(Icons.schedule_rounded, size: 18),
                label: Text(lesson.durationFor(language)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (lesson.sections.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.isKhmer ? 'គោលគំនិតសំខាន់ៗ' : 'Key concepts',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lesson.summaryFor(language),
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (lesson.concepts.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      for (final concept in lesson.concepts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${concept.term}: '
                                  '${lesson.conceptMeaningFor(concept, language)}',
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          if (localizedQuiz != null) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => QuizAttemptScreen(
                    userId: userId,
                    quiz: localizedQuiz,
                    progressRepository: progressRepository,
                    language: language,
                  ),
                ),
              ),
              icon: const Icon(Icons.quiz_rounded),
              label: Text(
                language.isKhmer
                    ? 'ចាប់ផ្តើមតេស្ត'
                    : 'Take ${localizedQuiz.title}',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
