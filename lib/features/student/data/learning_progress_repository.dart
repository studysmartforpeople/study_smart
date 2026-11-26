import 'package:cloud_firestore/cloud_firestore.dart';

import 'learning_curriculum.dart';

class LearningProgress {
  final Map<String, int> bestScores;
  final Set<String> passedQuizIds;
  final Set<String> unlockedLessonIds;
  final Set<String> selectedSubjectIds;
  final String? lastQuizId;

  const LearningProgress({
    required this.bestScores,
    required this.passedQuizIds,
    required this.unlockedLessonIds,
    required this.selectedSubjectIds,
    this.lastQuizId,
  });

  factory LearningProgress.initial() => const LearningProgress(
    bestScores: {},
    passedQuizIds: {},
    unlockedLessonIds: {},
    selectedSubjectIds: {},
    lastQuizId: null,
  );

  factory LearningProgress.fromData(Map<String, dynamic>? data) {
    if (data == null) return LearningProgress.initial();

    final rawScores = data['bestScores'];
    final rawPassedIds = data['passedQuizIds'];
    final rawUnlockedIds = data['unlockedLessonIds'];
    final rawSelectedSubjectIds = data['selectedSubjectIds'];
    final rawLastQuizId = data['lastQuizId'];
    final rawCredits = data['credits'];

    if (rawScores is! Map ||
        rawPassedIds is! List ||
        rawUnlockedIds is! List ||
        (data.containsKey('selectedSubjectIds') &&
            rawSelectedSubjectIds is! List) ||
        (rawLastQuizId != null && rawLastQuizId is! String) ||
        rawCredits is! int) {
      throw const FormatException(
        'Learning progress data has an invalid shape.',
      );
    }

    final bestScores = <String, int>{};
    for (final entry in rawScores.entries) {
      if (entry.key is! String || entry.value is! int) {
        throw const FormatException('Learning progress scores are invalid.');
      }
      bestScores[entry.key as String] = entry.value as int;
    }

    if (rawPassedIds.any((id) => id is! String) ||
        rawUnlockedIds.any((id) => id is! String) ||
        (rawSelectedSubjectIds is List &&
            rawSelectedSubjectIds.any((id) => id is! String))) {
      throw const FormatException('Learning progress IDs are invalid.');
    }

    final passedQuizIds = rawPassedIds.cast<String>().toSet();
    final unlockedLessonIds = rawUnlockedIds.cast<String>().toSet();
    final selectedSubjectIds = rawSelectedSubjectIds is List
        ? rawSelectedSubjectIds.cast<String>().toSet()
        : <String>{};
    if (selectedSubjectIds.any(
      (id) => !LearningCurriculum.containsSubject(id),
    )) {
      throw const FormatException('Learning progress subject IDs are invalid.');
    }
    final lastQuizId = rawLastQuizId as String?;
    if (lastQuizId != null &&
        !LearningCurriculum.quizzes.any((quiz) => quiz.id == lastQuizId)) {
      throw const FormatException('Learning progress quiz ID is invalid.');
    }
    if (rawCredits != passedQuizIds.length ||
        bestScores.values.any((score) => score < 0 || score > 100)) {
      throw const FormatException('Learning progress values are invalid.');
    }

    return LearningProgress(
      bestScores: bestScores,
      passedQuizIds: passedQuizIds,
      unlockedLessonIds: unlockedLessonIds,
      selectedSubjectIds: selectedSubjectIds,
      lastQuizId: lastQuizId,
    );
  }

  int get credits => passedQuizIds.length;

  LearningProgress withSelectedSubjects(Set<String> subjectIds) {
    if (subjectIds.any((id) => !LearningCurriculum.containsSubject(id))) {
      throw ArgumentError.value(
        subjectIds,
        'subjectIds',
        'Every selected subject must exist in the curriculum.',
      );
    }

    final nextUnlockedLessonIds = Set<String>.from(unlockedLessonIds);
    for (final subjectId in subjectIds) {
      final firstLesson = LearningCurriculum.firstLessonForSubject(subjectId);
      if (firstLesson != null) nextUnlockedLessonIds.add(firstLesson.id);
    }

    return LearningProgress(
      bestScores: bestScores,
      passedQuizIds: passedQuizIds,
      unlockedLessonIds: nextUnlockedLessonIds,
      selectedSubjectIds: Set<String>.from(subjectIds),
      lastQuizId: lastQuizId,
    );
  }

