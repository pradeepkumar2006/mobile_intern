import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // User 5-Color Palette (#374442, #7BB9B3, #A0CFC9, #BFDCD4, #D6EDE9)
  static const Color pineDark = Color(0xFF374442);    // #374442 Deep Charcoal Pine
  static const Color seafoamTeal = Color(0xFF7BB9B3); // #7BB9B3 Seafoam Teal
  static const Color softMint = Color(0xFFA0CFC9);    // #A0CFC9 Soft Mint
  static const Color paleMint = Color(0xFFBFDCD4);    // #BFDCD4 Pale Mint Mist
  static const Color iceMint = Color(0xFFD6EDE9);     // #D6EDE9 Ultra-light Ice Mint

  // Primary Brand Mappings
  static const Color primary = seafoamTeal;
  static const Color primaryDark = pineDark;
  static const Color primaryLight = softMint;

  // Typography & Content
  static const Color brandNavy = pineDark;
  static const Color textPrimary = pineDark;
  static const Color textSecondary = Color(0xFF5A6B68);
  static const Color textMuted = Color(0xFF8A9C98);
  static const Color error = Color(0xFFDC2626);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF4FAF8);
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color cardTint = iceMint;

  // UI Accents
  static const Color borderLight = Color(0xFFD8E8E4);
  static const Color shadowColor = Color(0x1A374442);

  // Exact Vertical Gradient from User's Image 3
  // Top: #4C6D68 -> Mid: #5E8B85 -> Bottom: #73ACA6
  static const LinearGradient brandGradient = LinearGradient(
    colors: [
      Color(0xFF4C6D68), // Rich Dark Sage-Pine (Top)
      Color(0xFF5E8B85), // Smooth Mid Tone
      Color(0xFF73ACA6), // Fresh Seafoam Teal (Bottom)
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      Color(0xFF73ACA6),
      Color(0xFF374442),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Modern Color Gradient Palette for Booking Workflow & High-Impact UI
  static const LinearGradient gradientEmeraldTeal = LinearGradient(
    colors: [
      Color(0xFF0F766E), // Deep Teal
      Color(0xFF0D9488), // Sea Teal
      Color(0xFF10B981), // Glowing Emerald
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientSunsetAmber = LinearGradient(
    colors: [
      Color(0xFFEA580C), // Deep Coral Orange
      Color(0xFFF59E0B), // Radiant Amber
      Color(0xFFFBBF24), // Golden Yellow
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientCyberCyan = LinearGradient(
    colors: [
      Color(0xFF0284C7), // Sky Azure
      Color(0xFF06B6D4), // Cyan Neon
      Color(0xFF14B8A6), // Seafoam Bright
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientVioletIndigo = LinearGradient(
    colors: [
      Color(0xFF4338CA), // Deep Indigo
      Color(0xFF6366F1), // Royal Violet
      Color(0xFF818CF8), // Soft Lilac
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientRosePink = LinearGradient(
    colors: [
      Color(0xFFBE123C), // Deep Crimson Rose
      Color(0xFFF43F5E), // Vibrant Coral Pink
      Color(0xFFFB7185), // Soft Rose
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientDarkGlass = LinearGradient(
    colors: [
      Color(0xFF1E2E2B), // Deep Pine Noir
      Color(0xFF2B443F), // Mid Dusk Pine
      Color(0xFF1E2E2B), // Deep Pine Noir
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientCardSelected = LinearGradient(
    colors: [
      Color(0xFFE8F7F3),
      Color(0xFFF4FAF8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
