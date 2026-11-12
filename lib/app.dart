import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class StudySmartApp extends StatelessWidget {
  const StudySmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Smart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF4F7FF),
      ),
      home: const AuthGate(),
    );
  }
}

String firebaseErrorMessage(Object error, {required String action}) {
  if (error is FirebaseAuthException) {
    final description = switch (error.code) {
      'invalid-email' => 'The email address is invalid.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account was found for this email.',
      'wrong-password' || 'invalid-credential' =>
        'The email or password is incorrect.',
      'email-already-in-use' =>
        'This email is already registered. Sign in or retry registration if profile setup previously failed.',
      'weak-password' => 'Choose a stronger password with at least 8 characters.',
      'network-request-failed' =>
        'Network error. Check your connection and try again.',
      'too-many-requests' =>
        'Too many attempts. Wait a moment and try again.',
      'operation-not-allowed' =>
        'Email/password sign-in is disabled for this Firebase project.',
      _ => error.message?.trim().isNotEmpty == true
          ? error.message!
          : 'No additional Firebase details were provided.',
    };
    return '$action failed [Firebase Auth ${error.code}]: $description';
  }

  if (error is FirebaseException) {
    final details = error.message?.trim().isNotEmpty == true
        ? error.message!
        : 'No additional Firebase details were provided.';
    return '$action failed [${error.plugin} ${error.code}]: $details';
  }

  if (error is StateError) {
    return '$action failed: ${error.message}';
  }

  return '$action failed [${error.runtimeType}]: $error';
}

bool _isValidGmail(String email) {
  return RegExp(
    r'^[A-Z0-9._%+-]+@gmail\.com$',
    caseSensitive: false,
  ).hasMatch(email.trim());
}

Future<String> _loadUserRole(String uid) async {
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const LandingScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AuthGateIssue(
            message: firebaseErrorMessage(
              snapshot.error!,
              action: 'Checking sign-in state',
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return const LandingScreen();
        }

        return FutureBuilder<String>(
          future: _loadUserRole(user.uid),
          builder: (context, docSnapshot) {
            if (docSnapshot.hasError) {
              return _AuthGateIssue(
                message: firebaseErrorMessage(
                  docSnapshot.error!,
                  action: 'Loading your account profile',
                ),
              );
            }
            if (docSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final role = docSnapshot.data!;
            if (role == 'admin') {
              return AdminDashboardScreen(user: user);
            }

            return StudentDashboardScreen(user: user);
          },
        );
      },
    );
  }
}

class _AuthGateIssue extends StatelessWidget {
  final String message;

