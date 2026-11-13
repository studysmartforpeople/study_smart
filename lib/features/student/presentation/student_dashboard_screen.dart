import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/presentation/landing_screen.dart';
import 'pages/lessons_page.dart';
import 'pages/progress_page.dart';
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
    final pages = <Widget>[
      StudentHomePage(user: widget.user),
      SubjectListPage(),
      LessonsPage(),
      QuizzesPage(),
      ProgressPage(),
      StudentProfilePage(user: widget.user),
      SettingsPage(onLogout: _logout),
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
              accountName: Text(widget.user.displayName ?? 'Study Smart Student'),
              accountEmail: Text(widget.user.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (widget.user.displayName ?? 'S').substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 24, color: Colors.indigo),
                ),
              ),
            ),
            _DrawerItem(label: 'Home', icon: Icons.home_rounded, index: 0, onTap: () => setState(() => _selectedIndex = 0)),
            _DrawerItem(label: 'My Subjects', icon: Icons.menu_book_rounded, index: 1, onTap: () => setState(() => _selectedIndex = 1)),
            _DrawerItem(label: 'Lessons', icon: Icons.library_books_rounded, index: 2, onTap: () => setState(() => _selectedIndex = 2)),
            _DrawerItem(label: 'Quizzes', icon: Icons.quiz_rounded, index: 3, onTap: () => setState(() => _selectedIndex = 3)),
            _DrawerItem(label: 'My Progress', icon: Icons.insights_rounded, index: 4, onTap: () => setState(() => _selectedIndex = 4)),
            _DrawerItem(label: 'My Profile', icon: Icons.person_rounded, index: 5, onTap: () => setState(() => _selectedIndex = 5)),
            _DrawerItem(label: 'Settings', icon: Icons.settings_rounded, index: 6, onTap: () => setState(() => _selectedIndex = 6)),
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
        onDestinationSelected: (value) => setState(() => _selectedIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Subjects'),
          NavigationDestination(icon: Icon(Icons.library_books_rounded), label: 'Lessons'),
          NavigationDestination(icon: Icon(Icons.quiz_rounded), label: 'Quizzes'),
          NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final int index;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
