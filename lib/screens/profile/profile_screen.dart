import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../marketplace/my_listings_screen.dart';
import 'edit_profile_screen.dart';
import 'verification_screen.dart';
import 'referral_screen.dart';
import '../services/provider_leads_screen.dart';
import '../marketplace/seller_analytics_screen.dart';
import '../../widgets/verification_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          final user = provider.currentUser;

          if (provider.isLoading && user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (user == null) {
            return _buildNotLoggedIn(context);
          }

          final memberSince = user.createdAt != null
              ? DateFormat('MMMM yyyy').format(user.createdAt!)
              : 'Recently';

          return RefreshIndicator(
            onRefresh: () => provider.fetchProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Blue header / status bar area
                  Container(
                    color: AppColors.primary,
                    child: const SafeArea(
                      bottom: false,
                      child: SizedBox(height: 8),
                    ),
                  ),

                  // Brand logo section
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Text(
                          'IndiaWish',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.featured,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'IN',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile avatar + name
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF002F5A),
                                    Color(0xFF1565C0),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundColor: const Color(0xFFFFF3CD),
                                  backgroundImage: user.profilePicUrl != null
                                      ? NetworkImage(user.profilePicUrl!)
                                      : null,
                                  child: user.profilePicUrl == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Color(0xFF5B9ECF),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            if (user.isElite)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade700,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              VerificationBadge(level: user.verificationLevel),
                              if (user.email.isNotEmpty)
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'Member since $memberSince',
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats Row
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat('${user.followerCount}', 'Followers'),
                        Container(
                          width: 1,
                          height: 28,
                          color: AppColors.lightGrey,
                        ),
                        _buildStat('${user.followingCount}', 'Following'),
                      ],
                    ),
                  ),

                  // "View and Edit Profile" button
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View and Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Profile completion progress
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStepsRemaining(user),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (i) {
                            final completed = _getCompletedSteps(user);
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 4),
                                height: 5,
                                decoration: BoxDecoration(
                                  color: i < completed
                                      ? AppColors.featured
                                      : AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We are built on trust. Help one another to get to know each other better.',
                          style: TextStyle(fontSize: 11, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Menu items
                  _buildMenuSection([
                    _MenuItem(
                      Icons.credit_card_outlined,
                      'Buy Packages & My Orders',
                      'Packages, orders, billing and invoices',
                    ),
                    _MenuItem(
                      Icons.favorite_border,
                      'Wishlist',
                      'View your liked items here',
                    ),
                  ]),

                  const SizedBox(height: 8),

                  _buildMenuSection([
                    _MenuItem(
                      Icons.list_alt_outlined,
                      'My Listings',
                      'View and manage your ads',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyListingsScreen(),
                        ),
                      ),
                    ),
                    _MenuItem(
                      Icons.bar_chart_outlined,
                      'Analytics Dashboard',
                      'Track views and leads for your ads',
                      badge: 'New',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SellerAnalyticsScreen(),
                        ),
                      ),
                    ),
                    _MenuItem(
                      Icons.work_outline,
                      'Provider Service Leads',
                      'View and accept new job requests',
                      badge: 'New',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProviderLeadsScreen(),
                        ),
                      ),
                    ),
                    _MenuItem(
                      Icons.star_border_outlined,
                      user.isElite
                          ? 'Elite Member Active'
                          : 'Become an Elite Buyer',
                      user.isElite
                          ? 'You have access to all premium features'
                          : 'Call owners directly',
                      onTap: () => provider.toggleElite(),
                    ),
                    _MenuItem(
                      Icons.card_giftcard,
                      'Invite & Earn',
                      'Share your code and earn ₹50 credit',
                      badge: '🎁',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReferralScreen(),
                        ),
                      ),
                    ),
                    _MenuItem(
                      Icons.storefront_outlined,
                      'Become an Elite Seller',
                      'Unlock direct calls from buyers',
                      badge: 'New',
                      onTap: () => provider.toggleElite(),
                    ),
                    _MenuItem(
                      Icons.verified_user_outlined,
                      user.verificationLevel == 'phone' ||
                              user.verificationLevel == 'id' ||
                              user.verificationLevel == 'top_seller'
                          ? '✅ Phone Verified'
                          : 'Verify Phone Number',
                      user.verificationLevel == 'unverified'
                          ? 'Get a verified badge to boost trust'
                          : 'Your phone is verified',
                      badge: user.verificationLevel == 'unverified'
                          ? 'New'
                          : null,
                      onTap: user.verificationLevel == 'unverified'
                          ? () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const VerificationScreen(),
                                ),
                              );
                              if (result == true) provider.fetchProfile();
                            }
                          : null,
                    ),
                    _MenuItem(
                      Icons.settings_outlined,
                      'Settings',
                      'Privacy and logout',
                    ),
                  ]),

                  const SizedBox(height: 8),

                  _buildMenuSection([
                    _MenuItem(
                      Icons.logout,
                      'Logout',
                      '',
                      isDestructive: true,
                      onTap: () => provider.logout(),
                    ),
                  ]),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  int _getCompletedSteps(dynamic user) {
    int count = 1; // Account created
    if (user.profilePicUrl != null) count++;
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) count++;
    if (user.email.isNotEmpty) count++;
    return count;
  }

  String _getStepsRemaining(dynamic user) {
    final remaining = 5 - _getCompletedSteps(user);
    return remaining > 0 ? '$remaining steps left' : 'Profile complete!';
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.primary,
          child: const SafeArea(bottom: false, child: SizedBox(height: 8)),
        ),
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'IndiaWish',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 72,
                  color: AppColors.lightGrey,
                ),
                SizedBox(height: 16),
                Text(
                  'Please login to view your profile',
                  style: TextStyle(color: AppColors.grey, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(List<_MenuItem> items) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: items.map((item) {
          return _buildMenuItem(item);
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Builder(
      builder: (context) => InkWell(
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.lightGrey, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 22,
                color: item.isDestructive ? Colors.red : AppColors.darkText,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: item.isDestructive
                                ? Colors.red
                                : AppColors.darkText,
                          ),
                        ),
                        if (item.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.subtitle.isNotEmpty)
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;
  final String? badge;

  _MenuItem(
    this.icon,
    this.title,
    this.subtitle, {
    this.onTap,
    this.isDestructive = false,
    this.badge,
  });
}
