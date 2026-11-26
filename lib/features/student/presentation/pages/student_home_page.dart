import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/firebase_error_message.dart';
import '../../../../shared/widgets/select_subject_prompt.dart';
import '../../data/learning_curriculum.dart';
import '../../data/learning_language.dart';
import '../../data/learning_progress_repository.dart';
import 'lessons_page.dart';

class StudentHomePage extends StatelessWidget {
  final User user;
  final LearningProgressRepository progressRepository;
  final LearningLanguage language;
  final VoidCallback? onChooseSubjects;

  const StudentHomePage({
    super.key,
    required this.user,
    this.progressRepository = const LearningProgressRepository(),
    this.language = LearningLanguage.english,
    this.onChooseSubjects,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final suppliedName = user.displayName?.trim();
    final displayName = suppliedName == null || suppliedName.isEmpty
        ? 'Student'
        : suppliedName;

    return StreamBuilder<LearningProgress>(
      stream: progressRepository.watch(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                firebaseErrorMessage(
                  snapshot.error!,
                  action: 'Loading your learning overview',
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
        final selectedLessons = LearningCurriculum.lessons
            .where(
              (lesson) =>
                  progress.selectedSubjectIds.contains(lesson.subjectId),
            )
            .toList();
        final selectedQuizzes = LearningCurriculum.quizzes.where((quiz) {
          final lesson = LearningCurriculum.lessonById(quiz.lessonId);
          return progress.selectedSubjectIds.contains(lesson.subjectId);
        }).toList();
        final completedLessons = selectedLessons.where((lesson) {
          final quiz = LearningCurriculum.quizForLesson(lesson.id);
          return quiz != null && progress.passedQuizIds.contains(quiz.id);
        }).length;
        final progressPercent = selectedLessons.isEmpty
            ? 0
            : (completedLessons * 100 / selectedLessons.length).round();
        final scoredQuizzes = selectedQuizzes
            .where((quiz) => progress.bestScores.containsKey(quiz.id))
            .toList();
        final averageScore = scoredQuizzes.isEmpty
            ? 0
            : (scoredQuizzes
                          .map((quiz) => progress.bestScores[quiz.id]!)
                          .reduce((first, second) => first + second) /
                      scoredQuizzes.length)
                  .round();
        final nextLessons = selectedLessons.where((lesson) {
          final quiz = LearningCurriculum.quizForLesson(lesson.id);
          return progress.unlockedLessonIds.contains(lesson.id) &&
              (quiz == null || !progress.passedQuizIds.contains(quiz.id));
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      displayName.substring(0, 1).toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _LearningJourneyCard(
                progressPercent: progressPercent,
                completedLessons: completedLessons,
                totalLessons: selectedLessons.length,
              ),
              const SizedBox(height: 24),
              Text(
                'Your overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.65,
                children: [
                  _HomeMetricCard(
                    title: 'Subjects',
                    value: '${progress.selectedSubjectIds.length}',
                    icon: Icons.menu_book_rounded,
                    color: scheme.primary,
                  ),
                  _HomeMetricCard(
                    title: 'Lessons completed',
                    value: '$completedLessons',
                    icon: Icons.task_alt_rounded,
                    color: scheme.tertiary,
                  ),
                  _HomeMetricCard(
                    title: 'Learning progress',
                    value: '$progressPercent%',
                    icon: Icons.trending_up_rounded,
                    color: scheme.secondary,
                  ),
                  _HomeMetricCard(
                    title: 'Average quiz score',
                    value: '$averageScore%',
                    icon: Icons.emoji_events_rounded,
                    color: scheme.tertiary,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Continue learning',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lessons from the subjects you selected.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              if (progress.selectedSubjectIds.isEmpty)
                SelectSubjectPrompt(
                  message: 'Choose a subject to see your first lesson here.',
                  onChooseSubjects: onChooseSubjects,
                )
              else if (nextLessons.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'You are all caught up in your selected subjects.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...nextLessons.map(
                  (lesson) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          lesson.titleFor(language),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(lesson.subjectFor(language)),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => LessonDetailScreen(
                              userId: user.uid,
                              lesson: lesson,
                              progressRepository: progressRepository,
                              language: language,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LearningJourneyCard extends StatelessWidget {
  final int progressPercent;
  final int completedLessons;
  final int totalLessons;

  const _LearningJourneyCard({
    required this.progressPercent,
    required this.completedLessons,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasLessons = totalLessons > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR LEARNING JOURNEY',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.82),
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  hasLessons
                      ? 'Keep building your skills'
                      : 'Start your learning journey',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  hasLessons
                      ? '$completedLessons of $totalLessons lessons completed'
                      : 'Choose a subject to see your progress here.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progressPercent / 100,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Text(
                  '$progressPercent%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _HomeMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: color, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
