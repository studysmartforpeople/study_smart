import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_smart_dev/app.dart';
import 'package:study_smart_dev/shared/widgets/stat_card.dart';

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
