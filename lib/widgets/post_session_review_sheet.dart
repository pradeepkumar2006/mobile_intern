import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/services/wallet_service.dart';

class PostSessionReviewSheet extends StatefulWidget {
  final Map<String, dynamic> creator;
  final String serviceTitle;
  final double sessionCost;
  final VoidCallback? onCompleted;

  const PostSessionReviewSheet({
    super.key,
    required this.creator,
    this.serviceTitle = 'Video Call Session',
    this.sessionCost = 500.0,
    this.onCompleted,
  });

  /// Helper to open as modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> creator,
    String serviceTitle = 'Video Call Session',
    double sessionCost = 500.0,
    VoidCallback? onCompleted,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PostSessionReviewSheet(
        creator: creator,
        serviceTitle: serviceTitle,
        sessionCost: sessionCost,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<PostSessionReviewSheet> createState() => _PostSessionReviewSheetState();
}

class _PostSessionReviewSheetState extends State<PostSessionReviewSheet> {
  int _selectedStars = 5;
  final TextEditingController _feedbackController = TextEditingController();

  final List<String> _quickTags = [
    'Polite Host',
    'Great Conversation',
    'Clear Audio',
    'Helpful Advice',
    'On Time',
    'Highly Recommended',
    'Respectful',
  ];

  final Set<String> _selectedTags = {'Polite Host', 'Great Conversation'};
  double _selectedTip = 0.0;
  bool _isSubmitting = false;

  final List<String> _starLabels = [
    'Tap to rate',
    'Needs Improvement',
    'Fair Experience',
    'Good Session',
    'Great Conversation',
    'Exceptional Experience! ⭐',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitFeedback() async {
    setState(() => _isSubmitting = true);

    // Tip deduction simulation if tip selected
    if (_selectedTip > 0) {
      final wallet = WalletService.instance;
      if (wallet.availableBalance >= _selectedTip) {
        await wallet.holdForBooking(
          amount: _selectedTip,
          sessionTitle: 'Creator Tip to ${widget.creator['name']}',
        );
      }
    }

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.pop(context);
    widget.onCompleted?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Thank you! Your $_selectedStars-star review was submitted for ${widget.creator['name']}.',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pineDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creatorName = widget.creator['name'] as String? ?? 'Creator';
    final creatorImage = widget.creator['image'] as String? ??
        widget.creator['avatar'] as String? ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing Gradient Drag Handle
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                gradient: AppColors.gradientEmeraldTeal,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Header with Creator Avatar & Session Finished Badge
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradientEmeraldTeal,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3310B981),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(creatorImage),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.gradientEmeraldTeal,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'Rate Your Session with $creatorName',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.pineDark,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.serviceTitle} • ₹${widget.sessionCost.toInt()} Settled',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),

            // -------------------------------------------------------------
            // Star Rating Selector (1 to 5 Stars) with Golden Glow
            // -------------------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNumber = index + 1;
                      final isSelected = starNumber <= _selectedStars;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedStars = starNumber),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 38,
                            color: isSelected
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFD1D5DB),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _starLabels[_selectedStars],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -------------------------------------------------------------
            // Quick Tag Chips (PDF Page 11 & 12)
            // -------------------------------------------------------------
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'What went well?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pineDark,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 7.5),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.gradientEmeraldTeal : null,
                      color: isSelected ? null : const Color(0xFFF4FAF8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF10B981)
                            : AppColors.borderLight,
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x2410B981),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.pineDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // -------------------------------------------------------------
            // Optional Written Review Text Box
            // -------------------------------------------------------------
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add a written review (Optional)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pineDark,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FCFA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: _feedbackController,
                maxLines: 3,
                maxLength: 250,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pineDark,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Share details about your interaction with $creatorName...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // -------------------------------------------------------------
            // Optional Tip to Host
            // -------------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded,
                        size: 15, color: Color(0xFFF43F5E)),
                    const SizedBox(width: 6),
                    Text(
                      'Send a Tip to Creator',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pineDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  _selectedTip > 0 ? '₹${_selectedTip.toInt()}' : 'Optional',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _selectedTip > 0
                        ? const Color(0xFF0D9488)
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [0.0, 50.0, 100.0, 200.0].map((amt) {
                final isSelected = _selectedTip == amt;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTip = amt),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppColors.gradientSunsetAmber
                            : null,
                        color: isSelected ? null : const Color(0xFFF4FAF8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF59E0B)
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          amt == 0 ? 'None' : '+₹${amt.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : AppColors.pineDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // -------------------------------------------------------------
            // Submit Feedback CTA Button
            // -------------------------------------------------------------
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.gradientEmeraldTeal,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3310B981),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 19, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTip > 0
                                ? 'Submit Feedback & Tip ₹${_selectedTip.toInt()}'
                                : 'Submit Feedback',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
