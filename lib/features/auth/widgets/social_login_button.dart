// lib/features/auth/widgets/social_login_button.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: FaIcon(icon, color: foregroundColor),
      label: Text(
        label,
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
