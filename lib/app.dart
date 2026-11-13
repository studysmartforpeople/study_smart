import 'package:flutter/material.dart';

import 'features/auth/presentation/auth_gate.dart';

export 'core/services/user_role_service.dart';
export 'core/utils/auth_validators.dart';
export 'core/utils/firebase_error_message.dart';
export 'features/admin/presentation/admin_dashboard_screen.dart';
export 'features/auth/presentation/admin_login_screen.dart';
export 'features/auth/presentation/auth_gate.dart';
export 'features/auth/presentation/landing_screen.dart';
export 'features/auth/presentation/student_login_screen.dart';
export 'features/auth/presentation/student_register_screen.dart';
export 'features/student/presentation/pages/lessons_page.dart';
export 'features/student/presentation/pages/progress_page.dart';
export 'features/student/presentation/pages/quizzes_page.dart';
export 'features/student/presentation/pages/settings_page.dart';
export 'features/student/presentation/pages/student_home_page.dart';
export 'features/student/presentation/pages/student_profile_page.dart';
export 'features/student/presentation/pages/subject_list_page.dart';
export 'features/student/presentation/student_dashboard_screen.dart';

class StudySmartApp extends StatelessWidget {
  const StudySmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Smart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF4F7FF),
      ),
      home: const AuthGate(),
    );
  }
}
