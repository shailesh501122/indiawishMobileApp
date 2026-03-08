import 'package:flutter/material.dart';
import '../../models/listing.dart';
import '../../models/user.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';
import '../../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class SellerProfileScreen extends StatefulWidget {
  final String userId;

  const SellerProfileScreen({super.key, required this.userId});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getSellerProfile(widget.userId);
    if (mounted) {
      setState(() {
        _profileData = data;
        _isFollowing = data?['is_following'] ?? false;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final success = await _apiService.followUser(widget.userId);
    if (success && mounted) {
      setState(() {
        _isFollowing = !_isFollowing;
        // Optionally update follower count locally
        if (_profileData != null) {
          _profileData!['follower_count'] =
              (_profileData!['follower_count'] ?? 0) + (_isFollowing ? 1 : -1);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_profileData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    final userJson = _profileData!['user'];
    final user = UserBasic.fromJson(userJson);
    final listingsJson = _profileData!['listings'] as List;
    final listings = listingsJson.map((l) => Listing.fromJson(l)).toList();
    final followerCount = _profileData!['follower_count'] ?? 0;
    final followingCount = _profileData!['following_count'] ?? 0;

    final joinDate = user.createdAt != null
        ? DateFormat('MMMM yyyy').format(user.createdAt!)
        : '2024';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: user.profilePicUrl != null
                          ? CachedNetworkImageProvider(user.profilePicUrl!)
                          : null,
                      child: user.profilePicUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_profileData?['is_followed_by'] == true) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Follows You',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Member since $joinDate',
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Followers', followerCount.toString()),
                      _buildStatColumn('Following', followingCount.toString()),
                      _buildStatColumn('Ads', listings.length.toString()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isOnline(user) ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOnline(user)
                            ? 'Online Now'
                            : _formatLastSeen(user.lastSeen),
                        style: TextStyle(
                          color: _isOnline(user)
                              ? Colors.green
                              : AppColors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowing
                            ? Colors.white
                            : AppColors.primary,
                        side: _isFollowing
                            ? const BorderSide(color: AppColors.primary)
                            : null,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(
                          color: _isFollowing
                              ? AppColors.primary
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Ads by ${user.firstName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return ListingCard(
                  listing: listings[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ListingDetailScreen(listing: listings[index]),
                      ),
                    );
                  },
                );
              }, childCount: listings.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.grey, fontSize: 13),
        ),
      ],
    );
  }

  bool _isOnline(UserBasic user) {
    if (user.lastSeen == null) return false;
    final now = DateTime.now();
    return now.difference(user.lastSeen!).inMinutes < 5;
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Offline';
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.inMinutes < 60) {
      return 'Seen ${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return 'Seen ${diff.inHours}h ago';
    } else {
      return 'Seen ${DateFormat('MMM d').format(lastSeen)}';
    }
  }
}
