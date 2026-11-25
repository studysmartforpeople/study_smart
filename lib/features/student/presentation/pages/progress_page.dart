import 'package:flutter/material.dart';

import '../../../../core/utils/firebase_error_message.dart';
import '../../data/learning_curriculum.dart';
import '../../data/learning_progress_repository.dart';

class ProgressPage extends StatelessWidget {
  final String userId;

  const ProgressPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [ProgressOverview(userId: userId)],
    );
  }
}

class ProgressOverview extends StatelessWidget {
  final String userId;
  final LearningProgressRepository progressRepository;

  const ProgressOverview({
    super.key,
    required this.userId,
    this.progressRepository = const LearningProgressRepository(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalQuizzes = LearningCurriculum.quizzes.length;

    return StreamBuilder<LearningProgress>(
      stream: progressRepository.watch(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SelectableText(
                firebaseErrorMessage(
                  snapshot.error!,
                  action: 'Loading learning progress',
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Progress',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${progress.credits} / $totalQuizzes credits earned',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value:
                          progress.credits.clamp(0, totalQuizzes) /
                          totalQuizzes,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...LearningCurriculum.quizzes.map((quiz) {
              final score = progress.bestScores[quiz.id];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    progress.passedQuizIds.contains(quiz.id)
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: progress.passedQuizIds.contains(quiz.id)
                        ? Colors.green
                        : theme.colorScheme.outline,
                  ),
                  title: Text(quiz.title),
                  subtitle: Text(
                    score == null ? 'Not attempted' : 'Best score: $score%',
                  ),
                  trailing: score == null
                      ? null
                      : SizedBox(
                          width: 52,
                          child: LinearProgressIndicator(value: score / 100),
                        ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
