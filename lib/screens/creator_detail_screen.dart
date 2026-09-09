import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../widgets/booking_workflow_modal.dart';

class CreatorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> creator;
  final ValueChanged<int>? onNavigateTab;

  const CreatorDetailScreen({
    super.key,
    required this.creator,
    this.onNavigateTab,
  });

  @override
  State<CreatorDetailScreen> createState() => _CreatorDetailScreenState();
}

class _CreatorDetailScreenState extends State<CreatorDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  int _selectedServiceIndex = 3; // Default to Video Call (₹500)

  late final List<String> _mediaList;

  final List<Map<String, dynamic>> _services = [
    {
      'id': 'photo',
      'title': 'Paid Photo',
      'price': 200.0,
      'duration': 'Exclusive High-Res',
      'description': 'Personalized private photo message sent directly to you',
      'icon': Icons.image_rounded,
    },
    {
      'id': 'video',
      'title': 'Paid Video',
      'price': 400.0,
      'duration': '1 Minute Custom',
      'description': 'Recorded custom personalized video greeting & message',
      'icon': Icons.videocam_rounded,
    },
    {
      'id': 'voice_call',
      'title': 'Voice Call',
      'price': 300.0,
      'duration': 'Per 15 Min Session',
      'description': 'Private 1-on-1 real-time voice call interaction',
      'icon': Icons.phone_in_talk_rounded,
    },
    {
      'id': 'video_call',
      'title': 'Video Call (10 Minutes)',
      'price': 500.0,
      'duration': '10 Minutes HD',
      'description': 'Private 1-on-1 scheduled or instant live video interaction',
      'icon': Icons.video_call_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.creator['isSaved'] as bool? ?? false;
    final primaryImg = widget.creator['image'] as String? ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800';
    final avatarImg = widget.creator['avatar'] as String? ?? primaryImg;

    _mediaList = [
      primaryImg,
      avatarImg,
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
    ];
  }

  void _handleBookService() {
    BookingWorkflowModal.show(
      context,
      creator: widget.creator,
      initialServiceIndex: _selectedServiceIndex,
      onNavigateTab: widget.onNavigateTab,
    );
  }

  @override
  Widget build(BuildContext context) {
    final creator = widget.creator;
    final name = creator['name'] as String? ?? 'Creator';
    final age = creator['age']?.toString() ?? '22';
    final profession = creator['profession'] as String? ?? 'Digital Creator';
    final location = creator['location'] as String? ?? 'Mumbai, India';
    final bio = creator['bio'] as String? ??
        'Passionate creator sharing visual stories and private sessions.';
    final followers = creator['followers'] as String? ?? '120K';
    final rating = creator['rating'] as String? ?? '4.9';
    final tags = (creator['tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['Fashion', 'Art', 'Coffee'];

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFD),
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Photo Carousel with App Bar
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.pineDark,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: Icon(
                        _isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: _isFavorite ? const Color(0xFFEF4444) : Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _isFavorite = !_isFavorite);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: const Icon(Icons.share_outlined,
                          size: 18, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Profile link copied to clipboard',
                              style: GoogleFonts.plusJakartaSans(),
                            ),
                            backgroundColor: AppColors.pineDark,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Carousel
                      PageView.builder(
                        itemCount: _mediaList.length,
                        onPageChanged: (idx) =>
                            setState(() => _currentImageIndex = idx),
                        itemBuilder: (context, idx) {
                          return Image.network(
                            _mediaList[idx],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.pineDark,
                              child: const Icon(Icons.person,
                                  size: 100, color: AppColors.seafoamTeal),
                            ),
                          );
                        },
                      ),

                      // Gradient Overlay for smooth text readability
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0x66000000),
                                Colors.transparent,
                                Color(0xCC000000),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Online Status & Page Indicator
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Online Now',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Page Indicators
                            Row(
                              children: List.generate(_mediaList.length, (i) {
                                return Container(
                                  width: _currentImageIndex == i ? 18 : 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == i
                                        ? AppColors.seafoamTeal
                                        : Colors.white54,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Creator Profile Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name, Age & Verified Badge
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '$name, $age',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.pineDark,
                                      letterSpacing: -0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.verified_rounded,
                                    color: AppColors.seafoamTeal, size: 22),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.iceMint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFFD97706), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  rating,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.pineDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Profession & Location
                      Row(
                        children: [
                          Text(
                            profession,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.seafoamTeal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 2),
                          Text(
                            location,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Stats Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4FAF8),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Followers', followers),
                            Container(
                                width: 1,
                                height: 28,
                                color: AppColors.borderLight),
                            _buildStatItem('Reviews', '128 Reviews'),
                            Container(
                                width: 1,
                                height: 28,
                                color: AppColors.borderLight),
                            _buildStatItem('Response', 'Under 5m'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Spoken Languages
                      Text(
                        'Spoken Languages',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pineDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['English', 'Tamil', 'Hindi'].map((lang) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Text(
                              lang,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pineDark,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),

                      // Bio
                      Text(
                        'About Creator',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pineDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bio,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.iceMint.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '#$t',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pineDark,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 28),

                      // Service Rate Card (From PDF Page 10)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Service Rate Card',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.pineDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.iceMint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Platform Standard',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.pineDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 4 Service Cards
                      ...List.generate(_services.length, (idx) {
                        return _buildServiceCard(idx);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x141B2321),
                    blurRadius: 18,
                    offset: Offset(0, -4),
                  ),
                ],
                border: Border(
                  top: BorderSide(color: Color(0xFFE9F1EE), width: 1.0),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Chat Session Trigger Button
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          BookingWorkflowModal.show(
                            context,
                            creator: widget.creator,
                            initialServiceIndex: 0, // Chat session
                            onNavigateTab: widget.onNavigateTab,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.pineDark,
                          side: const BorderSide(
                              color: AppColors.seafoamTeal, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 18, color: AppColors.pineDark),
                        label: Text(
                          'Start Chat',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Connect Primary Gradient Button
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientEmeraldTeal,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3310B981),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _handleBookService,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.bolt_rounded,
                              size: 19, color: Colors.white),
                          label: Text(
                            'Book • ₹${(_services[_selectedServiceIndex]['price'] as double).toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.pineDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(int index) {
    final s = _services[index];
    final isSelected = _selectedServiceIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedServiceIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2F9F7) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.seafoamTeal : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0C7BB9B3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.pineDark : AppColors.iceMint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                s['icon'] as IconData,
                color: isSelected ? Colors.white : AppColors.pineDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pineDark,
                        ),
                      ),
                      Text(
                        '₹${(s['price'] as double).toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? AppColors.pineDark
                              : const Color(0xFF108E77),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['description'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.seafoamTeal : AppColors.borderLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
