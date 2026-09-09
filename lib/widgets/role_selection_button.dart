import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum RoleButtonStyle {
  primary,
  secondary,
}

class RoleSelectionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final RoleButtonStyle style;
  final IconData? icon;

  const RoleSelectionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = RoleButtonStyle.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = style == RoleButtonStyle.primary;

    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: isPrimary
            ? const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white : const Color(0x2EFFFFFF),
          foregroundColor: isPrimary ? const Color(0xFF1E293B) : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Color(0x55FFFFFF), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
