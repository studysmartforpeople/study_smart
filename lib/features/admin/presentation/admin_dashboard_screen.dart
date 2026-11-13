import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/firebase_error_message.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/presentation/landing_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final User user;

  const AdminDashboardScreen({super.key, required this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Future<List<Map<String, dynamic>>> _fetchStudents() async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();
    return query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectableText(
                  firebaseErrorMessage(
                    snapshot.error!,
                    action: 'Loading student records',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Platform overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
                children: const [
                  StatCard(title: 'Students', value: '120', color: Colors.indigo),
                  StatCard(title: 'Subjects', value: '4', color: Colors.green),
                  StatCard(title: 'Lessons', value: '18', color: Colors.orange),
                  StatCard(title: 'Quizzes', value: '12', color: Colors.purple),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Recent students', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (students.isEmpty)
                const Card(child: ListTile(title: Text('No students found in Firestore yet.')))
              else
                ...students.map(
                  (student) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text((student['fullName'] ?? 'S').toString().substring(0, 1).toUpperCase()),
                      ),
                      title: Text(student['fullName'] ?? 'Student'),
                      subtitle: Text(student['email'] ?? ''),
                      trailing: Chip(label: Text(student['studentCode'] ?? 'N/A')),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
