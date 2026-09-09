 import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SocialAuthType {
  google,
  apple,
}

class SocialAuthButton extends StatelessWidget {
  final SocialAuthType type;
  final VoidCallback onPressed;
  final bool isDark;

  const SocialAuthButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGoogle = type == SocialAuthType.google;
    final label = isGoogle ? 'Continue with Google' : 'Continue with Apple';

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isGoogle)
                  const _GoogleLogo(size: 20)
                else
                  Icon(
                    Icons.apple,
                    size: 24,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom vector drawing of official 4-color Google G logo
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final strokeWidth = w * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // Blue arc (Right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -math.pi / 4, math.pi / 2, false, paint);

    // Green arc (Bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, math.pi / 4, math.pi / 2, false, paint);

    // Yellow arc (Left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 3 * math.pi / 4, math.pi / 2, false, paint);

    // Red arc (Top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 5 * math.pi / 4, math.pi / 2, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTWH(
      w * 0.48,
      h / 2 - strokeWidth / 2,
      w * 0.52,
      strokeWidth,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
