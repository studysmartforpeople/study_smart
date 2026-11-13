import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../core/services/user_role_service.dart';
import '../../../core/utils/firebase_error_message.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';
import '../../student/presentation/student_dashboard_screen.dart';
import 'landing_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const LandingScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AuthGateIssue(
            message: firebaseErrorMessage(
              snapshot.error!,
              action: 'Checking sign-in state',
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return const LandingScreen();
        }

        return FutureBuilder<String>(
          future: loadUserRole(user.uid),
          builder: (context, docSnapshot) {
            if (docSnapshot.hasError) {
              return _AuthGateIssue(
                message: firebaseErrorMessage(
                  docSnapshot.error!,
                  action: 'Loading your account profile',
                ),
              );
            }
            if (docSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final role = docSnapshot.data!;
            if (role == 'admin') {
              return AdminDashboardScreen(user: user);
            }

            return StudentDashboardScreen(user: user);
          },
        );
      },
    );
  }
}

class _AuthGateIssue extends StatelessWidget {
  final String message;

  const _AuthGateIssue({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Could not load your account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SelectableText(message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            firebaseErrorMessage(error, action: 'Sign out'),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Study Smart...'),
          ],
        ),
      ),
    );
  }
}
