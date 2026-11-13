import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> loadUserRole(String uid) async {
  final userDocument =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (!userDocument.exists) {
    throw StateError(
      'The authenticated account has no users/$uid profile. '
      'Complete student registration or have an administrator provision this account.',
    );
  }

  final role = userDocument.data()?['role'];
  if (role != 'student' && role != 'admin') {
    throw StateError(
      'The users/$uid profile has an invalid or missing role. '
      'Ask an administrator to correct the profile.',
    );
  }

  return role as String;
}
