import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/date_of_birth_format.dart';
import '../../../../core/utils/firebase_error_message.dart';
import '../../data/profile_photo_repository.dart';
import 'progress_page.dart';

class StudentProfilePage extends StatefulWidget {
  final User user;

  const StudentProfilePage({super.key, required this.user});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  late final Future<DocumentSnapshot<Map<String, dynamic>>> _profileFuture;
  final ProfilePhotoRepository _photoRepository =
      const ProfilePhotoRepository();
  late final Stream<Uint8List?> _photoStream;
  bool _isSavingPhoto = false;
  bool _isRemovingPhoto = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();
    _photoStream = _photoRepository.watch(widget.user.uid);
  }

  Future<void> _changeProfilePhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      if (image == null || !mounted) return;

      setState(() {
        _isSavingPhoto = true;
        _isRemovingPhoto = false;
      });
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != widget.user.uid) {
        throw StateError(
          'The signed-in account changed. Please sign in again.',
        );
      }

      final bytes = await image.readAsBytes();
      await _photoRepository.save(widget.user.uid, bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo updated.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            firebaseErrorMessage(error, action: 'Updating profile photo'),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPhoto = false;
          _isRemovingPhoto = false;
        });
      }
    }
  }

  Future<void> _removeProfilePhoto() async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove profile photo?'),
        content: const Text('Your profile will show your initial instead.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (!mounted || shouldRemove != true) return;

    try {
      setState(() {
        _isSavingPhoto = true;
        _isRemovingPhoto = true;
      });
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != widget.user.uid) {
        throw StateError(
          'The signed-in account changed. Please sign in again.',
        );
      }

      await _photoRepository.remove(widget.user.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo removed.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            firebaseErrorMessage(error, action: 'Removing profile photo'),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPhoto = false;
          _isRemovingPhoto = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                firebaseErrorMessage(
                  snapshot.error!,
                  action: 'Loading student profile',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() ?? {};
        final storedName = (data['fullName'] ?? widget.user.displayName ?? '')
            .toString()
            .trim();
        final fullName = storedName.isEmpty ? 'Student' : storedName;
        final email = (data['email'] ?? widget.user.email ?? 'No email')
            .toString();
        final storedDateOfBirth = data['dateOfBirth'];
        final parsedDateOfBirth = storedDateOfBirth is String
            ? parseDateOfBirth(storedDateOfBirth)
            : null;
        final legacyAge = data['age'];
        final dateOfBirth = parsedDateOfBirth == null
            ? legacyAge == null
                  ? 'Not provided'
                  : 'Unavailable for previous account (age: $legacyAge)'
            : formatDateOfBirth(parsedDateOfBirth);
        final studentCode = (data['studentCode'] ?? 'N/A').toString();
        final preferredLanguage = (data['preferredLanguage'] ?? 'English')
            .toString();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            StreamBuilder<Uint8List?>(
              stream: _photoStream,
              builder: (context, photoSnapshot) {
                final photoBytes = photoSnapshot.data;
                final scheme = Theme.of(context).colorScheme;
                return Card(
                  color: scheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: scheme.primary,
                          backgroundImage: photoBytes == null
                              ? null
                              : MemoryImage(photoBytes),
                          child: photoSnapshot.hasError
                              ? const Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.white,
                                  size: 32,
                                )
                              : _isSavingPhoto
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : photoBytes == null
                              ? Text(
                                  fullName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fullName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: _isSavingPhoto
                                  ? null
                                  : _changeProfilePhoto,
                              icon: const Icon(Icons.camera_alt_rounded),
                              label: Text(
                                _isSavingPhoto
                                    ? _isRemovingPhoto
                                          ? 'Removing photo…'
                                          : 'Uploading photo…'
                                    : 'Change photo',
                              ),
                            ),
                            if (photoBytes != null)
                              TextButton.icon(
                                onPressed: _isSavingPhoto
                                    ? null
                                    : _removeProfilePhoto,
                                style: TextButton.styleFrom(
                                  foregroundColor: scheme.error,
                                ),
                                icon: const Icon(Icons.delete_outline_rounded),
                                label: const Text('Remove photo'),
                              ),
                          ],
                        ),
                        if (photoSnapshot.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              firebaseErrorMessage(
                                photoSnapshot.error!,
                                action: 'Loading profile photo',
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.error),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Account details',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _ProfileInfoTile(
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              value: email,
            ),
            _ProfileInfoTile(
              icon: Icons.cake_outlined,
              label: 'Date of Birth',
              value: dateOfBirth,
            ),
            _ProfileInfoTile(
              icon: Icons.badge_outlined,
              label: 'Student Code',
              value: studentCode,
            ),
            _ProfileInfoTile(
              icon: Icons.translate_rounded,
              label: 'Learning Language',
              value: preferredLanguage,
            ),
            const SizedBox(height: 16),
            ProgressOverview(userId: widget.user.uid),
          ],
        );
      },
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 21,
          ),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(value),
        ),
      ),
    );
  }
}
