import 'package:flutter/material.dart';

import '../../../../core/utils/firebase_error_message.dart';
import '../../../../shared/widgets/select_subject_prompt.dart';
import '../../data/learning_curriculum.dart';
import '../../data/learning_language.dart';
import '../../data/learning_progress_repository.dart';

class QuizzesPage extends StatelessWidget {
  final String userId;
  final LearningProgressRepository progressRepository;
  final LearningLanguage language;
  final VoidCallback? onChooseSubjects;

  const QuizzesPage({
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
        if (progress.selectedSubjectIds.isEmpty) {
          return SelectSubjectPrompt(
            message: 'Choose a subject to see its lesson quizzes and results.',
            onChooseSubjects: onChooseSubjects,
          );
        }

        final quizzes = LearningCurriculum.quizzes.where((quiz) {
          final lesson = LearningCurriculum.lessonById(quiz.lessonId);
          return progress.selectedSubjectIds.contains(lesson.subjectId);
        }).toList();
        final totalQuizzes = LearningCurriculum.quizzes.length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              'Your quizzes',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Check your knowledge and earn credits as you learn.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface
                                .withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${progress.credits} credits earned',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$totalQuizzes quizzes in your learning library',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (progress.credits / totalQuizzes)
                            .clamp(0.0, 1.0)
                            .toDouble(),
                        minHeight: 7,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withValues(alpha: 0.12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Pass a quiz with ${LearningCurriculum.passScore}% to '
                      'earn a credit and unlock the next lesson.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (final quiz in quizzes)
              _QuizCard(
                quiz: quiz,
                progress: progress,
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

class _QuizCard extends StatelessWidget {
  final QuizDefinition quiz;
  final LearningProgress progress;
  final String userId;
  final LearningProgressRepository progressRepository;
  final LearningLanguage language;

  const _QuizCard({
    required this.quiz,
    required this.progress,
    required this.userId,
    required this.progressRepository,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final lesson = LearningCurriculum.lessonById(quiz.lessonId);
    final localizedQuiz = LearningCurriculum.quizForLanguage(quiz, language);
    final lessonUnlocked = progress.unlockedLessonIds.contains(quiz.lessonId);
    final passed = progress.passedQuizIds.contains(quiz.id);
    final bestScore = progress.bestScores[quiz.id];
    final status = !lessonUnlocked
        ? language.isKhmer
              ? 'ជាប់សោ'
              : 'Locked'
        : passed
        ? language.isKhmer
              ? 'បានបញ្ចប់'
              : 'Completed'
        : language.isKhmer
        ? 'រួចរាល់'
        : 'Ready';
    final subtitle = bestScore == null
        ? '${lesson.subjectFor(language)} · ${lesson.titleFor(language)} · '
              '${language.isKhmer ? 'ត្រូវបានពិន្ទុ' : 'Pass with'} '
              '${LearningCurriculum.passScore}% '
              '${language.isKhmer ? 'ដើម្បីទទួលបាន 1 credit' : 'to earn 1 credit'}'
        : '${lesson.subjectFor(language)} · ${lesson.titleFor(language)} · '
              '${language.isKhmer ? 'ពិន្ទុល្អបំផុត' : 'Best score'}: $bestScore%';

    final scheme = Theme.of(context).colorScheme;
    final statusColor = !lessonUnlocked
        ? scheme.onSurfaceVariant
        : passed
        ? Colors.green.shade700
        : scheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: scheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            passed
                ? Icons.check_rounded
                : lessonUnlocked
                ? Icons.quiz_rounded
                : Icons.lock_outline_rounded,
            color: statusColor,
          ),
        ),
        title: Text(
          localizedQuiz.title,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.25)),
          ),
          child: Text(
            status,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
          ),
        ),
        onTap: lessonUnlocked
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => QuizAttemptScreen(
                    userId: userId,
                    quiz: localizedQuiz,
                    progressRepository: progressRepository,
                    language: language,
                  ),
                ),
              )
            : () {
                final requiredQuiz = LearningCurriculum.quizUnlockingLesson(
                  lesson.id,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      requiredQuiz == null
                          ? 'Choose ${lesson.subject} to unlock this quiz.'
                          : 'Pass ${requiredQuiz.title} with '
                                '${LearningCurriculum.passScore}% to unlock '
                                '${lesson.title}.',
                    ),
                  ),
                );
              },
      ),
    );
  }
}

class QuizAttemptScreen extends StatefulWidget {
  final String userId;
  final QuizDefinition quiz;
  final LearningProgressRepository progressRepository;
  final LearningLanguage language;

  const QuizAttemptScreen({
    super.key,
    required this.userId,
    required this.quiz,
    this.progressRepository = const LearningProgressRepository(),
    this.language = LearningLanguage.english,
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
                        ? widget.language.isKhmer
                              ? 'ជាប់ហើយ! អ្នកទទួលបាន 1 credit។'
                              : 'Passed! You earned 1 credit.'
                        : widget.language.isKhmer
                        ? 'ជាប់ហើយ! Credit ពីមុននៅដដែល។'
                        : 'Passed! Your previous credit is kept.'
                  : result.progress.passedQuizIds.contains(widget.quiz.id)
                  ? widget.language.isKhmer
                        ? 'មិនជាប់លើកនេះទេ ប៉ុន្តែលទ្ធផលជាប់ពីមុននៅដដែល។'
                        : 'Not passed this time. Your previous pass is kept.'
                  : widget.language.isKhmer
                  ? 'អ្នកត្រូវការពិន្ទុ ${LearningCurriculum.passScore}% ដើម្បីជាប់។ សូមសាកម្ដងទៀត។'
                  : 'You need ${LearningCurriculum.passScore}% to pass. Try again.',
              textAlign: TextAlign.center,
            ),
            if (passed && nextLesson != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.language.isKhmer
                    ? 'បានដោះសោ ${nextLesson.titleFor(widget.language)} ហើយ។'
                    : '${nextLesson.title} is now unlocked.',
              ),
            ],
            const SizedBox(height: 8),
            Text('Total credits: ${result.progress.credits}'),
            const SizedBox(height: 24),
            if (!passed)
              ElevatedButton(onPressed: _retry, child: const Text('Try again'))
            else
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
          ],
        ),
      ),
    );
  }
}
