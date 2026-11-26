import 'package:flutter/material.dart';

import 'admin_login_screen.dart';
import 'auth_screen_frame.dart';
import 'student_login_screen.dart';
import 'student_register_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreenFrame(
      maxWidth: 480,
      title: 'Study Smart',
      subtitle: 'Learn anytime, grow every day, and track your progress.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ActionButton(
            label: 'Student Login',
            icon: Icons.login_rounded,
            style: _ActionButtonStyle.primary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StudentLoginScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: 'Student Register',
            icon: Icons.person_add_rounded,
            style: _ActionButtonStyle.outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StudentRegisterScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: 'Admin Login',
            icon: Icons.admin_panel_settings_rounded,
            style: _ActionButtonStyle.tonal,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
          ),
        ],
      ),
    );
  }
}

enum _ActionButtonStyle { primary, outlined, tonal }

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final _ActionButtonStyle style;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    final buttonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(56)),
      shape: WidgetStatePropertyAll(shape),
    );

    return switch (style) {
      _ActionButtonStyle.primary => FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: buttonStyle,
      ),
      _ActionButtonStyle.outlined => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: buttonStyle,
      ),
      _ActionButtonStyle.tonal => FilledButton.tonalIcon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: buttonStyle,
      ),
    };
  }
}
