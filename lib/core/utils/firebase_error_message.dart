import 'package:firebase_auth/firebase_auth.dart';

String firebaseErrorMessage(Object error, {required String action}) {
  if (error is FirebaseAuthException) {
    final description = switch (error.code) {
      'invalid-email' => 'The email address is invalid.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account was found for this email.',
      'wrong-password' || 'invalid-credential' =>
        'The email or password is incorrect.',
      'email-already-in-use' =>
        'This email is already registered. Sign in or retry registration if profile setup previously failed.',
      'weak-password' => 'Choose a stronger password with at least 8 characters.',
      'network-request-failed' =>
        'Network error. Check your connection and try again.',
      'too-many-requests' =>
        'Too many attempts. Wait a moment and try again.',
      'operation-not-allowed' =>
        'Email/password sign-in is disabled for this Firebase project.',
      _ => error.message?.trim().isNotEmpty == true
          ? error.message!
          : 'No additional Firebase details were provided.',
    };
    return '$action failed [Firebase Auth ${error.code}]: $description';
  }

  if (error is FirebaseException) {
    final details = error.message?.trim().isNotEmpty == true
        ? error.message!
        : 'No additional Firebase details were provided.';
    return '$action failed [${error.plugin} ${error.code}]: $details';
  }

  if (error is StateError) {
    return '$action failed: ${error.message}';
  }

  return '$action failed [${error.runtimeType}]: $error';
}
