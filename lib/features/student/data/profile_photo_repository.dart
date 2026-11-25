import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePhotoRepository {
  static const maxPhotoBytes = 250 * 1024;
  static const maxEncodedPhotoCharacters = 350000;

  const ProfilePhotoRepository();

  DocumentReference<Map<String, dynamic>> _photoDocument(String userId) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('profilePhotos')
          .doc('current');

  Stream<Uint8List?> watch(String userId) =>
      _photoDocument(userId).snapshots().map((snapshot) {
        final data = snapshot.data();
        if (data == null || !data.containsKey('base64')) return null;

        final encodedPhoto = data['base64'];
        if (encodedPhoto is! String ||
            encodedPhoto.length > maxEncodedPhotoCharacters) {
          throw const FormatException('Stored profile photo is invalid.');
        }

        final bytes = base64Decode(encodedPhoto);
        if (bytes.length > maxPhotoBytes) {
          throw const FormatException('Stored profile photo is too large.');
        }
        return bytes;
      });

  Future<void> save(String userId, Uint8List bytes) async {
    if (bytes.length > maxPhotoBytes) {
      throw StateError('Choose a photo smaller than 250 KB.');
    }

    await _photoDocument(userId).set({'base64': base64Encode(bytes)});
  }

  Future<void> remove(String userId) => _photoDocument(userId).delete();
}
