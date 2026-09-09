import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../widgets/trylo_logo.dart';
import 'creator_detail_screen.dart';

class CreatorDiscoverScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const CreatorDiscoverScreen({super.key, this.onNavigateTab});

  @override
  State<CreatorDiscoverScreen> createState() => _CreatorDiscoverScreenState();
}

class _CreatorDiscoverScreenState extends State<CreatorDiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCountry = 'All Countries';
  String _selectedCategory = 'Featured';
  final List<String> _selectedLanguages = [];
  String _selectedGender = 'All';
  RangeValues _ageRange = const RangeValues(18, 50);
  bool _verifiedOnly = false;
  bool _onlineOnly = false;

  static const List<String> _countries = [
    'All Countries',
    'India',
    'Singapore',
    'UAE',
    'United Kingdom',
    'United States',
  ];

  static const List<String> _categories = [
    'Featured',
    'Top Rated',
    'Trending',
    'Recommended',
    'Live Now',
  ];

  static const List<String> _availableLanguages = [
    'Tamil',
    'English',
    'Hindi',
    'Telugu',
    'Malayalam',
    'Kannada',
  ];

  final List<Map<String, dynamic>> _stories = [
    {
      'name': 'Joe',
      'avatar':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&auto=format&fit=crop&q=80',
      'hasAdd': true,
      'caption': 'Exploring the coastal breeze today!',
    },
    {
      'name': 'Kim',
      'avatar':
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
      'hasAdd': false,
      'caption': 'Coffee dates and studio recordings',
    },
    {
      'name': 'Joyce',
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
      'hasAdd': false,
      'caption': 'Sunset golden hour vibes',
    },
    {
      'name': 'Ria',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
      'hasAdd': false,
      'caption': 'Behind the scenes of runway shoot',
    },
    {
      'name': 'Sophie',
      'avatar':
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&auto=format&fit=crop&q=80',
      'hasAdd': false,
      'caption': 'Weekend getaway ready!',
    },
    {
      'name': 'Arjun',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
      'hasAdd': false,
      'caption': 'Acoustic jam night starting soon',
    },
  ];

  final List<Map<String, dynamic>> _creators = [
    {
      'id': '1',
      'name': 'Olivia Fisher',
      'age': 20,
      'profession': 'Fashion Designer',
      'location': 'Bandra, Mumbai',
      'country': 'India',
      'distance': '3km',
      'image':
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&auto=format&fit=crop&q=80',
      'avatar':
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&auto=format&fit=crop&q=80',
      'caption':
          'Designing the new summer pastel collection. Coffee breaks and vintage boutique hopping in Bandra. Let us connect and spark creativity!',
      'bio':
          'Fashion designer and visual storyteller. Living between art galleries, vintage boutiques, and rooftop coffee shops.',
      'followers': '128K',
      'rating': '4.9',
      'reviewCount': 128,
      'likes': 1284,
      'comments': 48,
      'tags': ['Fashion', 'PastelAesthetic', 'Coffee', 'Art'],
      'categories': ['Featured', 'Trending', 'Recommended'],
      'languages': ['English', 'Tamil', 'Hindi'],
      'gender': 'Female',
      'isVerified': true,
      'isOnline': true,
      'isLiked': false,
      'isFollowing': false,
      'isSaved': false,
    },
    {
      'id': '2',
      'name': 'Maya Patel',
      'age': 22,
      'profession': 'Digital Creator & DJ',
      'location': 'Juhu Beach, Mumbai',
      'country': 'India',
      'distance': '5km',
      'image':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=80',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
      'caption':
          'Sunset rooftop session dropping tonight! Curating electronic beats and aesthetic lifestyle vlogs. Who is joining for the live set?',
      'bio':
          'Music producer, sunset chaser, and content creator. Spreading good energy and electronic rhythms.',
      'followers': '94K',
      'rating': '4.9',
      'reviewCount': 96,
      'likes': 2140,
      'comments': 86,
      'tags': ['Music', 'ElectronicBeats', 'DJ', 'Fitness'],
      'categories': ['Featured', 'Top Rated', 'Trending', 'Live Now'],
      'languages': ['English', 'Hindi', 'Tamil'],
      'gender': 'Female',
      'isVerified': true,
      'isOnline': true,
      'isLiked': true,
      'isFollowing': true,
      'isSaved': true,
    },
    {
      'id': '3',
      'name': 'Liam Vance',
      'age': 24,
      'profession': 'Editorial Photographer',
      'location': 'Colaba, Mumbai',
      'country': 'United Kingdom',
      'distance': '8km',
      'image':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&auto=format&fit=crop&q=80',
      'avatar':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&auto=format&fit=crop&q=80',
      'caption':
          'Golden hour raw portraits on 35mm film. The street colors in Mumbai during dusk are unmatched.',
      'bio':
          'Capturing raw emotions through analog 35mm film. Always down for spontaneous road trips and indie gigs.',
      'followers': '65K',
      'rating': '4.8',
      'reviewCount': 52,
      'likes': 890,
      'comments': 32,
      'tags': ['Photography', '35mm', 'StreetFilm', 'IndieRock'],
      'categories': ['Featured', 'Recommended'],
      'languages': ['English', 'French'],
      'gender': 'Male',
      'isVerified': true,
      'isOnline': false,
      'isLiked': false,
      'isFollowing': false,
      'isSaved': false,
    },
    {
      'id': '4',
      'name': 'Sophia Chen',
      'age': 21,
      'profession': 'Yoga & Wellness Coach',
      'location': 'Marine Drive, Mumbai',
      'country': 'Singapore',
      'distance': '4km',
      'image':
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&auto=format&fit=crop&q=80',
      'avatar':
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
      'caption':
          'Morning meditation and sunrise yoga flow. Finding peace and breath amidst the vibrant city pace. Breathe in calmness, breathe out doubts.',
      'bio':
          'Certified mindfulness and yoga instructor. Encouraging holistic living, plant-based smoothies, and mindful dating.',
      'followers': '112K',
      'rating': '5.0',
      'reviewCount': 142,
      'likes': 1650,
      'comments': 59,
      'tags': ['YogaFlow', 'Wellness', 'Mindfulness', 'HealthyLiving'],
      'categories': ['Featured', 'Top Rated', 'Trending', 'Live Now'],
      'languages': ['English', 'Tamil', 'Telugu'],
      'gender': 'Female',
      'isVerified': true,
      'isOnline': true,
      'isLiked': false,
      'isFollowing': false,
      'isSaved': false,
    },
    {
      'id': '5',
      'name': 'Arjun Mehta',
      'age': 23,
      'profession': 'Indie Musician & Songwriter',
      'location': 'Khar West, Mumbai',
      'country': 'India',
      'distance': '6km',
      'image':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&auto=format&fit=crop&q=80',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
      'caption':
          'Late night acoustic jam under city streetlights. Writing melodies about serendipity and warm chai. What song should I cover next?',
      'bio':
          'Acoustic indie singer-songwriter. Coffee enthusiast and lover of poetic lyricism.',
      'followers': '82K',
      'rating': '4.9',
      'reviewCount': 74,
      'likes': 1430,
      'comments': 74,
      'tags': ['IndieMusic', 'Acoustic', 'Songwriter', 'Vibes'],
      'categories': ['Featured', 'Trending', 'Top Rated'],
      'languages': ['Hindi', 'English', 'Punjabi'],
      'gender': 'Male',
      'isVerified': true,
      'isOnline': false,
      'isLiked': true,
      'isFollowing': true,
      'isSaved': false,
    },
    {
      'id': '6',
      'name': 'Elena Rostova',
      'age': 22,
      'profession': 'Travel & Culinary Storyteller',
      'location': 'Downtown Marina, Dubai',
      'country': 'UAE',
      'distance': '2km',
      'image':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&auto=format&fit=crop&q=80',
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
      'caption':
          'Exploring hidden street food alleys and capturing colorful stories. Anyone up for a sunset street food adventure?',
      'bio':
          'Full-time travel journalist and food curator. Visited 24 countries, seeking authentic local experiences.',
      'followers': '175K',
      'rating': '4.9',
      'reviewCount': 188,
      'likes': 3210,
      'comments': 142,
      'tags': ['TravelStory', 'Foodie', 'Wanderlust', 'StreetEats'],
      'categories': ['Featured', 'Recommended', 'Trending'],
      'languages': ['English', 'Tamil', 'Kannada'],
      'gender': 'Female',
      'isVerified': true,
      'isOnline': true,
      'isLiked': false,
      'isFollowing': false,
      'isSaved': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedCountry != 'All Countries') count++;
    if (_selectedCategory != 'Featured') count++;
    if (_selectedLanguages.isNotEmpty) count += _selectedLanguages.length;
    if (_selectedGender != 'All') count++;
    if (_ageRange.start > 18 || _ageRange.end < 50) count++;
    if (_verifiedOnly) count++;
    if (_onlineOnly) count++;
    if (_searchController.text.trim().isNotEmpty) count++;
    return count;
  }

  List<Map<String, dynamic>> get _filteredCreators {
    final query = _searchController.text.trim().toLowerCase();
    return _creators.where((creator) {
      // 1. Search Query Filter
      if (query.isNotEmpty) {
        final name = (creator['name'] as String? ?? '').toLowerCase();
        final profession = (creator['profession'] as String? ?? '').toLowerCase();
        final bio = (creator['bio'] as String? ?? '').toLowerCase();
        final location = (creator['location'] as String? ?? '').toLowerCase();
        final tags = ((creator['tags'] as List<dynamic>?) ?? [])
            .map((e) => e.toString().toLowerCase())
            .toList();
        final languages = ((creator['languages'] as List<dynamic>?) ?? [])
            .map((e) => e.toString().toLowerCase())
            .toList();

        final matchesName = name.contains(query);
        final matchesProfession = profession.contains(query);
        final matchesBio = bio.contains(query);
        final matchesLocation = location.contains(query);
        final matchesTags = tags.any((t) => t.contains(query));
        final matchesLangs = languages.any((l) => l.contains(query));

        if (!matchesName &&
            !matchesProfession &&
            !matchesBio &&
            !matchesLocation &&
            !matchesTags &&
            !matchesLangs) {
          return false;
        }
      }

      // 2. Country Filter
      if (_selectedCountry != 'All Countries') {
        final country = creator['country'] as String? ?? 'India';
        if (country.toLowerCase() != _selectedCountry.toLowerCase()) {
          return false;
        }
      }

      // 3. Category Filter
      if (_selectedCategory != 'Featured') {
        if (_selectedCategory == 'Live Now') {
          if ((creator['isOnline'] as bool? ?? false) != true) return false;
        } else if (_selectedCategory == 'Top Rated') {
          final rating = double.tryParse(creator['rating']?.toString() ?? '0') ?? 0;
          if (rating < 4.9) return false;
        } else {
          final categories = ((creator['categories'] as List<dynamic>?) ?? [])
              .map((c) => c.toString())
              .toList();
          if (!categories.contains(_selectedCategory)) return false;
        }
      }

      // 4. Gender Filter
      if (_selectedGender != 'All') {
        final gender = creator['gender'] as String? ?? '';
        if (gender.toLowerCase() != _selectedGender.toLowerCase()) return false;
      }

      // 5. Age Range
      final age = (creator['age'] as num?)?.toInt() ?? 20;
      if (age < _ageRange.start || age > _ageRange.end) return false;

      // 6. Verified Only
      if (_verifiedOnly && (creator['isVerified'] as bool? ?? false) != true) {
        return false;
      }

      // 7. Online Only
      if (_onlineOnly && (creator['isOnline'] as bool? ?? false) != true) {
        return false;
      }

      // 8. Language Filter
      if (_selectedLanguages.isNotEmpty) {
        final langs = ((creator['languages'] as List<dynamic>?) ?? [])
            .map((l) => l.toString())
            .toList();
        final hasAnyLang = _selectedLanguages.any((l) => langs.contains(l));
        if (!hasAnyLang) return false;
      }

      return true;
    }).toList();
  }

  void _openCreatorProfile(Map<String, dynamic> creator) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatorDetailScreen(
          creator: creator,
          onNavigateTab: widget.onNavigateTab,
        ),
      ),
    );
  }

  void _openStoryModal(Map<String, dynamic> story) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: AppColors.pineDark,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      story['avatar'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.pineDark,
                        child: const Icon(Icons.person,
                            size: 80, color: AppColors.seafoamTeal),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xCC000000),
                          Colors.transparent,
                          Color(0xCC000000)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.network(
                            story['avatar'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 40,
                              height: 40,
                              color: AppColors.iceMint,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story['name'],
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Just now',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.softMint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        story['caption'],
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Country',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pineDark,
                    ),
                  ),
                  if (_selectedCountry != 'All Countries')
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedCountry = 'All Countries');
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Reset',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.seafoamTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ..._countries.map((country) {
                final isSelected = _selectedCountry == country;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.public_rounded,
                    color: isSelected ? AppColors.seafoamTeal : AppColors.textMuted,
                    size: 20,
                  ),
                  title: Text(
                    country,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.pineDark : AppColors.textSecondary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.seafoamTeal, size: 20)
                      : null,
                  onTap: () {
                    setState(() => _selectedCountry = country);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAdvancedFiltersSheet() {
    List<String> tempLanguages = List.from(_selectedLanguages);
    String tempGender = _selectedGender;
    RangeValues tempAgeRange = _ageRange;
    bool tempVerifiedOnly = _verifiedOnly;
    bool tempOnlineOnly = _onlineOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Creators',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.pineDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempLanguages.clear();
                              tempGender = 'All';
                              tempAgeRange = const RangeValues(18, 50);
                              tempVerifiedOnly = false;
                              tempOnlineOnly = false;
                            });
                          },
                          child: Text(
                            'Reset All',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFDC2626),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      children: [
                        // Spoken Languages
                        Text(
                          'Spoken Languages',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.pineDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableLanguages.map((lang) {
                            final isSel = tempLanguages.contains(lang);
                            return FilterChip(
                              label: Text(lang),
                              selected: isSel,
                              onSelected: (val) {
                                setSheetState(() {
                                  if (val) {
                                    tempLanguages.add(lang);
                                  } else {
                                    tempLanguages.remove(lang);
                                  }
                                });
                              },
                              selectedColor: AppColors.iceMint,
                              checkmarkColor: AppColors.pineDark,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? AppColors.pineDark : AppColors.textSecondary,
                              ),
                              backgroundColor: const Color(0xFFF7FCFA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSel
                                      ? AppColors.seafoamTeal
                                      : AppColors.borderLight,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Gender Filter
                        Text(
                          'Creator Gender',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.pineDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: ['All', 'Female', 'Male'].map((g) {
                            final isSel = tempGender == g;
                            return ChoiceChip(
                              label: Text(g),
                              selected: isSel,
                              onSelected: (val) {
                                if (val) setSheetState(() => tempGender = g);
                              },
                              selectedColor: AppColors.pineDark,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? Colors.white : AppColors.textSecondary,
                              ),
                              backgroundColor: const Color(0xFFF7FCFA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSel
                                      ? AppColors.pineDark
                                      : AppColors.borderLight,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Age Range
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Age Range',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pineDark,
                              ),
                            ),
                            Text(
                              '${tempAgeRange.start.toInt()} - ${tempAgeRange.end.toInt()} yrs',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.seafoamTeal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        RangeSlider(
                          values: tempAgeRange,
                          min: 18,
                          max: 60,
                          divisions: 42,
                          activeColor: AppColors.seafoamTeal,
                          inactiveColor: AppColors.paleMint,
                          labels: RangeLabels(
                            '${tempAgeRange.start.toInt()}',
                            '${tempAgeRange.end.toInt()}',
                          ),
                          onChanged: (values) {
                            setSheetState(() => tempAgeRange = values);
                          },
                        ),

                        const SizedBox(height: 18),

                        // Verified Only Switch
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: AppColors.seafoamTeal,
                          title: Row(
                            children: [
                              const Icon(Icons.verified_rounded,
                                  color: AppColors.seafoamTeal, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Verified Creators Only',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.pineDark,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Show only identity-verified profiles',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          value: tempVerifiedOnly,
                          onChanged: (v) {
                            setSheetState(() => tempVerifiedOnly = v);
                          },
                        ),

                        const Divider(height: 20, color: AppColors.borderLight),

                        // Online Only Switch
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: const Color(0xFF10B981),
                          title: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Online Now Only',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.pineDark,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Show creators currently active for instant interaction',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          value: tempOnlineOnly,
                          onChanged: (v) {
                            setSheetState(() => tempOnlineOnly = v);
                          },
                        ),

                        const SizedBox(height: 28),

                        // Apply Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.brandGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLanguages.clear();
                                  _selectedLanguages.addAll(tempLanguages);
                                  _selectedGender = tempGender;
                                  _ageRange = tempAgeRange;
                                  _verifiedOnly = tempVerifiedOnly;
                                  _onlineOnly = tempOnlineOnly;
                                });
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Apply Filters',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _resetAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedCountry = 'All Countries';
      _selectedCategory = 'Featured';
      _selectedLanguages.clear();
      _selectedGender = 'All';
      _ageRange = const RangeValues(18, 50);
      _verifiedOnly = false;
      _onlineOnly = false;
    });
  }

  void _toggleLike(Map<String, dynamic> creator) {
    setState(() {
      final isLiked = !((creator['isLiked'] as bool?) ?? false);
      creator['isLiked'] = isLiked;
      final currentLikes = (creator['likes'] as int?) ?? 0;
      if (isLiked) {
        creator['likes'] = currentLikes + 1;
      } else {
        creator['likes'] = (currentLikes > 0) ? currentLikes - 1 : 0;
      }
    });
  }

  void _toggleFollow(Map<String, dynamic> creator) {
    setState(() {
      creator['isFollowing'] = !((creator['isFollowing'] as bool?) ?? false);
    });
    final isFollowing = (creator['isFollowing'] as bool?) ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFollowing
              ? 'Following ${creator['name']}'
              : 'Unfollowed ${creator['name']}',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.pineDark,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleSave(Map<String, dynamic> creator) {
    setState(() {
      creator['isSaved'] = !((creator['isSaved'] as bool?) ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCreators;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFD),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar with Logo, Country Selector, and Filter Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                child: Row(
                  children: [
                    // Trylo Brand Logo
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.iceMint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const TryloLogo(
                        iconSize: 18,
                        fontSize: 16,
                        spacing: 6,
                      ),
                    ),

                    const Spacer(),

                    // Country Selector Pill Button
                    GestureDetector(
                      onTap: _showCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.public_rounded,
                                size: 16, color: AppColors.seafoamTeal),
                            const SizedBox(width: 6),
                            Text(
                              _selectedCountry == 'All Countries'
                                  ? 'Global'
                                  : _selectedCountry,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pineDark,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                size: 16, color: AppColors.pineDark),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Filter Button with Badge
                    GestureDetector(
                      onTap: _showAdvancedFiltersSheet,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderLight),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              size: 20,
                              color: AppColors.pineDark,
                            ),
                          ),
                          if (_activeFiltersCount > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.seafoamTeal,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$_activeFiltersCount',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
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

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pineDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search creators, skills, passions...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.seafoamTeal,
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 18, color: AppColors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
            ),

            // Category Tabs: Featured, Top Rated, Trending, Recommended, Live Now
            SliverToBoxAdapter(
              child: Container(
                height: 42,
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    final isLiveNow = cat == 'Live Now';

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.pineDark
                              : const Color(0xFFF4FAF8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.pineDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLiveNow) ...[
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF059669),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            Text(
                              cat,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.pineDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Stories Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Discover Stories',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.pineDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 104,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _stories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final story = _stories[index];
                        return GestureDetector(
                          onTap: () => _openStoryModal(story),
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.seafoamTeal,
                                          AppColors.softMint,
                                          Color(0xFFFF6584),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          story['avatar'],
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: 56,
                                            height: 56,
                                            color: AppColors.iceMint,
                                            child: const Icon(Icons.person,
                                                color: AppColors.seafoamTeal),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (story['hasAdd'] == true)
                                    Positioned(
                                      top: 0,
                                      right: -2,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF6584),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.add_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                story['name'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.pineDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // Feed Header: "Near you" and Active Count
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Near you',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.pineDark,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.iceMint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${filtered.length} Creators',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.pineDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_activeFiltersCount > 0)
                      GestureDetector(
                        onTap: _resetAllFilters,
                        child: Text(
                          'Clear Filters',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _showAdvancedFiltersSheet,
                        child: const Icon(Icons.tune_rounded,
                            color: AppColors.pineDark, size: 20),
                      ),
                  ],
                ),
              ),
            ),

            // Instagram-Style Vertical Scrolling Profiles Feed or Empty State
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.iceMint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_off_rounded,
                          size: 40,
                          color: AppColors.seafoamTeal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Creators Found',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pineDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search keyword, country selector, or filters to discover amazing creators.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _resetAllFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pineDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Reset Filters',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final creator = filtered[index];
                      return _buildInstagramStylePost(creator);
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstagramStylePost(Map<String, dynamic> creator) {
    final bool isLiked = (creator['isLiked'] as bool?) ?? false;
    final bool isFollowing = (creator['isFollowing'] as bool?) ?? false;
    final bool isSaved = (creator['isSaved'] as bool?) ?? false;
    final bool isOnline = (creator['isOnline'] as bool?) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12374442),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header (Avatar with online dot, Name, Profession, Follow Button)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _openCreatorProfile(creator),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.seafoamTeal, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            creator['avatar'],
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 42,
                              height: 42,
                              color: AppColors.iceMint,
                              child: const Icon(Icons.person,
                                  color: AppColors.seafoamTeal),
                            ),
                          ),
                        ),
                      ),
                      if (isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openCreatorProfile(creator),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${creator['name']}, ${creator['age']}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.pineDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded,
                                color: AppColors.seafoamTeal, size: 16),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${creator['profession']} • ${creator['location']}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Connect / Following Pill
                OutlinedButton(
                  onPressed: () => _toggleFollow(creator),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                    side: BorderSide(
                      color: isFollowing
                          ? AppColors.borderLight
                          : AppColors.seafoamTeal,
                      width: 1.2,
                    ),
                    backgroundColor: isFollowing
                        ? const Color(0xFFF4FAF8)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isFollowing ? 'Following' : 'Connect',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isFollowing
                          ? AppColors.textSecondary
                          : AppColors.seafoamTeal,
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                IconButton(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.pineDark, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _openCreatorProfile(creator),
                ),
              ],
            ),
          ),

          // Main Media Photo with Tap to Open Detail Page & Double-Tap to Like
          GestureDetector(
            onDoubleTap: () => _toggleLike(creator),
            onTap: () => _openCreatorProfile(creator),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 1.05,
                    child: Image.network(
                      creator['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.iceMint,
                        child: const Center(
                          child: Icon(Icons.person,
                              size: 64, color: AppColors.seafoamTeal),
                        ),
                      ),
                    ),
                  ),
                ),

                // Top Right Distance Pill
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.seafoamTeal, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '(${creator['distance']})',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Left Rating Pill
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFB800), size: 15),
                        const SizedBox(width: 4),
                        Text(
                          '${creator['rating']}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Row (Like, Chat, Book CTA, Save)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                // Like Button
                IconButton(
                  icon: Icon(
                    isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color:
                        isLiked ? const Color(0xFFFF4D6D) : AppColors.pineDark,
                    size: 26,
                  ),
                  onPressed: () => _toggleLike(creator),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 14),

                // Chat Button
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.pineDark, size: 24),
                  onPressed: () => widget.onNavigateTab?.call(1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Chat with Creator',
                ),
                const SizedBox(width: 14),

                // "Book Session" CTA Button with Vibrant Gradient
                GestureDetector(
                  onTap: () => _openCreatorProfile(creator),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 13, vertical: 7.5),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientEmeraldTeal,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2810B981),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          'Book • From ₹200',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Save Bookmark Button
                IconButton(
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved ? AppColors.seafoamTeal : AppColors.pineDark,
                    size: 24,
                  ),
                  onPressed: () => _toggleSave(creator),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Likes Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${creator['likes']} likes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.pineDark,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Caption & Description (Clean, No Emojis)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.pineDark),
                children: [
                  TextSpan(
                    text: '${creator['name']} ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: creator['caption'],
                    style: const TextStyle(
                        color: AppColors.textSecondary, height: 1.35),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Tags Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6,
              children: (creator['tags'] as List<String>).map((tag) {
                return Text(
                  '#$tag',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.seafoamTeal,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // View Full Profile & Services Link
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _openCreatorProfile(creator),
              child: Text(
                'View all ${creator['comments']} reviews, services & rate card...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
