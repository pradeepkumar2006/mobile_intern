import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/services/wallet_service.dart';
import '../screens/active_call_screen.dart';
import 'add_funds_bottom_sheet.dart';

/// The 7-Step Booking Workflow Modal Steps (PDF Page 10 & 11)
enum BookingModalStep {
  serviceSelection,   // Step A & B: Service selection & real-time balance check
  waitingForCreator,  // Step C & D: Money reserved in escrow & 60s acceptance timer
  creatorAccepted,    // Step E: Creator accepted -> launch active session
  cancelledOrRefunded // Step F: Timeout/declined -> Requirement #7 automatic refund
}

class BookingWorkflowModal extends StatefulWidget {
  final Map<String, dynamic> creator;
  final int initialServiceIndex;
  final ValueChanged<int>? onNavigateTab;

  const BookingWorkflowModal({
    super.key,
    required this.creator,
    this.initialServiceIndex = 2, // Default to Video Call
    this.onNavigateTab,
  });

  /// Helper to open modal as high-end bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> creator,
    int initialServiceIndex = 2,
    ValueChanged<int>? onNavigateTab,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BookingWorkflowModal(
        creator: creator,
        initialServiceIndex: initialServiceIndex,
        onNavigateTab: onNavigateTab,
      ),
    );
  }

  @override
  State<BookingWorkflowModal> createState() => _BookingWorkflowModalState();
}

