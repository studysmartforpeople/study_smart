import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/date_of_birth_format.dart';

String formatStudentCode(int number) {
  if (number < 1) {
    throw ArgumentError.value(number, 'number', 'Must be greater than zero.');
  }
  return 'SDS2026-${number.toString().padLeft(4, '0')}';
}

class StudentRegistrationRepository {
  const StudentRegistrationRepository();

  Future<String> createStudentProfile({
    required String uid,
    required String fullName,
    required String email,
    required DateTime dateOfBirth,
  }) {
    final firestore = FirebaseFirestore.instance;
    final profile = firestore.collection('users').doc(uid);
    final counter = firestore.collection('systemCounters').doc('studentCode');

    return firestore.runTransaction((transaction) async {
      final counterSnapshot = await transaction.get(counter);
      final rawLastNumber = counterSnapshot.data()?['lastNumber'];
      if (counterSnapshot.exists && rawLastNumber is! int) {
        throw const FormatException(
          'The student code counter is invalid. Contact an administrator.',
        );
      }

      final nextNumber = (rawLastNumber is int ? rawLastNumber : 0) + 1;
      final studentCode = formatStudentCode(nextNumber);

      transaction.set(counter, {'lastNumber': nextNumber});
      transaction.set(profile, {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'dateOfBirth': serializeDateOfBirth(dateOfBirth),
        'studentCode': studentCode,
        'role': 'student',
        'preferredLanguage': 'English',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return studentCode;
    });
  }
}
