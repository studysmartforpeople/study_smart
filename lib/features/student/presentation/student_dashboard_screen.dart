import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/presentation/landing_screen.dart';
import '../data/profile_photo_repository.dart';
import 'pages/lessons_page.dart';
import 'pages/quizzes_page.dart';
import 'pages/settings_page.dart';
import 'pages/student_home_page.dart';
import 'pages/student_profile_page.dart';
import 'pages/subject_list_page.dart';

class StudentDashboardScreen extends StatefulWidget {
  final User user;

  const StudentDashboardScreen({super.key, required this.user});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  late final Stream<Uint8List?> _profilePhotoStream;

  @override
  void initState() {
    super.initState();
    _profilePhotoStream = const ProfilePhotoRepository().watch(widget.user.uid);
  }

  void _selectPage(int index) {
    setState(() => _selectedIndex = index);
    Navigator.of(context).pop();
  }

  void _openSettings() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: SettingsPage(onLogout: _logout),
        ),
      ),
    );
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
    final signedInUser = FirebaseAuth.instance.currentUser ?? widget.user;
    final drawerName = signedInUser.displayName?.trim();
    final displayedName = drawerName == null || drawerName.isEmpty
        ? 'Study Smart Student'
        : drawerName;

    final pages = <Widget>[
      StudentHomePage(user: widget.user),
      SubjectListPage(),
      LessonsPage(userId: widget.user.uid),
      QuizzesPage(userId: widget.user.uid),
      StudentProfilePage(user: widget.user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Smart'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
                ),
              ),
              accountName: Text(displayedName),
              accountEmail: Text(signedInUser.email ?? ''),
              currentAccountPicture: StreamBuilder<Uint8List?>(
                stream: _profilePhotoStream,
                builder: (context, snapshot) {
                  final photoBytes = snapshot.data;
                  return Tooltip(
                    message: snapshot.hasError
                        ? 'Profile photo could not be loaded.'
                        : 'Profile photo',
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: photoBytes == null
                          ? null
                          : MemoryImage(photoBytes),
                      child: snapshot.hasError
                          ? const Icon(
                              Icons.broken_image_rounded,
                              color: Colors.red,
                            )
                          : photoBytes == null
                          ? Text(
                              displayedName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.indigo,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            _DrawerItem(
              label: 'Home',
              icon: Icons.home_rounded,
              onTap: () => _selectPage(0),
            ),
            _DrawerItem(
              label: 'My Subjects',
              icon: Icons.menu_book_rounded,
              onTap: () => _selectPage(1),
            ),
            _DrawerItem(
              label: 'Lessons',
              icon: Icons.library_books_rounded,
              onTap: () => _selectPage(2),
            ),
            _DrawerItem(
              label: 'Quizzes',
              icon: Icons.quiz_rounded,
              onTap: () => _selectPage(3),
            ),
            _DrawerItem(
              label: 'My Profile & Progress',
              icon: Icons.person_rounded,
              onTap: () => _selectPage(4),
            ),
            _DrawerItem(
              label: 'Settings',
              icon: Icons.settings_rounded,
              onTap: _openSettings,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) =>
            setState(() => _selectedIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_rounded),
            label: 'Lessons',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_rounded),
            label: 'Quizzes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}
