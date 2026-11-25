import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:study_smart_dev/app.dart';
import 'package:study_smart_dev/core/services/app_theme_controller.dart';
import 'package:study_smart_dev/core/utils/date_of_birth_format.dart';
import 'package:study_smart_dev/features/auth/data/student_registration_repository.dart';
import 'package:study_smart_dev/features/admin/data/admin_student_repository.dart';
import 'package:study_smart_dev/features/student/data/learning_curriculum.dart';
import 'package:study_smart_dev/features/student/data/learning_progress_repository.dart';
import 'package:study_smart_dev/shared/widgets/stat_card.dart';

class _MemoryAdminStudentRepository extends AdminStudentRepository {
  final List<AdminStudentRecord> students;

  _MemoryAdminStudentRepository(this.students);

  @override
  Future<List<AdminStudentRecord>> fetchStudents() async => students;
}

class _MemoryLearningProgressRepository extends LearningProgressRepository {
  LearningProgress _progress = LearningProgress.initial();
  int? submittedScore;

  @override
  Stream<LearningProgress> watch(String userId) => Stream.value(_progress);

  @override
  Future<QuizSubmissionResult> submitQuiz({
    required String userId,
    required QuizDefinition quiz,
    required int score,
  }) async {
    submittedScore = score;
    final result = _progress.withQuizResult(quiz: quiz, score: score);
    _progress = result.progress;
    return result;
  }
}

class _TestUser implements User {
  const _TestUser();

  @override
  String? get displayName => 'Alex';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('Firebase Auth errors include useful codes and explanations', () {
    final message = firebaseErrorMessage(
      FirebaseAuthException(code: 'invalid-credential'),
      action: 'Student login',
    );

    expect(message, contains('Firebase Auth invalid-credential'));
    expect(message, contains('email or password is incorrect'));
  });

