import 'package:flutter/material.dart';

import '../../../../core/utils/firebase_error_message.dart';
import '../../data/learning_curriculum.dart';
import '../../data/learning_progress_repository.dart';

class LessonsPage extends StatelessWidget {
  final String userId;
  final LearningProgressRepository progressRepository;

  const LessonsPage({
    super.key,
    required this.userId,
    this.progressRepository = const LearningProgressRepository(),
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
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: LearningCurriculum.lessons.length,
          itemBuilder: (context, index) {
            final lesson = LearningCurriculum.lessons[index];
            final unlocked = progress.unlockedLessonIds.contains(lesson.id);
            final requiredQuiz = LearningCurriculum.quizUnlockingLesson(
              lesson.id,
            );
            final subtitle = unlocked
                ? '${lesson.subject} • ${lesson.level} • ${lesson.duration}'
                : 'Pass ${requiredQuiz?.title ?? 'the previous quiz'} '
                      'with ${LearningCurriculum.passScore}% to unlock';

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    unlocked ? Icons.play_arrow_rounded : Icons.lock_outline,
                  ),
                ),
                title: Text(lesson.title),
                subtitle: Text(subtitle),
                trailing: Icon(
                  unlocked ? Icons.chevron_right_rounded : Icons.lock_outline,
                ),
                onTap: () {
                  if (unlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening ${lesson.title}')),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('$subtitle.')));
                },
              ),
            );
          },
        );
      },
    );
  }
}
