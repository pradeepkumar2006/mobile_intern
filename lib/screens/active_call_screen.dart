import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/services/wallet_service.dart';
import '../widgets/add_funds_bottom_sheet.dart';
import '../widgets/post_session_review_sheet.dart';

enum NetworkQuality { strong, fair, weak }

class ActiveCallScreen extends StatefulWidget {
  final Map<String, dynamic> creator;
  final bool isVideoCall;
  final double sessionCost;
  final String serviceTitle;
  final int initialDurationSeconds;

  const ActiveCallScreen({
    super.key,
    required this.creator,
    this.isVideoCall = true,
    this.sessionCost = 500.0,
    this.serviceTitle = 'Video Call (10 Minutes)',
    this.initialDurationSeconds = 600, // 10 minutes default
  });

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen>
    with TickerProviderStateMixin {
  late int _secondsRemaining;
  late Timer _callCountdownTimer;

  // Call Controls State
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = true;
  bool _isFrontCamera = true;
  bool _isLowBandwidthMode = false;

  // Network Quality State
  NetworkQuality _networkQuality = NetworkQuality.strong;
  int _pingMs = 42;

  // Draggable PIP coordinates (for Video Call)
  Offset _pipPosition = const Offset(20, 80);

  // Pulse animations for Voice Call Avatar & Radar waves
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // Low Time Warning Alert dismiss
  bool _isLowTimeDismissed = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.initialDurationSeconds;

    // Countdown Timer (counts down to 0)
    _callCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _handleTimeExpired();
      } else {
        setState(() {
          _secondsRemaining--;

          // Dynamic network quality fluctuation simulation
          if (_secondsRemaining % 25 == 0) {
            _pingMs = 38 + (_secondsRemaining % 17);
            if (_pingMs > 50) {
              _networkQuality = NetworkQuality.fair;
            } else {
              _networkQuality = NetworkQuality.strong;
            }
          }
        });
      }
    });

    // Pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );

    _pulseOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _callCountdownTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  bool get _isLowTime => _secondsRemaining <= 120; // Last 2 minutes

  // -------------------------------------------------------------
  // Extend Session Flow (+5 Minutes for ₹150)
  // -------------------------------------------------------------
  Future<void> _handleExtendSession() async {
    const extendCost = 150.0;
    final wallet = WalletService.instance;
    final creatorName = widget.creator['name'] as String? ?? 'Creator';

    if (wallet.availableBalance < extendCost) {
      final shortfall = extendCost - wallet.availableBalance;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Need ₹${shortfall.ceil()} more to extend session.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Add Money',
            textColor: Colors.white,
            onPressed: () => AddFundsBottomSheet.show(
              context,
              initialAmount: shortfall,
              onDepositSuccess: () => setState(() {}),
            ),
          ),
        ),
      );
      return;
    }

    final success = await wallet.holdForBooking(
      amount: extendCost,
      sessionTitle: 'Session Extension (+5 mins with $creatorName)',
    );

    if (success && mounted) {
      setState(() {
        _secondsRemaining += 300; // Add 5 minutes (300s)
        _isLowTimeDismissed = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.add_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Session extended by +5 minutes! ₹${extendCost.toInt()} reserved.',
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0D9488),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  // -------------------------------------------------------------
  // Call End / Timeout Logic with Post-Session Review Sheet
  // -------------------------------------------------------------
  Future<void> _openReviewAndFinish() async {
    _callCountdownTimer.cancel();
    await PostSessionReviewSheet.show(
      context,
      creator: widget.creator,
      serviceTitle: widget.serviceTitle,
      sessionCost: widget.sessionCost,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleTimeExpired() {
    _openReviewAndFinish();
  }

  void _handleEndCall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFEE2E2),
              ),
              child: const Icon(Icons.call_end_rounded,
                  color: Color(0xFFDC2626), size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'End Active Session?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.pineDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to end this ${widget.isVideoCall ? 'video' : 'voice'} call with ${widget.creator['name']}? The session will be concluded and rating sheet will open.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Continue Call',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _openReviewAndFinish();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'End Session',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creatorName = widget.creator['name'] as String? ?? 'Creator';
    final creatorImage = widget.creator['image'] as String? ??
        widget.creator['avatar'] as String? ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800';

    return Scaffold(
      backgroundColor: const Color(0xFF131D1B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // -------------------------------------------------------------
          // 1. Background Content (Video Stream or Voice Ambient Gradient)
          // -------------------------------------------------------------
          if (widget.isVideoCall && _isVideoEnabled) ...[
            _buildVideoStream(creatorImage),
          ] else ...[
            _buildVoiceCallAmbient(creatorName, creatorImage),
          ],

          // -------------------------------------------------------------
          // 2. Draggable PIP Self Video Preview (for Video Call)
          // -------------------------------------------------------------
          if (widget.isVideoCall && _isVideoEnabled)
            _buildDraggablePipPreview(),

          // -------------------------------------------------------------
          // 3. Top Header Bar: Timer, Network Indicator, Minimize
          // -------------------------------------------------------------
          _buildTopHeaderBar(),

          // -------------------------------------------------------------
          // 4. Low Time Warning Banner (< 2 minutes remaining)
          // -------------------------------------------------------------
          if (_isLowTime && !_isLowTimeDismissed)
            _buildLowTimeWarningBanner(),

          // -------------------------------------------------------------
          // 5. Bottom Overlay Call Controls
          // -------------------------------------------------------------
          _buildBottomControlsOverlay(creatorName),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Full-Screen Video Stream View
  // -------------------------------------------------------------
  Widget _buildVideoStream(String creatorImage) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          creatorImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
            ),
            child: const Center(
              child: Icon(Icons.person, size: 80, color: Colors.white54),
            ),
          ),
        ),

        // Dark Gradient Scrim Overlay for Readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.75),
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.25, 0.7, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // Voice Call Screen with Animated Radial Gradient Pulsing Rings
  // -------------------------------------------------------------
  Widget _buildVoiceCallAmbient(String creatorName, String creatorImage) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1C2C29),
            Color(0xFF131E1C),
            Color(0xFF0F1816),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Multi-layer Pulsing Radar Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulsing Ring
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseScale.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: _pulseOpacity.value),
                            width: 2.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Radial Glow
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF0D9488).withValues(alpha: 0.35),
                        const Color(0xFF06B6D4).withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.3, 0.7, 1.0],
                    ),
                  ),
                ),

                // Avatar Container
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradientCyberCyan,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3306B6D4),
                        blurRadius: 20,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(creatorImage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Creator Name & Verification
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  creatorName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded,
                    size: 20, color: Color(0xFF14B8A6)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Encrypted 1-on-1 Voice Session Active',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFFD6EDE9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Audio Waveform Equalizer Bars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (index) {
                final heights = [14.0, 24.0, 36.0, 44.0, 30.0, 20.0, 12.0];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 4.5,
                  height: heights[index],
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientEmeraldTeal,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Draggable Picture-in-Picture (PIP) Self Video Preview
  // -------------------------------------------------------------
  Widget _buildDraggablePipPreview() {
    return Positioned(
      top: _pipPosition.dy,
      right: _pipPosition.dx,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _pipPosition = Offset(
              (_pipPosition.dx - details.delta.dx).clamp(16.0, 220.0),
              (_pipPosition.dy + details.delta.dy).clamp(60.0, 520.0),
            );
          });
        },
        child: Container(
          width: 105,
          height: 148,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: AppColors.gradientEmeraldTeal,
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFF1E2E2B)),
                const Center(
                  child: Icon(Icons.person,
                      size: 44, color: AppColors.seafoamTeal),
                ),
                Positioned(
                  bottom: 6,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'You',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _isFrontCamera = !_isFrontCamera),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black45,
                      ),
                      child: const Icon(Icons.flip_camera_ios_rounded,
                          size: 13, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Top Header Bar: Back, Countdown Timer, Network Signal Indicator
  // -------------------------------------------------------------
  Widget _buildTopHeaderBar() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Exit / Minimize Button
              CircleAvatar(
                radius: 19,
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                  onPressed: _handleEndCall,
                ),
              ),

              // Countdown Timer with Glowing Gradient Capsule
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: _isLowTime
                      ? AppColors.gradientSunsetAmber
                      : AppColors.gradientEmeraldTeal,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _isLowTime
                          ? const Color(0x40EA580C)
                          : const Color(0x3310B981),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(_secondsRemaining),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isLowTime ? '• Low Time' : '• Remaining',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Network Quality Signal Indicator
              _buildNetworkQualityIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Network Signal Indicator (Signal Bars & Low Bandwidth Toggle)
  // -------------------------------------------------------------
  Widget _buildNetworkQualityIndicator() {
    Color signalColor;
    String signalLabel;
    switch (_networkQuality) {
      case NetworkQuality.strong:
        signalColor = const Color(0xFF10B981);
        signalLabel = 'HD • $_pingMs ms';
        break;
      case NetworkQuality.fair:
        signalColor = const Color(0xFFF59E0B);
        signalLabel = 'Fair • $_pingMs ms';
        break;
      case NetworkQuality.weak:
        signalColor = const Color(0xFFEF4444);
        signalLabel = 'Weak';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 4-Bar Signal Indicator
          Row(
            children: List.generate(4, (index) {
              final barHeights = [4.0, 7.0, 10.0, 13.0];
              final isActive = _networkQuality == NetworkQuality.strong ||
                  (_networkQuality == NetworkQuality.fair && index < 3) ||
                  index == 0;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                width: 2.5,
                height: barHeights[index],
                decoration: BoxDecoration(
                  color: isActive
                      ? signalColor
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
          const SizedBox(width: 6),
          Text(
            _isLowBandwidthMode ? 'Lite Mode' : signalLabel,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Low Time Warning Banner (< 2 Minutes Remaining Quick Prompt)
  // -------------------------------------------------------------
  Widget _buildLowTimeWarningBanner() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 56, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppColors.gradientSunsetAmber,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44EA580C),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Session Ending Soon (${_formatDuration(_secondsRemaining)})',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Keep conversation going with creator.',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Extend Session Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: _handleExtendSession,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    '+5 Mins (₹150)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFC2410C),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white70, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _isLowTimeDismissed = true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Bottom Controls Overlay Bar: Camera, Mute, Reactions, End Call
  // -------------------------------------------------------------
  Widget _buildBottomControlsOverlay(String creatorName) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Floating Emoji Reactions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['❤️', '🔥', '✨', '👏', '💎'].map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$emoji reaction sent to $creatorName'),
                          duration: const Duration(milliseconds: 900),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.pineDark,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 17)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Controls Bar Container with Glassmorphism
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(32),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.14)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Microphone Toggle
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      label: _isMuted ? 'Unmute' : 'Mute',
                      isActive: !_isMuted,
                      onTap: () => setState(() => _isMuted = !_isMuted),
                    ),

                    // Video Camera Toggle (Video Call) or Speaker Toggle (Voice Call)
                    if (widget.isVideoCall) ...[
                      _buildControlButton(
                        icon: _isVideoEnabled
                            ? Icons.videocam_rounded
                            : Icons.videocam_off_rounded,
                        label: _isVideoEnabled ? 'Cam Off' : 'Cam On',
                        isActive: _isVideoEnabled,
                        onTap: () => setState(
                            () => _isVideoEnabled = !_isVideoEnabled),
                      ),
                      _buildControlButton(
                        icon: Icons.flip_camera_ios_rounded,
                        label: 'Flip',
                        isActive: true,
                        onTap: () => setState(
                            () => _isFrontCamera = !_isFrontCamera),
                      ),
                      _buildControlButton(
                        icon: _isLowBandwidthMode
                            ? Icons.data_saver_on_rounded
                            : Icons.hd_rounded,
                        label: _isLowBandwidthMode ? 'Lite' : 'HD',
                        isActive: !_isLowBandwidthMode,
                        onTap: () => setState(() =>
                            _isLowBandwidthMode = !_isLowBandwidthMode),
                      ),
                    ] else ...[
                      _buildControlButton(
                        icon: _isSpeakerOn
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        label: _isSpeakerOn ? 'Speaker' : 'Ear',
                        isActive: _isSpeakerOn,
                        onTap: () =>
                            setState(() => _isSpeakerOn = !_isSpeakerOn),
                      ),
                      _buildControlButton(
                        icon: Icons.graphic_eq_rounded,
                        label: 'HD Voice',
                        isActive: true,
                        onTap: () {},
                      ),
                    ],

                    // Red End Call Button
                    GestureDetector(
                      onTap: _handleEndCall,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x66DC2626),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Colors.white.withValues(alpha: 0.18)
                  : const Color(0xFFDC2626).withValues(alpha: 0.35),
              border: Border.all(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFDC2626),
                width: 1.2,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
