import 'package:cloud_firestore/cloud_firestore.dart';

import 'learning_language.dart';

class PreferredLanguageRepository {
  const PreferredLanguageRepository();

  Stream<LearningLanguage> watch(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return LearningLanguage.english;
          return LearningLanguage.fromPreference(
            snapshot.data()?['preferredLanguage'],
          );
        });
  }

  Future<void> setLanguage({
    required String userId,
    required LearningLanguage language,
  }) {
    return FirebaseFirestore.instance.collection('users').doc(userId).update({
      'preferredLanguage': language.preferenceValue,
    });
  }
}
