import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/user_role_service.dart';
import '../../../core/utils/firebase_error_message.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';

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

      final role = await loadUserRole(credential.user!.uid);
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
                    'Use the admin email and password assigned to the platform.',
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