  const _AuthGateIssue({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Could not load your account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SelectableText(message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            firebaseErrorMessage(error, action: 'Sign out'),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Study Smart...'),
          ],
        ),
      ),
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded, size: 42, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Study Smart',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Learn anytime, improve your skills, and track your growth.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 28),
                      _ActionButton(
                        label: 'Student Login',
                        icon: Icons.login_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const StudentLoginScreen()),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _ActionButton(
                        label: 'Student Register',
                        icon: Icons.person_add_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const StudentRegisterScreen()),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _ActionButton(
                        label: 'Admin Login',
                        icon: Icons.admin_panel_settings_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class StudentLoginScreen extends StatefulWidget {
  final String initialEmail;

  const StudentLoginScreen({super.key, this.initialEmail = ''});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(text: widget.initialEmail);
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final role = await _loadUserRole(credential.user!.uid);
      if (role != 'student') {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This account does not have student access.')),
        );
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => StudentDashboardScreen(user: credential.user!)),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = firebaseErrorMessage(e, action: 'Student login');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(firebaseErrorMessage(e, action: 'Student login')),
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Continue your learning journey with Study Smart.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Gmail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter your Gmail.';
                      if (!_isValidGmail(value)) {
                        return 'Enter a valid Gmail address ending in @gmail.com.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter your password.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('Login'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StudentRegisterScreen()),
                    ),
                    child: const Text('Need an account? Create one here'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _studentCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    var authAccountAvailable = false;
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final currentUser = FirebaseAuth.instance.currentUser;
      User? user;

      if (currentUser != null &&
          currentUser.email?.toLowerCase() == email.toLowerCase()) {
        final existingProfile = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (existingProfile.exists) {
          throw FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'A profile already exists for this account. Please sign in.',
          );
        }
        user = currentUser;
      } else {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = credential.user;
      }

      if (user == null) {
        throw StateError('Firebase Authentication returned no user account.');
      }
      authAccountAvailable = true;

      final age = int.tryParse(_ageController.text.trim()) ?? 0;
      final fullName = _nameController.text.trim();
      final studentCode = _studentCodeController.text.trim();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName,
        'email': user.email ?? email,
        'age': age,
        'studentCode': studentCode,
        'role': 'student',
        'preferredLanguage': 'English',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful. Welcome to Study Smart!')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => StudentDashboardScreen(user: user!)),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final recoveryHint = authAccountAvailable
          ? ' Your authentication account is intact. After resolving the reported issue, press Register again to retry saving the profile.'
          : '';
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'This Gmail already has an account. Sign in with that account.',
            ),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Sign in',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StudentLoginScreen(
                      initialEmail: _emailController.text.trim(),
                    ),
                  ),
                );
              },
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${firebaseErrorMessage(e, action: 'Student registration')}$recoveryHint',
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Registration')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'Create your student account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Full name is required.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Gmail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email is required.';
                      final email = value.trim();
                      if (!_isValidGmail(email)) {
                        return 'Enter a valid Gmail address ending in @gmail.com.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.cake_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Age is required.';
                      final age = int.tryParse(value.trim());
                      if (age == null || age <= 0) return 'Age must be a valid positive number.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _studentCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Student Code',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Student code is required.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Password is required.';
                      if (value.length < 8) return 'Password must contain at least 8 characters.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_reset_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please confirm your password.';
                      if (value != _passwordController.text) return 'Passwords do not match.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _register,
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: const Text('Register'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final role = await _loadUserRole(credential.user!.uid);
      if (role != 'admin') {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access denied. Only admin accounts can access this panel.')),
        );
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AdminDashboardScreen(user: credential.user!)),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = firebaseErrorMessage(e, action: 'Admin login');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(firebaseErrorMessage(e, action: 'Admin login')),
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'Authorized Admin Access',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use the admin Google account assigned to the platform.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Admin Email',
                      prefixIcon: Icon(Icons.email_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Admin email is required.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Password is required.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.admin_panel_settings_rounded),
                          label: const Text('Continue to Admin Dashboard'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

class StudentHomePage extends StatelessWidget {
  final User user;

  const StudentHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.indigo,
                child: Text(
                  (user.displayName ?? 'S').substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back,', style: TextStyle(color: Colors.black54)),
                    Text(
                      user.displayName ?? 'Student',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Your learning streak is growing!', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text('4-day streak', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text('Keep going to unlock your next milestone.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: const [
              _StatCard(title: 'Total Subjects', value: '4', color: Colors.indigo),
              _StatCard(title: 'Completed Lessons', value: '12', color: Colors.green),
              _StatCard(title: 'Learning Progress', value: '72%', color: Colors.orange),
              _StatCard(title: 'Quiz Scores', value: '88%', color: Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recommended lessons', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._recommendedLessons.map(
            (lesson) => Card(
              child: ListTile(
                leading: const Icon(Icons.play_circle_fill_rounded, color: Colors.indigo),
                title: Text(lesson['title'] as String),
                subtitle: Text(lesson['subject'] as String),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<Map<String, String>> _recommendedLessons = [
  {'title': 'English Basics - Vocabulary Practice', 'subject': 'English Basic'},
  {'title': 'Computer Basics - Internet Safety', 'subject': 'Computer Basic'},
  {'title': 'Mathematics Basics - Fractions Review', 'subject': 'Mathematics Basic'},
  {'title': 'Programming Basics - Variables and Data Types', 'subject': 'Programming Basic'},
];

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class SubjectListPage extends StatelessWidget {
  final List<SubjectModel> subjects = [
    SubjectModel('English Basic', 'Build vocabulary, grammar, and reading confidence.', 4, 68),
    SubjectModel('Computer Basic', 'Learn hardware, software, and digital safety basics.', 5, 74),
    SubjectModel('Mathematics Basic', 'Practice arithmetic, fractions, and problem solving.', 3, 82),
    SubjectModel('Programming Basic', 'Start coding with logic, variables, and loops.', 4, 60),
  ];

  SubjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: subjects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(subject.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Chip(label: Text('${subject.lessons} lessons')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(subject.description, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: subject.progress / 100),
                const SizedBox(height: 8),
                Text('${subject.progress}% completed', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SubjectModel {
  final String name;
  final String description;
  final int lessons;
  final int progress;

  const SubjectModel(this.name, this.description, this.lessons, this.progress);
}

class LessonsPage extends StatelessWidget {
  final List<Map<String, String>> lessons = const [
    {'title': 'Vocabulary Essentials', 'subject': 'English Basic', 'time': '15 mins'},
    {'title': 'Computer Safety', 'subject': 'Computer Basic', 'time': '20 mins'},
    {'title': 'Working with Fractions', 'subject': 'Mathematics Basic', 'time': '18 mins'},
    {'title': 'Variables in Programming', 'subject': 'Programming Basic', 'time': '25 mins'},
  ];

  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.play_arrow_rounded),
            ),
            title: Text(lesson['title']!),
            subtitle: Text('${lesson['subject']} • ${lesson['time']}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${lesson['title']}')),
              );
            },
          ),
        );
      },
    );
  }
}

class QuizzesPage extends StatelessWidget {
  final List<Map<String, dynamic>> quizzes = const [
    {'title': 'English Quiz 1', 'score': '90%', 'status': 'Ready'},
    {'title': 'Computer Quiz 1', 'score': '85%', 'status': 'Ready'},
    {'title': 'Math Quiz 1', 'score': '92%', 'status': 'Completed'},
    {'title': 'Programming Quiz 1', 'score': '78%', 'status': 'Ready'},
  ];

  const QuizzesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.quiz_rounded, color: Colors.deepPurple),
            title: Text(quiz['title'] as String),
            subtitle: Text('Score: ${quiz['score']}'),
            trailing: Chip(label: Text(quiz['status'] as String)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Starting ${quiz['title']}')),
              );
            },
          ),
        );
      },
    );
  }
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final progresses = [
      {'label': 'English', 'value': 0.8},
      {'label': 'Computer', 'value': 0.72},
      {'label': 'Mathematics', 'value': 0.9},
      {'label': 'Programming', 'value': 0.64},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Progress Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...progresses.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item['label']} • ${(item['value'] as double) * 100 ~/ 1}%'),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: item['value'] as double),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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

class SettingsPage extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsPage({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Email notifications'),
          subtitle: const Text('Receive updates on lessons and quizzes.'),
          value: true,
          onChanged: (_) {},
        ),
        SwitchListTile(
          title: const Text('Dark mode'),
          subtitle: const Text('Focus better at night.'),
          value: false,
          onChanged: (_) {},
        ),
        ListTile(
          leading: const Icon(Icons.language_rounded),
          title: const Text('Preferred language'),
          subtitle: const Text('English'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Language preference saved successfully.')),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: onLogout,
        ),
      ],
    );
  }
}

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
                  _StatCard(title: 'Students', value: '120', color: Colors.indigo),
                  _StatCard(title: 'Subjects', value: '4', color: Colors.green),
                  _StatCard(title: 'Lessons', value: '18', color: Colors.orange),
                  _StatCard(title: 'Quizzes', value: '12', color: Colors.purple),
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