  QuizSubmissionResult withQuizResult({
    required QuizDefinition quiz,
    required int score,
  }) {
    if (score < 0 || score > 100) {
      throw ArgumentError.value(score, 'score', 'Score must be from 0 to 100.');
    }
    final lesson = LearningCurriculum.lessonById(quiz.lessonId);
    if (!selectedSubjectIds.contains(lesson.subjectId)) {
      throw StateError('Select this lesson subject before taking its quiz.');
    }
    if (!unlockedLessonIds.contains(lesson.id)) {
      throw StateError('Unlock this lesson before submitting its quiz.');
    }

    final previouslyPassed = passedQuizIds.contains(quiz.id);
    final passed = previouslyPassed || score >= LearningCurriculum.passScore;
    final nextBestScores = Map<String, int>.from(bestScores);
    final previousBest = nextBestScores[quiz.id] ?? 0;
    if (score > previousBest) nextBestScores[quiz.id] = score;

    final nextPassedQuizIds = Set<String>.from(passedQuizIds);
    final nextUnlockedLessonIds = Set<String>.from(unlockedLessonIds);
    if (passed) {
      nextPassedQuizIds.add(quiz.id);
      if (quiz.nextLessonId case final nextLessonId?) {
        final nextLesson = LearningCurriculum.lessonById(nextLessonId);
        if (nextLesson.subjectId != lesson.subjectId) {
          throw StateError('A quiz cannot unlock a lesson in another subject.');
        }
        nextUnlockedLessonIds.add(nextLessonId);
      }
    }

    return QuizSubmissionResult(
      progress: LearningProgress(
        bestScores: nextBestScores,
        passedQuizIds: nextPassedQuizIds,
        unlockedLessonIds: nextUnlockedLessonIds,
        selectedSubjectIds: selectedSubjectIds,
        lastQuizId: quiz.id,
      ),
      earnedCredit: !previouslyPassed && passed,
    );
  }

  Map<String, dynamic> toFirestoreData() => {
    'bestScores': bestScores,
    'passedQuizIds': passedQuizIds.toList(),
    'unlockedLessonIds': unlockedLessonIds.toList(),
    'selectedSubjectIds': selectedSubjectIds.toList(),
    'lastQuizId': lastQuizId,
    'credits': credits,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class QuizSubmissionResult {
  final LearningProgress progress;
  final bool earnedCredit;

  const QuizSubmissionResult({
    required this.progress,
    required this.earnedCredit,
  });
}

class LearningProgressRepository {
  const LearningProgressRepository();

  DocumentReference<Map<String, dynamic>> _progressDocument(String userId) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('learningProgress')
          .doc('current');

  Stream<LearningProgress> watch(String userId) =>
      _progressDocument(userId)
          .snapshots()
          .map((snapshot) => LearningProgress.fromData(snapshot.data()));

  Future<LearningProgress> setSubjectSelected({
    required String userId,
    required String subjectId,
    required bool selected,
  }) {
    final document = _progressDocument(userId);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final current = LearningProgress.fromData(snapshot.data());
      final subjectIds = Set<String>.from(current.selectedSubjectIds);
      if (selected) {
        subjectIds.add(subjectId);
      } else {
        subjectIds.remove(subjectId);
      }
      final progress = current.withSelectedSubjects(subjectIds);
      transaction.set(document, progress.toFirestoreData());
      return progress;
    });
  }

  Future<QuizSubmissionResult> submitQuiz({
    required String userId,
    required QuizDefinition quiz,
    required int score,
  }) {
    final document = _progressDocument(userId);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final current = LearningProgress.fromData(snapshot.data());
      final result = current.withQuizResult(quiz: quiz, score: score);
      transaction.set(document, result.progress.toFirestoreData());
      return result;
    });
  }
}
