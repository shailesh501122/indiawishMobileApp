import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'home/home_screen.dart';
import 'chat/chat_list_screen.dart';
import 'profile/profile_screen.dart';
import 'marketplace/reels_screen.dart';

import 'package:provider/provider.dart';
import '../providers/marketplace_provider.dart';
import '../providers/user_provider.dart';
import 'marketplace/create_listing_screen.dart';
import 'marketplace/my_listings_screen.dart';
import 'auth/login_screen.dart';

class MainScreensWrapper extends StatefulWidget {
  const MainScreensWrapper({super.key});

  @override
  State<MainScreensWrapper> createState() => _MainScreensWrapperState();
}

class _MainScreensWrapperState extends State<MainScreensWrapper> {
  // 0=Home, 1=Chats, 2=MyAds, 3=Account
  // Index 2 in bottom nav is the "Sell" FAB (not a real screen)
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final marketplaceProvider = context.read<MarketplaceProvider>();
      marketplaceProvider.fetchListings();
      marketplaceProvider.fetchProperties();
      marketplaceProvider.fetchCategories();

      // Listen for logout to redirect to Home
      final userProvider = context.read<UserProvider>();
      userProvider.addListener(_handleAuthChange);
    });
  }

  void _handleAuthChange() {
    if (!mounted) return;
    final userProvider = context.read<UserProvider>();
    if (!userProvider.isAuthenticated && _selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  void dispose() {
    // Note: UserProvider is usually long-lived, but we should remove listener if wrapper is disposed
    try {
      context.read<UserProvider>().removeListener(_handleAuthChange);
    } catch (_) {}
    super.dispose();
  }

  // Actual screens mapped to nav indices (0, 1, 3, 4 in visual bar)
  List<Widget> get _screens => [
    const HomeScreen(),
    ReelsScreen(isActive: _selectedIndex == 1),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // "Sell" button
      _checkAuthAndNavigate(() {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateListingScreen()),
        );
      });
      return;
    }

    int screenIdx;
    if (index < 2) {
      screenIdx = index;
    } else {
      screenIdx = index - 1;
    }

    if (index == 3 || index == 4) {
      _checkAuthAndNavigate(() {
        setState(() => _selectedIndex = screenIdx);
      });
    } else {
      setState(() => _selectedIndex = screenIdx);
    }
  }

  int get _navBarIndex {
    if (_selectedIndex >= 2) return _selectedIndex + 1;
    return _selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _buildOlxBottomNav(),
    );
  }

  Widget _buildOlxBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(
                1,
                Icons.play_circle_fill_rounded,
                Icons.play_circle_outline_rounded,
                'Reels',
              ),
              _buildSellButton(),
              _buildNavItem(
                3,
                Icons.chat_bubble_rounded,
                Icons.chat_bubble_outline_rounded,
                'Chats',
              ),
              _buildNavItem(
                4,
                Icons.person_rounded,
                Icons.person_outline_rounded,
                'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int navIndex,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = _navBarIndex == navIndex;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabTapped(navIndex),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primary : AppColors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.sellRing, width: 3),
              ),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Sell',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAuthAndNavigate(VoidCallback onSuccess) {
    final userProvider = context.read<UserProvider>();
    if (userProvider.isAuthenticated) {
      onSuccess();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
}