  test('Firestore errors include plugin, code, and server details', () {
    final message = firebaseErrorMessage(
      FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Missing or insufficient permissions.',
      ),
      action: 'Loading account profile',
    );

    expect(message, contains('cloud_firestore permission-denied'));
    expect(message, contains('Missing or insufficient permissions.'));
  });

  test('Student codes use the padded sequential format', () {
    expect(formatStudentCode(1), 'SDS2026-0001');
    expect(formatStudentCode(9), 'SDS2026-0009');
    expect(formatStudentCode(10), 'SDS2026-0010');
    expect(formatStudentCode(1000), 'SDS2026-1000');
  });

  test('Birth dates round-trip as date-only values', () {
    final date = DateTime(2010, 4, 7);
    final storedDate = serializeDateOfBirth(date);

    expect(storedDate, '2010-04-07');
    expect(parseDateOfBirth(storedDate), date);
    expect(formatDateOfBirth(date), '07/04/2010');
    expect(parseDateOfBirth('2010-02-30'), isNull);
  });

  testWidgets('Study Smart landing screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LandingScreen()));

    expect(find.text('Study Smart'), findsWidgets);
    expect(find.text('Student Login'), findsOneWidget);
    expect(find.text('Student Register'), findsOneWidget);
  });

  testWidgets('Student login accepts a prefilled email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StudentLoginScreen(initialEmail: 'student@gmail.com'),
      ),
    );

    final emailField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(emailField.controller?.text, 'student@gmail.com');
  });

  testWidgets('Student registration asks for birth date, not age or code', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: StudentRegisterScreen()));

    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Select date of birth'), findsOneWidget);
    expect(find.text('Age'), findsNothing);
    expect(find.text('Student Code'), findsNothing);

    await tester.tap(find.text('Select date of birth'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Student login can show and hide the password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: StudentLoginScreen()));

    var passwordField = tester.widget<EditableText>(
      find.descendant(
        of: find.byType(TextFormField).last,
        matching: find.byType(EditableText),
      ),
    );
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    passwordField = tester.widget<EditableText>(
      find.descendant(
        of: find.byType(TextFormField).last,
        matching: find.byType(EditableText),
      ),
    );
    expect(passwordField.obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('Admin login can show and hide the password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminLoginScreen()));

    final emailField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(emailField.controller?.text, 'admin@studysmart.com');

    var passwordField = tester.widget<EditableText>(
      find.descendant(
        of: find.byType(TextFormField).last,
        matching: find.byType(EditableText),
      ),
    );
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    passwordField = tester.widget<EditableText>(
      find.descendant(
        of: find.byType(TextFormField).last,
        matching: find.byType(EditableText),
      ),
    );
    expect(passwordField.obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('Admin dashboard shows real student progress and details', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final themeController = AppThemeController();
    addTearDown(themeController.dispose);

    final firstQuiz = LearningCurriculum.quizzes.first;
    final progress = LearningProgress.initial()
        .withQuizResult(quiz: firstQuiz, score: 80)
        .progress;
    final repository = _MemoryAdminStudentRepository([
      AdminStudentRecord(
        uid: 'student-1',
        fullName: 'Sok Dara',
        email: 'sok@example.com',
        studentCode: 'ST-001',
        progress: progress,
      ),
      AdminStudentRecord(
        uid: 'student-2',
        fullName: 'Maly',
        email: 'maly@example.com',
        studentCode: 'ST-002',
        progress: LearningProgress.initial(),
      ),
    ]);

    await tester.pumpWidget(
      AppThemeScope(
        controller: themeController,
        child: AnimatedBuilder(
          animation: themeController,
          builder: (context, _) => MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeController.themeMode,
            home: AdminDashboardScreen(
              user: const _TestUser(),
              repository: repository,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Switch to dark mode'), findsOneWidget);
    await tester.tap(find.byTooltip('Switch to dark mode'));
    await tester.pumpAndSettle();
    expect(themeController.isDarkMode, isTrue);
    expect(
      Theme.of(tester.element(find.text('Dashboard overview'))).brightness,
      Brightness.dark,
    );
    expect(find.byTooltip('Switch to light mode'), findsOneWidget);

    expect(find.text('Students'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Started learning'), findsOneWidget);
    expect(find.text('Quiz passes'), findsOneWidget);
    final startedLearningCard = find.ancestor(
      of: find.text('Started learning'),
      matching: find.byType(Card),
    );
    final quizPassesCard = find.ancestor(
      of: find.text('Quiz passes'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(of: startedLearningCard, matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: quizPassesCard, matching: find.text('1')),
      findsOneWidget,
    );
    expect(find.text('Average progress'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sok Dara'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Sok Dara'), findsOneWidget);

    await tester.tap(find.text('Sok Dara'));
    await tester.pumpAndSettle();

    expect(find.text('Progress: 1/5 quizzes passed'), findsOneWidget);
    expect(find.text('Best score: 80% · Passed'), findsOneWidget);
    expect(find.textContaining('English Alphabet: A, B, C'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dark mode setting changes theme and persists', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final themeController = AppThemeController();

    await tester.pumpWidget(
      AppThemeScope(
        controller: themeController,
        child: AnimatedBuilder(
          animation: themeController,
          builder: (context, _) => MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeController.themeMode,
            home: Scaffold(body: SettingsPage(onLogout: () {})),
          ),
        ),
      ),
    );

    expect(
      Theme.of(tester.element(find.text('Settings'))).brightness,
      Brightness.light,
    );

    await tester.tap(find.widgetWithText(SwitchListTile, 'Dark mode'));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.text('Settings'))).brightness,
      Brightness.dark,
    );
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(AppThemeController.preferenceKey), isTrue);

    themeController.dispose();
  });

  test('Passing the beginner English quiz unlocks Vocabulary Essentials', () {
    final firstLesson = LearningCurriculum.lessons.first;
    final quiz = LearningCurriculum.quizzes.first;

    expect(firstLesson.title, 'English Alphabet: A, B, C');
    expect(quiz.lessonId, firstLesson.id);
    expect(
      LearningCurriculum.lessonById(quiz.nextLessonId!).title,
      'Vocabulary Essentials',
    );
    expect(
      calculateQuizScore(quiz, [0, 1, 2, 1, 0]),
      LearningCurriculum.passScore,
    );
  });

  test('New learning progress starts at the beginner English lesson', () {
    final progress = LearningProgress.fromData(null);

    expect(progress.credits, 0);
    expect(progress.bestScores, isEmpty);
    expect(progress.unlockedLessonIds, {LearningCurriculum.lessons.first.id});
  });

  test('Passing a quiz earns one credit and unlocks the next lesson once', () {
    final initial = LearningProgress.initial();
    final quiz = LearningCurriculum.quizzes.first;

    final failedAttempt = initial.withQuizResult(quiz: quiz, score: 60);
    expect(failedAttempt.progress.credits, 0);
    expect(failedAttempt.earnedCredit, isFalse);
    expect(failedAttempt.progress.unlockedLessonIds, {
      LearningCurriculum.lessons.first.id,
    });

    final passedAttempt = initial.withQuizResult(quiz: quiz, score: 80);
    expect(passedAttempt.progress.credits, 1);
    expect(passedAttempt.earnedCredit, isTrue);
    expect(
      passedAttempt.progress.unlockedLessonIds,
      contains(quiz.nextLessonId),
    );

    final retake = passedAttempt.progress.withQuizResult(
      quiz: quiz,
      score: 100,
    );
    expect(retake.progress.credits, 1);
    expect(retake.progress.bestScores[quiz.id], 100);
    expect(retake.earnedCredit, isFalse);
  });

  testWidgets('Passing a quiz shows the next lesson unlocked', (
    WidgetTester tester,
  ) async {
    final repository = _MemoryLearningProgressRepository();
    final quiz = LearningCurriculum.quizzes.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuizzesPage(
            userId: 'student-1',
            progressRepository: repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Locked'), findsNWidgets(4));

    await tester.tap(find.text(quiz.title));
    await tester.pumpAndSettle();

    for (var index = 0; index < quiz.questions.length; index++) {
      final question = quiz.questions[index];
      await tester.tap(find.text(question.options[question.correctOption]));
      await tester.pump();
      await tester.tap(
        find.text(
          index == quiz.questions.length - 1 ? 'Submit quiz' : 'Next question',
        ),
      );
      await tester.pumpAndSettle();
    }

    expect(repository.submittedScore, 100);
    expect(find.text('Your score: 100%'), findsOneWidget);
    expect(find.text('Vocabulary Essentials is now unlocked.'), findsOneWidget);
    expect(find.text('Total credits: 1'), findsOneWidget);
  });

  testWidgets('Profile progress shows earned credits and quiz scores', (
    WidgetTester tester,
  ) async {
    final repository = _MemoryLearningProgressRepository();
    final firstQuiz = LearningCurriculum.quizzes.first;
    await repository.submitQuiz(
      userId: 'student-1',
      quiz: firstQuiz,
      score: 80,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgressOverview(
            userId: 'student-1',
            progressRepository: repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 5 credits earned'), findsOneWidget);
    expect(find.text('Best score: 80%'), findsOneWidget);
    expect(find.text('Not attempted'), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home page displays the student overview in dark mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: StudentHomePage(user: _TestUser())),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Your overview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Subjects page displays responsive learning cards', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SubjectListPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Explore subjects'), findsOneWidget);
    expect(find.text('English Basic'), findsOneWidget);
    expect(find.text('Programming Basic'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Stat card fits in a compact dashboard grid cell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 123,
              height: 70,
              child: StatCard(
                title: 'Completed Lessons',
                value: '12',
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
