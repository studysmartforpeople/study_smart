import 'package:cloud_firestore/cloud_firestore.dart';

import '../../student/data/learning_progress_repository.dart';

class AdminStudentRecord {
  final String uid;
  final String fullName;
  final String email;
  final String studentCode;
  final LearningProgress progress;

  const AdminStudentRecord({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.studentCode,
    required this.progress,
  });
}

class AdminStudentRepository {
  const AdminStudentRepository();

  Future<List<AdminStudentRecord>> fetchStudents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    return Future.wait(
      snapshot.docs.map((document) async {
        final data = document.data();
        final progressSnapshot = await document.reference
            .collection('learningProgress')
            .doc('current')
            .get();

        String profileValue(String key, String fallback) {
          final value = data[key];
          return value is String && value.trim().isNotEmpty
              ? value.trim()
              : fallback;
        }

        return AdminStudentRecord(
          uid: document.id,
          fullName: profileValue('fullName', 'Student'),
          email: profileValue('email', ''),
          studentCode: profileValue('studentCode', 'N/A'),
          progress: LearningProgress.fromData(progressSnapshot.data()),
        );
      }),
    );
  }
}
