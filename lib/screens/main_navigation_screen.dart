import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/floating_bottom_bar.dart';
import 'creator_discover_screen.dart';
import 'chat_list_screen.dart';
import 'wallet_screen.dart';
import 'profile_self_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFD),
      body: Stack(
        children: [
          // Screen views
          IndexedStack(
            index: _currentIndex,
            children: [
              CreatorDiscoverScreen(onNavigateTab: _onTabTapped),
              const ChatListScreen(),
              const WalletScreen(),
              ProfileSelfScreen(onNavigateTab: _onTabTapped),
            ],
          ),

          // Floating Capsule Bottom Navigation Bar matching Sample Image
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
          ),
        ],
      ),
    );
  }
}