class _BookingWorkflowModalState extends State<BookingWorkflowModal>
    with TickerProviderStateMixin {
  late int _selectedServiceIndex;
  BookingModalStep _currentStep = BookingModalStep.serviceSelection;

  // 60-Second Acceptance Timer (Step D)
  static const int _totalWaitSeconds = 60;
  int _secondsRemaining = _totalWaitSeconds;
  Timer? _countdownTimer;

  // Pulse & Ripple animation controllers for radar ring
  late AnimationController _pulseController;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _pulseOpacityAnimation;

  // Spotlight Services matching PDF specification
  final List<Map<String, dynamic>> _services = [
    {
      'id': 'chat',
      'title': 'Chat Session',
      'price': 150.0,
      'duration': '30 Mins Chat',
      'description': 'Direct private messaging with instant media sharing',
      'icon': Icons.chat_bubble_rounded,
      'type': 'chat',
      'badge': 'Instant Connect',
      'gradient': AppColors.gradientVioletIndigo,
      'accentColor': const Color(0xFF6366F1),
    },
    {
      'id': 'voice_call',
      'title': 'Voice Call',
      'price': 300.0,
      'duration': 'Per 15 Min Session',
      'description': 'Private 1-on-1 real-time voice call interaction',
      'icon': Icons.phone_in_talk_rounded,
      'type': 'voice',
      'badge': 'High Quality Audio',
      'gradient': AppColors.gradientCyberCyan,
      'accentColor': const Color(0xFF06B6D4),
    },
    {
      'id': 'video_call',
      'title': 'Video Call (10 Minutes)',
      'price': 500.0,
      'duration': '10 Minutes HD',
      'description': 'Private 1-on-1 live HD video call interaction',
      'icon': Icons.videocam_rounded,
      'type': 'video',
      'badge': 'Most Popular',
      'gradient': AppColors.gradientRosePink,
      'accentColor': const Color(0xFFF43F5E),
    },
    {
      'id': 'photo',
      'title': 'Paid Photo',
      'price': 200.0,
      'duration': 'High-Res Photo',
      'description': 'Personalized private photo message sent directly to you',
      'icon': Icons.image_rounded,
      'type': 'photo',
      'badge': 'Private Media',
      'gradient': AppColors.gradientSunsetAmber,
      'accentColor': const Color(0xFFF59E0B),
    },
    {
      'id': 'video_clip',
      'title': 'Paid Video Greeting',
      'price': 400.0,
      'duration': '1 Minute Custom',
      'description': 'Recorded custom personalized video greeting & message',
      'icon': Icons.video_library_rounded,
      'type': 'video_clip',
      'badge': 'Custom Clip',
      'gradient': AppColors.gradientEmeraldTeal,
      'accentColor': const Color(0xFF10B981),
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedServiceIndex =
        widget.initialServiceIndex.clamp(0, _services.length - 1);

    // Pulse animation for waiting radar ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );

    _pulseOpacityAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  double get _selectedCost => _services[_selectedServiceIndex]['price'] as double;
  String get _selectedServiceTitle => _services[_selectedServiceIndex]['title'] as String;
  String get _selectedServiceType => _services[_selectedServiceIndex]['type'] as String;

  // -------------------------------------------------------------
  // Step D Timer Logic
  // -------------------------------------------------------------
  void _startWaitingTimer() {
    _secondsRemaining = _totalWaitSeconds;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _handleDeclineOrTimeout(reason: 'Timeout (60s expired)');
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  // -------------------------------------------------------------
  // Step C: Money Reservation ("Session Hold")
  // -------------------------------------------------------------
  Future<void> _handleConfirmAndReserve() async {
    final wallet = WalletService.instance;
    final cost = _selectedCost;
    final creatorName = widget.creator['name'] as String? ?? 'Creator';

    if (wallet.availableBalance < cost) {
      final shortfall = cost - wallet.availableBalance;
      _openAddFundsSheet(shortfall);
      return;
    }

    // Hold funds in Escrow
    final success = await wallet.holdForBooking(
      amount: cost,
      sessionTitle: '$_selectedServiceTitle with $creatorName',
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _currentStep = BookingModalStep.waitingForCreator;
      });
      _pulseController.repeat();
      _startWaitingTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to reserve funds. Please check wallet balance.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // -------------------------------------------------------------
  // Step B: Insufficient Balance -> Auto open Razorpay Add Money Sheet
  // -------------------------------------------------------------
  void _openAddFundsSheet(double shortfall) {
    AddFundsBottomSheet.show(
      context,
      initialAmount: shortfall,
      onDepositSuccess: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  // -------------------------------------------------------------
  // Step E: Creator Accepts the Request
  // -------------------------------------------------------------
  void _handleCreatorAccept() {
    _countdownTimer?.cancel();
    _pulseController.stop();
    setState(() {
      _currentStep = BookingModalStep.creatorAccepted;
    });

    // Celebration animation delay then launch session
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      Navigator.pop(context); // Close modal sheet

      if (_selectedServiceType == 'video') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ActiveCallScreen(
              creator: widget.creator,
              isVideoCall: true,
              sessionCost: _selectedCost,
              serviceTitle: _selectedServiceTitle,
            ),
          ),
        );
      } else if (_selectedServiceType == 'voice') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ActiveCallScreen(
              creator: widget.creator,
              isVideoCall: false,
              sessionCost: _selectedCost,
              serviceTitle: _selectedServiceTitle,
            ),
          ),
        );
      } else {
        // Chat or Media: Switch to messages tab
        widget.onNavigateTab?.call(1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.mark_chat_read_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Chat session connected with ${widget.creator['name']}!',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700),
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
    });
  }

  // -------------------------------------------------------------
  // Step F: Creator Declines, 60s Timeout, or User Cancels -> Automatic Refund (Req #7)
  // -------------------------------------------------------------
  Future<void> _handleDeclineOrTimeout({String reason = 'Creator declined'}) async {
    _countdownTimer?.cancel();
    _pulseController.stop();
    final wallet = WalletService.instance;
    final cost = _selectedCost;
    final creatorName = widget.creator['name'] as String? ?? 'Creator';

    await wallet.refundReservedBooking(
      amount: cost,
      sessionTitle: '$_selectedServiceTitle with $creatorName',
    );

    if (!mounted) return;

    setState(() {
      _currentStep = BookingModalStep.cancelledOrRefunded;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: const Icon(Icons.currency_rupee_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$reason. ₹${cost.toInt()} automatically refunded to your Available Balance.',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pineDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return ListenableBuilder(
      listenable: WalletService.instance,
      builder: (context, _) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing gradient drag handle bar
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 48,
                  height: 4.5,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientEmeraldTeal,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Visual 4-Stage Booking Roadmap Stepper
              _buildWorkflowStageStepper(),

              // Animated Step Transition Content inside Flexible
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _buildCurrentStepWidget(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Visual 4-Stage Workflow Progress Stepper (PDF Page 10 & 11)
  Widget _buildWorkflowStageStepper() {
    int activeStage = 0;
    switch (_currentStep) {
      case BookingModalStep.serviceSelection:
        activeStage = 0;
        break;
      case BookingModalStep.waitingForCreator:
        activeStage = 1;
        break;
      case BookingModalStep.creatorAccepted:
        activeStage = 2;
        break;
      case BookingModalStep.cancelledOrRefunded:
        activeStage = 3;
        break;
    }

    final stages = [
      {'label': '1. Service', 'icon': Icons.tune_rounded},
      {'label': '2. Reserve', 'icon': Icons.lock_clock_rounded},
      {'label': '3. Waiting (60s)', 'icon': Icons.radar_rounded},
      {'label': activeStage == 3 ? '4. Refunded' : '4. Connect', 'icon': Icons.bolt_rounded},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF2F8F6),
            Color(0xFFE9F4F1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.paleMint.withValues(alpha: 0.6)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(stages.length, (index) {
          final isCurrent = index == activeStage;
          final isCompleted = index < activeStage;
          final s = stages[index];

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: isCurrent
                      ? AppColors.gradientEmeraldTeal
                      : isCompleted
                          ? const LinearGradient(
                              colors: [Color(0xFF0D9488), Color(0xFF10B981)],
                            )
                          : null,
                  color: isCurrent || isCompleted ? null : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle_rounded : (s['icon'] as IconData),
                      size: 13,
                      color: isCurrent || isCompleted
                          ? Colors.white
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s['label'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: isCurrent || isCompleted
                            ? Colors.white
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < stages.length - 1) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 9,
                  color: isCompleted ? const Color(0xFF0D9488) : AppColors.borderLight,
                ),
                const SizedBox(width: 4),
              ],
            ],
          );
        }),
      ),
    ),
  );
}

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case BookingModalStep.serviceSelection:
        return _buildServiceSelectionStep();
      case BookingModalStep.waitingForCreator:
        return _buildWaitingStateStep();
      case BookingModalStep.creatorAccepted:
        return _buildAcceptedStep();
      case BookingModalStep.cancelledOrRefunded:
        return _buildRefundedStep();
    }
  }

  // -------------------------------------------------------------
  // Step A & B: Service Selection & Real-Time Wallet Balance Check
  // -------------------------------------------------------------
  Widget _buildServiceSelectionStep() {
    final wallet = WalletService.instance;
    final cost = _selectedCost;
    final hasSufficientBalance = wallet.availableBalance >= cost;
    final shortfall = cost - wallet.availableBalance;
    final creatorName = widget.creator['name'] as String? ?? 'Creator';
    final creatorImage = widget.creator['avatar'] as String? ??
        widget.creator['image'] as String? ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200';
    final profession = widget.creator['profession'] as String? ?? 'Verified Creator';
    final rating = widget.creator['rating']?.toString() ?? '4.9';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      key: const ValueKey('step_selection'),
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.of(context).viewInsets.bottom + 26,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modal Header Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confirm Booking Request',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.pineDark,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textMuted, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Header: Creator Mini Banner with Rich Gradient Frame
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E3A34),
                  Color(0xFF2D554D),
                  Color(0xFF1E3A34),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x241E3A34),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Creator Avatar with Animated Gradient Ring
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradientCyberCyan,
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(creatorImage),
                  ),
                ),
                const SizedBox(width: 12),

                // Creator Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              creatorName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              size: 16, color: Color(0xFF14B8A6)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profession,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFFD6EDE9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating & Close Button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientSunsetAmber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Step A Section Title: Service Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Step A: Select Service Mode',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.pineDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Core Engine (PDF P.10)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F766E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Vertical list of services with Color Gradients
          ...List.generate(_services.length, (index) {
            final s = _services[index];
            final isSelected = _selectedServiceIndex == index;
            final LinearGradient serviceGrad = s['gradient'] as LinearGradient;
            final Color accent = s['accentColor'] as Color;

            return GestureDetector(
              onTap: () => setState(() => _selectedServiceIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF2FBF8) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? accent : AppColors.borderLight,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          const BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    // Gradient Icon Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: isSelected ? serviceGrad : null,
                        color: isSelected ? null : const Color(0xFFF2F7F6),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        s['icon'] as IconData,
                        color: isSelected ? Colors.white : AppColors.pineDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Service Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        s['title'] as String,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.pineDark,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: accent.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          s['badge'] as String,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: accent,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹${(s['price'] as double).toInt()}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected ? accent : AppColors.pineDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            s['description'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Duration: ${s['duration']}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                isSelected ? 'Active Selection ✓' : 'Tap to select',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? accent : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Radio Check Pill
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isSelected ? serviceGrad : null,
                        color: isSelected ? null : AppColors.borderLight,
                      ),
                      child: Icon(
                        isSelected
                            ? Icons.check_rounded
                            : Icons.circle,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // -----------------------------------------------------------
          // Step B: Real-Time Wallet Balance Check Box (Gradient Glass)
          // -----------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasSufficientBalance
                    ? [
                        const Color(0xFFF0FDF9),
                        const Color(0xFFE6F7F3),
                      ]
                    : [
                        const Color(0xFFFEF2F2),
                        const Color(0xFFFEE2E2),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: hasSufficientBalance
                    ? const Color(0xFF6EE7B7)
                    : const Color(0xFFFCA5A5),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasSufficientBalance
                      ? const Color(0x1210B981)
                      : const Color(0x12EF4444),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with step label & status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 18,
                            color: hasSufficientBalance
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Step B: Real-Time Wallet Check',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: hasSufficientBalance
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF991B1B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: hasSufficientBalance
                            ? AppColors.gradientEmeraldTeal
                            : AppColors.gradientSunsetAmber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        hasSufficientBalance ? 'Sufficient Balance ✓' : 'Low Balance',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Breakdown: Selected Service Cost vs User Available Balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Service',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$_selectedServiceTitle (₹${cost.toInt()})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.pineDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Wallet Balance',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${wallet.availableBalance.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: hasSufficientBalance
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),

                if (!hasSufficientBalance) ...[
                  const Divider(height: 16, color: Color(0xFFFECACA)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shortfall Required:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      Text(
                        '₹${shortfall.ceil()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // -----------------------------------------------------------
          // Step C: Money Reservation ("Session Hold") Notice
          // -----------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFFBEB),
                  Color(0xFFFEF3C7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_rounded,
                      size: 14, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step C: Escrow Session Hold (Requirement #7)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'This ₹${cost.toInt()} will be locked in your Reserved Balance. If creator declines or session is cancelled, it is automatically refunded.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: const Color(0xFF78350F),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // -----------------------------------------------------------
          // Dynamic Action CTA Button: Confirm & Reserve vs Add Money
          // -----------------------------------------------------------
          if (hasSufficientBalance) ...[
            // Sufficient Balance -> Gradient "Confirm & Reserve Amount" Button
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.gradientEmeraldTeal,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4010B981),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _handleConfirmAndReserve,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Confirm & Reserve ₹${cost.toInt()} in Hold',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 18, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Insufficient Balance -> Gradient "Add ₹X to Wallet" Button (Razorpay)
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.gradientSunsetAmber,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40EA580C),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _openAddFundsSheet(shortfall),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_card_rounded,
                        size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Add ₹${shortfall.ceil()} to Wallet (Razorpay UPI)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.open_in_new_rounded,
                        size: 16, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Step D: Creator Acceptance Waiting State (60s Timer & Gradient Radar)
  // -------------------------------------------------------------
  Widget _buildWaitingStateStep() {
    final creatorName = widget.creator['name'] as String? ?? 'Creator';
    final creatorImage = widget.creator['avatar'] as String? ??
        widget.creator['image'] as String? ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200';
    final cost = _selectedCost;
    final progress = _secondsRemaining / _totalWaitSeconds;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      key: const ValueKey('step_waiting'),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step D Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.gradientCyberCyan,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3006B6D4),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.radar_rounded, size: 15, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'Step D: Creator Acceptance Engine',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Header Text
          Text(
            'Request Sent to Creator...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.pineDark,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Waiting for acceptance (60s timer)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),

          // -----------------------------------------------------------
          // Multi-Layer Animated Radar Rings & Creator Avatar Center
          // -----------------------------------------------------------
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Pulsing Ripple Wave 1
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseScaleAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: _pulseOpacityAnimation.value),
                          width: 2.5,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Glowing Multi-stop Radial Gradient Background
              Container(
                width: 134,
                height: 134,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0D9488).withValues(alpha: 0.22),
                      const Color(0xFF06B6D4).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                ),
              ),

              // Circular Countdown Progress Arc with Gradient Look
              SizedBox(
                width: 114,
                height: 114,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5.5,
                  backgroundColor: AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.35
                        ? const Color(0xFF0D9488)
                        : const Color(0xFFEA580C),
                  ),
                ),
              ),

              // Creator Avatar Centerpiece
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.gradientEmeraldTeal,
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundImage: NetworkImage(creatorImage),
                ),
              ),

              // 60s Countdown Capsule Floating Badge
              Positioned(
                bottom: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: progress > 0.35
                        ? AppColors.gradientEmeraldTeal
                        : AppColors.gradientSunsetAmber,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${_secondsRemaining}s',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // -----------------------------------------------------------
          // Escrow Session Hold Status Card (Requirement #7 Banner)
          // -----------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF0FDF4),
                  Color(0xFFE6F7F3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6EE7B7)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradientEmeraldTeal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${cost.toInt()} Locked in Escrow Hold',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.pineDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Alert sent to $creatorName. If declined or timed out, 100% instant refund to Available Balance.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // -----------------------------------------------------------
          // Simulation Controls: Cancel / Accept / Decline
          // -----------------------------------------------------------
          Row(
            children: [
              // User Cancel Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _handleDeclineOrTimeout(reason: 'Request cancelled by you'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Cancel Request',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Simulate Creator Accept Button
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientEmeraldTeal,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3010B981),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _handleCreatorAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Simulate Accept',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Simulate Creator Decline Button (Quick Test for Requirement #7 Refund)
          TextButton.icon(
            onPressed: () =>
                _handleDeclineOrTimeout(reason: 'Creator was currently busy'),
            icon: const Icon(Icons.cancel_outlined,
                size: 16, color: AppColors.error),
            label: Text(
              'Simulate Creator Decline (Test Req #7 Refund)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Step E: Acceptance Celebration Transition
  // -------------------------------------------------------------
  Widget _buildAcceptedStep() {
    final creatorName = widget.creator['name'] as String? ?? 'Creator';

    return Padding(
      key: const ValueKey('step_accepted'),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 42),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradientEmeraldTeal,
              boxShadow: [
                BoxShadow(
                  color: Color(0x4010B981),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 46),
          ),
          const SizedBox(height: 22),
          Text(
            'Request Accepted!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.pineDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$creatorName accepted your $_selectedServiceTitle. Connecting secure session now...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Step F: Declined / Timeout / Refunded State (Requirement #7)
  // -------------------------------------------------------------
  Widget _buildRefundedStep() {
    final wallet = WalletService.instance;
    final cost = _selectedCost;

    return Padding(
      key: const ValueKey('step_refunded'),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradientCyberCyan,
              boxShadow: [
                BoxShadow(
                  color: Color(0x3006B6D4),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.currency_rupee_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 18),
          Text(
            '₹${cost.toInt()} Refunded to Wallet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.pineDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Per Requirement #7, the reserved session hold has been immediately returned to your Available Balance.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),

          // Refund Summary Gradient Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF0FDF4),
                  Color(0xFFE6F7F3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6EE7B7)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Refunded Amount:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '+₹${cost.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16, color: Color(0xFFA7F3D0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Updated Available Balance:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${wallet.availableBalance.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.pineDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Done CTA Button
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.gradientEmeraldTeal,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3010B981),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Done • Explore Other Creators',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
