import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../widgets/role_selection_button.dart';
import '../widgets/trylo_logo.dart';
import 'main_navigation_screen.dart';
import 'user_auth_screen.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  static const String _maleAvatarUrl =
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&auto=format&fit=crop&q=80';
  static const String _femaleAvatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80';

  void _navigateToAuth(BuildContext context, {required bool isSignUp}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserAuthScreen(initialIsSignUp: isSignUp),
      ),
    );
  }

  void _handleJoinCreator(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        // Exact Vertical Gradient from User's Image (#4C6D68 -> #5E8B85 -> #73ACA6)
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradient,
        ),
        child: Stack(
          children: [
            // Top right ambient curve
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            // Bottom left organic curve
            Positioned(
              bottom: 40,
              left: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.12),
                ),
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Bar: Trylo brand pill & Community badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0x33FFFFFF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const TryloLogo(
                                    iconSize: 20,
                                    fontSize: 16,
                                    spacing: 6,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0x22FFFFFF),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0x33FFFFFF)),
                                  ),
                                  child: Text(
                                    'Dating & Community',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.iceMint,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Dual Overlapping Match Avatars + 100% Match Floating Badge
                            SizedBox(
                              width: 270,
                              height: 190,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Left Avatar (Guy)
                                  Positioned(
                                    left: 10,
                                    top: 10,
                                    child: _buildAvatar(_maleAvatarUrl, size: 135),
                                  ),

                                  // Right Avatar (Girl)
                                  Positioned(
                                    right: 10,
                                    bottom: 0,
                                    child: _buildAvatar(_femaleAvatarUrl, size: 135),
                                  ),

                                  // "100% Match" Floating Badge
                                  Positioned(
                                    top: 24,
                                    right: 68,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFC4B5FD), // Lavender
                                            Color(0xFFA78BFA),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x33A78BFA),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '100% Match',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Main Headline & Subtitle
                            Column(
                              children: [
                                Text(
                                  'Find your preferences\npartners',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.6,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Join us with other millions of people\nand find your best matches',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: AppColors.iceMint,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // Bottom Action Section: 2 Clean Buttons (No Icons) + Log In Link
                            Column(
                              children: [
                                // Button 1: Join as Creator (Clean White Pill)
                                RoleSelectionButton(
                                  text: 'Join as Creator',
                                  style: RoleButtonStyle.primary,
                                  onPressed: () => _handleJoinCreator(context),
                                ),

                                const SizedBox(height: 12),

                                // Button 2: Join as User (Clean Translucent Frosted Pill)
                                RoleSelectionButton(
                                  text: 'Join as User',
                                  style: RoleButtonStyle.secondary,
                                  onPressed: () => _navigateToAuth(context, isSignUp: true),
                                ),

                                const SizedBox(height: 12),

                                // Already have an account link
                                TextButton(
                                  onPressed: () => _navigateToAuth(context, isSignUp: false),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white.withValues(alpha: 0.85),
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                  ),
                                  child: Text(
                                    'Already have an account? Log In',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.iceMint,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String url, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppColors.iceMint,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.seafoamTeal),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.iceMint,
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.seafoamTeal,
                size: 48,
              ),
            );
          },
        ),
      ),
    );
  }
}
