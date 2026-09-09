import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/trylo_logo_data.dart';

/// Trylo Logo Lockup: Exact Brand Icon + Typography
class TryloLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final double spacing;

  const TryloLogo({
    super.key,
    this.iconSize = 58.0,
    this.fontSize = 42.0,
    this.spacing = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Trylo Squircle Heart-Arrow Icon from assets
        ClipRRect(
          borderRadius: BorderRadius.circular(iconSize * 0.22),
          child: Image.asset(
            'assets/images/trylo_icon.png',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (c, e, s) => Image.memory(
              TryloLogoData.bytes,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
          ),
        ),

        SizedBox(width: spacing),

        // Brand Name Text
        Text(
          'trylo',
          style: GoogleFonts.plusJakartaSans(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: AppColors.brandNavy,
            letterSpacing: -0.6,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
