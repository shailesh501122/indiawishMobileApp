import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/discovery_provider.dart';
import '../../widgets/discovery_card.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/service_card.dart';
import '../../core/constants.dart';
import '../marketplace/listing_detail_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  final bool isActive;

  const DiscoveryScreen({super.key, this.isActive = true});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final List<Map<String, String>> discoveryCategories = [
    {'id': 'tourist_attraction', 'name': 'Attractions', 'icon': 'map'},
    {'id': 'restaurant', 'name': 'Restaurants', 'icon': 'restaurant'},
    {'id': 'hotel', 'name': 'Hotels', 'icon': 'hotel'},
    {'id': 'movie_theater', 'name': 'Movies', 'icon': 'movie'},
    {'id': 'cafe', 'name': 'Cafes', 'icon': 'local_cafe'},
    {'id': 'night_club', 'name': 'Clubs', 'icon': 'nightlife'},
    {'id': 'shopping_mall', 'name': 'Malls', 'icon': 'local_mall'},
  ];

  @override
  void initState() {
    super.initState();
    _initFetch();
  }

  void _initFetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isActive) {
        final discovery = context.read<DiscoveryProvider>();
        discovery.fetchAllDiscovery();
        discovery.fetchNearbyPlaces();
      }
    });
  }

  @override
  void didUpdateWidget(DiscoveryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initFetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              'Discover',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            floating: true,
            centerTitle: false,
            pinned: true,
          ),

          // discoveryCategories persistent header
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 40,
                child: Consumer<DiscoveryProvider>(
                  builder: (context, discovery, child) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: discoveryCategories.length,
                      itemBuilder: (context, index) {
                        final cat = discoveryCategories[index];
                        final isSelected =
                            discovery.selectedCategory == cat['id'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(cat['name']!),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                discovery.setCategory(cat['id']!);
                              }
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          Consumer<DiscoveryProvider>(
            builder: (context, discovery, child) {
              if (discovery.isLoading && discovery.trendingListings.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Trending Listings (Marketplace)
                  if (discovery.trendingListings.isNotEmpty) ...[
                    _buildSectionHeader('Trending Now', 'Marketplace'),
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: discovery.trendingListings.length,
                        itemBuilder: (context, index) {
                          final listing = discovery.trendingListings[index];
                          return SizedBox(
                            width: 180,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ListingCard(
                                listing: listing,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListingDetailScreen(listing: listing),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // 2. Recommended Services
                  if (discovery.recommendedServices.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Top Professional Services',
                      'Verified',
                    ),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: discovery.recommendedServices.length,
                        itemBuilder: (context, index) {
                          return ServiceCard(
                            profile: discovery.recommendedServices[index],
                            isHorizontal: true,
                          );
                        },
                      ),
                    ),
                  ],

                  // 3. Nearby Header
                  _buildSectionHeader('Around You', 'Places'),

                  if (discovery.nearbyPlaces.isEmpty && !discovery.isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No places found nearby',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                ]),
              );
            },
          ),

          // 4. Nearby Places Grid
          Consumer<DiscoveryProvider>(
            builder: (context, discovery, child) {
              if (discovery.nearbyPlaces.isEmpty)
                return const SliverToBoxAdapter(child: SizedBox.shrink());

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return DiscoveryCard(place: discovery.nearbyPlaces[index]);
                  }, childCount: discovery.nearbyPlaces.length),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'See All',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
