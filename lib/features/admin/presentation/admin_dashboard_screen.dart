import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/app_theme_controller.dart';
import '../../../core/utils/firebase_error_message.dart';
import '../../auth/presentation/landing_screen.dart';
import '../../student/data/learning_curriculum.dart';
import '../data/admin_student_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  final User user;
  final AdminStudentRepository repository;

  const AdminDashboardScreen({
    super.key,
    required this.user,
    this.repository = const AdminStudentRepository(),
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<AdminStudentRecord>> _studentsFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _studentsFuture = widget.repository.fetchStudents();
    _searchController.addListener(_updateSearchQuery);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_updateSearchQuery)
      ..dispose();
    super.dispose();
  }

  void _updateSearchQuery() {
    setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
  }

  void _reloadStudents() {
    setState(() => _studentsFuture = widget.repository.fetchStudents());
  }

  Future<void> _toggleTheme() async {
    final themeController = AppThemeScope.of(context);
    try {
      final saved = await themeController.setDarkMode(
        !themeController.isDarkMode,
      );
      if (!saved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save dark mode setting.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            firebaseErrorMessage(error, action: 'Saving dark mode setting'),
          ),
        ),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = AppThemeScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Smart Admin'),
        actions: [
          IconButton(
            onPressed: _toggleTheme,
            tooltip: themeController.isDarkMode
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            icon: Icon(
              themeController.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          IconButton(
            onPressed: _reloadStudents,
            tooltip: 'Refresh student data',
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<AdminStudentRecord>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        firebaseErrorMessage(
                          snapshot.error!,
                          action: 'Loading student records',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _reloadStudents,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!;
          final totalQuizPasses = students.fold<int>(
            0,
            (total, student) => total + student.progress.quizPasses,
          );
          final activeLearners = students
              .where((student) => student.progress.quizPasses > 0)
              .length;
          final totalPossibleCredits =
              students.length * LearningCurriculum.quizzes.length;
          final averageProgress = totalPossibleCredits == 0
              ? 0
              : (totalQuizPasses * 100 / totalPossibleCredits).round();
          final matchingStudents = students.where((student) {
            final searchableText =
                '${student.fullName} ${student.email} ${student.studentCode}'
                    .toLowerCase();
            return searchableText.contains(_searchQuery);
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1100
                  ? 4
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: ListView(
                    padding: EdgeInsets.all(
                      constraints.maxWidth < 600 ? 16 : 28,
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.surfaceContainerLow,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface.withValues(
                                        alpha: 0.72,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.shield_rounded,
                                          size: 15,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ADMIN CONSOLE',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.7,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Dashboard overview',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Monitor student activity and learning progress.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings_rounded,
                                color: colorScheme.primary,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 124,
                        children: [
                          _OverviewCard(
                            title: 'Students',
                            value: '${students.length}',
                            icon: Icons.people_alt_rounded,
                            color: colorScheme.primary,
                          ),
                          _OverviewCard(
                            title: 'Started learning',
                            value: '$activeLearners',
                            icon: Icons.auto_stories_rounded,
                            color: colorScheme.tertiary,
                          ),
                          _OverviewCard(
                            title: 'Quiz passes',
                            value: '$totalQuizPasses',
                            icon: Icons.task_alt_rounded,
                            color: colorScheme.secondary,
                          ),
                          _OverviewCard(
                            title: 'Average progress',
                            value: '$averageProgress%',
                            icon: Icons.trending_up_rounded,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Student learning progress',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              child: Text(
                                '${matchingStudents.length} of ${students.length}',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search name, email, or student code',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: _searchController.clear,
                                  tooltip: 'Clear search',
                                  icon: const Icon(Icons.clear_rounded),
                                ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.55),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (students.isEmpty)
                        const _DashboardEmptyState(
                          icon: Icons.people_outline_rounded,
                          title: 'No students yet',
                          message: 'Student accounts will appear here after registration.',
                        )
                      else if (matchingStudents.isEmpty)
                        const _DashboardEmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No matching students',
                          message:
                              'Try a different name, email, or student code.',
                        )
                      else
                        ...matchingStudents.map(
                          (student) => _StudentListTile(
                            student: student,
                            onTap: () => _showStudentDetails(student),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showStudentDetails(AdminStudentRecord student) {
    showDialog<void>(
      context: context,
      builder: (context) => _StudentProgressDialog(student: student),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _DashboardEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(icon, size: 40, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentListTile extends StatelessWidget {
  final AdminStudentRecord student;
  final VoidCallback onTap;

  const _StudentListTile({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalQuizzes = LearningCurriculum.quizzes.length;
    final progressValue = (student.progress.quizPasses / totalQuizzes).clamp(
      0.0,
      1.0,
    );
    final progressColor = student.progress.quizPasses > 0
        ? colorScheme.tertiary
        : colorScheme.outline;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        minVerticalPadding: 10,
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: Text(student.fullName.substring(0, 1).toUpperCase()),
        ),
        title: Text(student.fullName),
        subtitle: Text(
          [
            if (student.email.isNotEmpty) student.email,
            'Code: ${student.studentCode}',
          ].join('  ·  '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        trailing: SizedBox(
          width: 70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${student.progress.quizPasses}/$totalQuizzes',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressValue.toDouble(),
                  minHeight: 5,
                  color: progressColor,
                  backgroundColor: progressColor.withValues(alpha: 0.14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentProgressDialog extends StatelessWidget {
  final AdminStudentRecord student;

  const _StudentProgressDialog({required this.student});

  @override
  Widget build(BuildContext context) {
    final student = this.student;
    final progress = student.progress;
    final totalQuizzes = LearningCurriculum.quizzes.length;
    final totalCredits = progress.credits;

    return AlertDialog(
      title: Text(student.fullName),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(student.email),
              Text('Student code: ${student.studentCode}'),
              const SizedBox(height: 20),
              Text(
                'Credits: $totalCredits',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text('Credit progress: ${progress.creditRemainder}/100'),
              const SizedBox(height: 16),
              Text(
                'Progress: ${progress.quizPasses}/$totalQuizzes quizzes passed',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.quizPasses / totalQuizzes,
              ),
              const SizedBox(height: 16),
              ...LearningCurriculum.quizzes.map((quiz) {
                final score = progress.bestScores[quiz.id];
                final passed = progress.passedQuizIds.contains(quiz.id);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    passed
                        ? Icons.check_circle_rounded
                        : score == null
                        ? Icons.radio_button_unchecked_rounded
                        : Icons.replay_rounded,
                    color: passed ? Colors.green : null,
                  ),
                  title: Text(quiz.title),
                  subtitle: Text(
                    score == null
                        ? 'Not attempted'
                        : 'Best score: $score%${passed ? ' · Passed' : ' · Not passed'}',
                  ),
                );
              }),
              const SizedBox(height: 8),
              const Text(
                'Unlocked lessons',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              ...LearningCurriculum.lessons
                  .where(
                    (lesson) => progress.unlockedLessonIds.contains(lesson.id),
                  )
                  .map((lesson) => Text('• ${lesson.title}')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
