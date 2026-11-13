import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/firebase_error_message.dart';

class StudentProfilePage extends StatelessWidget {
  final User user;

  const StudentProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
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
        final fullName = data['fullName'] ?? user.displayName ?? 'Student';
        final email = data['email'] ?? user.email ?? 'No email';
        final age = data['age'] ?? 'N/A';
        final studentCode = data['studentCode'] ?? 'N/A';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.indigo,
                    child: Text(
                      fullName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _ProfileInfoTile(label: 'Email', value: email),
            _ProfileInfoTile(label: 'Age', value: age.toString()),
            _ProfileInfoTile(label: 'Student Code', value: studentCode.toString()),
            _ProfileInfoTile(label: 'Learning Language', value: data['preferredLanguage'] ?? 'English'),
          ],
        );
      },
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
      ),
    );
  }
}
