import 'package:flutter/material.dart';

import '../../../../core/utils/firebase_error_message.dart';
import '../../data/learning_curriculum.dart';
import '../../data/learning_progress_repository.dart';

class QuizzesPage extends StatelessWidget {
  final String userId;
  final LearningProgressRepository progressRepository;

  const QuizzesPage({
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
                  action: 'Loading quiz progress',
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
          itemCount: LearningCurriculum.quizzes.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.stars_rounded),
                  title: Text('Credits: ${progress.credits}'),
                  subtitle: Text(
                    'Pass a quiz with ${LearningCurriculum.passScore}% to earn '
                    '1 credit and unlock the next lesson.',
                  ),
                ),
              );
            }

            final quiz = LearningCurriculum.quizzes[index - 1];
            final lessonUnlocked = progress.unlockedLessonIds.contains(
              quiz.lessonId,
            );
            final passed = progress.passedQuizIds.contains(quiz.id);
            final bestScore = progress.bestScores[quiz.id];
            final status = !lessonUnlocked
                ? 'Locked'
                : passed
                ? 'Completed'
                : 'Ready';
            final subtitle = bestScore == null
                ? 'Pass with ${LearningCurriculum.passScore}% to earn 1 credit'
                : 'Best score: $bestScore%';

            return Card(
              child: ListTile(
                leading: const Icon(
                  Icons.quiz_rounded,
                  color: Colors.deepPurple,
                ),
                title: Text(quiz.title),
                subtitle: Text(subtitle),
                trailing: Chip(label: Text(status)),
                onTap: lessonUnlocked
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => QuizAttemptScreen(
                            userId: userId,
                            quiz: quiz,
                            progressRepository: progressRepository,
                          ),
                        ),
                      )
                    : () {
                        final lesson = LearningCurriculum.lessonById(
                          quiz.lessonId,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Complete ${lesson.title} to unlock this quiz.',
                            ),
                          ),
                        );
                      },
              ),
            );
          },
        );
      },
    );
  }
}

class QuizAttemptScreen extends StatefulWidget {
  final String userId;
  final QuizDefinition quiz;
  final LearningProgressRepository progressRepository;

  const QuizAttemptScreen({
    super.key,
    required this.userId,
    required this.quiz,
    this.progressRepository = const LearningProgressRepository(),
  });

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  late final List<int?> _selectedOptions = List.filled(
    widget.quiz.questions.length,
    null,
  );
  int _questionIndex = 0;
  bool _isSubmitting = false;
  int? _lastScore;
  QuizSubmissionResult? _result;

  Future<void> _advance() async {
    if (_selectedOptions[_questionIndex] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose an answer to continue.')),
      );
      return;
    }

    if (_questionIndex < widget.quiz.questions.length - 1) {
      setState(() => _questionIndex++);
      return;
    }

    final answers = _selectedOptions.cast<int>();
    final score = calculateQuizScore(widget.quiz, answers);
    setState(() => _isSubmitting = true);

    try {
      final result = await widget.progressRepository.submitQuiz(
        userId: widget.userId,
        quiz: widget.quiz,
        score: score,
      );
      if (!mounted) return;
      setState(() {
        _lastScore = score;
        _result = result;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            firebaseErrorMessage(error, action: 'Saving quiz result'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _retry() {
    setState(() {
      for (var index = 0; index < _selectedOptions.length; index++) {
        _selectedOptions[index] = null;
      }
      _questionIndex = 0;
      _lastScore = null;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: _result == null ? _buildQuestion() : _buildResult(),
    );
  }

  Widget _buildQuestion() {
    final question = widget.quiz.questions[_questionIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${_questionIndex + 1} of ${widget.quiz.questions.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_questionIndex + 1) / widget.quiz.questions.length,
          ),
          const SizedBox(height: 24),
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RadioGroup<int>(
              groupValue: _selectedOptions[_questionIndex],
              onChanged: _isSubmitting
                  ? (_) {}
                  : (value) => setState(
                      () => _selectedOptions[_questionIndex] = value,
                    ),
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) => Card(
                  child: RadioListTile<int>(
                    value: index,
                    title: Text(question.options[index]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _advance,
            child: _isSubmitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _questionIndex == widget.quiz.questions.length - 1
                        ? 'Submit quiz'
                        : 'Next question',
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final score = _lastScore!;
    final passed = score >= LearningCurriculum.passScore;
    final result = _result!;
    final nextLesson = widget.quiz.nextLessonId == null
        ? null
        : LearningCurriculum.lessonById(widget.quiz.nextLessonId!);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.celebration_rounded : Icons.refresh_rounded,
              size: 56,
              color: passed
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Your score: $score%',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              passed
                  ? result.earnedCredit
                        ? 'Passed! You earned 1 credit.'
                        : 'Passed! Your previous credit is kept.'
                  : result.progress.passedQuizIds.contains(widget.quiz.id)
                  ? 'Not passed this time. Your previous pass is kept.'
                  : 'You need ${LearningCurriculum.passScore}% to pass. Try again.',
              textAlign: TextAlign.center,
            ),
            if (passed && nextLesson != null) ...[
              const SizedBox(height: 8),
              Text('${nextLesson.title} is now unlocked.'),
            ],
            const SizedBox(height: 8),
            Text('Total credits: ${result.progress.credits}'),
            const SizedBox(height: 24),
            if (!passed)
              ElevatedButton(onPressed: _retry, child: const Text('Try again'))
            else
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to quizzes'),
              ),
          ],
        ),
      ),
    );
  }
}
