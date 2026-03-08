import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/marketplace_provider.dart';
import '../../widgets/listing_card.dart';
import '../marketplace/listing_detail_screen.dart';
import '../marketplace/category_selection_screen.dart';
import '../../models/category.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../providers/config_provider.dart';
import '../../providers/discovery_provider.dart';
import '../../widgets/location_selector_modal.dart';
import '../../widgets/discovery_card.dart';
import '../services/services_list_screen.dart';
import '../../providers/services_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MarketplaceProvider>();
      provider.fetchCategories();
      provider.fetchFreshRecommendations();
      provider.fetchRecentInteractions();
      context.read<ConfigProvider>().fetchConfigs();
      context.read<DiscoveryProvider>().fetchNearbyPlaces();
      context.read<ServicesProvider>().fetchCategories();
      _determinePosition();
    });
  }

  String _currentAddress = 'DLF Phase 3, Gurgaon';
  bool _isFetchingLocation = false;

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() => _isFetchingLocation = true);

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isFetchingLocation = false);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isFetchingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isFetchingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = '${place.subLocality}, ${place.locality}';
          _isFetchingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() => _isFetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: RefreshIndicator(
              color: const Color.fromARGB(255, 216, 71, 3),
              onRefresh: () async {
                final provider = context.read<MarketplaceProvider>();
                final servicesProv = context.read<ServicesProvider>();
                await Future.wait([
                  provider.fetchCategories(),
                  provider.fetchFreshRecommendations(),
                  provider.fetchRecentInteractions(),
                  servicesProv.fetchCategories(),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySection(),
                    _buildHomeServicesSection(),
                    const SizedBox(height: 16),
                    _buildEliteBuyerBanner(),

                    _buildRecentInteractionsSection(context),
                    _buildFreshRecommendations(context),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const Color creamHeader = Color(0xFFFFF9E3);
    const Color darkBlue = AppColors.primary;

    return Container(
      color: creamHeader,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Brand + location + icons row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
              child: Row(
                children: [
                  // Brand name
                  Consumer<ConfigProvider>(
                    builder: (context, config, child) {
                      return Text(
                        config.get('app_name', 'IndiaWish'),
                        style: const TextStyle(
                          color: darkBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      );
                    },
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
                        color: darkBlue,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Location selector
                  Expanded(
                    child: Consumer<DiscoveryProvider>(
                      builder: (context, discovery, child) {
                        return InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  const LocationSelectorModal(),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: darkBlue,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  discovery.selectedLocationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: darkBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: darkBlue,
                                size: 16,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Notifications icon removed as requested
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.lightGrey, width: 0.5),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: AppColors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Consumer<ConfigProvider>(
                        builder: (context, config, child) {
                          return TextField(
                            decoration: InputDecoration(
                              hintText: config.get(
                                'search_hint',
                                'Find Cars, Mobile Phones and more...',
                              ),
                              hintStyle: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          );
                        },
                      ),
                    ),
                    Container(height: 44, width: 1, color: AppColors.lightGrey),
                    IconButton(
                      icon: const Icon(Icons.mic, color: darkBlue, size: 20),
                      onPressed: () {},
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      constraints: const BoxConstraints(),
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

  Widget _buildCategorySection() {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        if (provider.categories.isEmpty) {
          // If no categories in DB, show a subset of default ones or empty
          return const SizedBox.shrink();
        }

        return Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              _buildCategoryRow(provider.categories.take(5).toList()),
              if (provider.categories.length > 5) ...[
                const SizedBox(height: 8),
                _buildCategoryRow(provider.categories.skip(5).take(5).toList()),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRow(List<dynamic> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((item) {
        // 1. Try to map dynamic backend icon string to IconData
        IconData? iconData;
        final backendIcon = item.icon?.toString().toLowerCase() ?? '';
        final name = item.name.toLowerCase();

        // Direct Material Icon Map
        if (backendIcon == 'directions_car' || name.contains('vehicle'))
          iconData = Icons.directions_car;
        else if (backendIcon == 'work' ||
            name.contains('service') ||
            name.contains('job'))
          iconData = Icons.work;
        else if (backendIcon == 'smartphone' || name.contains('mobile'))
          iconData = Icons.smartphone;
        else if (backendIcon == 'kitchen' || name.contains('electronic'))
          iconData = Icons.kitchen;
        else if (backendIcon == 'home' ||
            name.contains('real estate') ||
            name.contains('property'))
          iconData = Icons.home;
        else if (backendIcon == 'checkroom' || name.contains('fashion'))
          iconData = Icons.checkroom;
        else if (backendIcon == 'business' || name.contains('commercial'))
          iconData = Icons.business;
        else if (backendIcon == 'two_wheeler' || name.contains('bike'))
          iconData = Icons.two_wheeler;
        else if (backendIcon == 'chair' || name.contains('furniture'))
          iconData = Icons.chair;
        else if (backendIcon == 'pets' || name.contains('pet'))
          iconData = Icons.pets;
        else if (backendIcon == 'shopping_bag')
          iconData = Icons.shopping_bag;

        // Final Fallback
        iconData ??= Icons.category_outlined;

        return _buildCategoryItem(iconData, item.name, item.icon, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CategorySelectionScreen(initialCategory: item),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildCategoryItem(
    IconData fallbackIcon,
    String label,
    String? iconUrl,
    VoidCallback onTap,
  ) {
    String? fullImageUrl;
    if (iconUrl != null && iconUrl.isNotEmpty && iconUrl != 'null') {
      // Sanitize Windows backslashes
      String sanitizedUrl = iconUrl.replaceAll('\\', '/');
      if (sanitizedUrl.startsWith('http')) {
        fullImageUrl = sanitizedUrl;
      } else {
        // Ensure ApiConfig.baseUrl handles '/api' correctly to get standard base URL
        final base = ApiConfig.baseUrl.replaceAll('/api', '');
        if (!sanitizedUrl.startsWith('/')) {
          sanitizedUrl = '/$sanitizedUrl';
        }
        fullImageUrl = '$base$sanitizedUrl';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightGrey, width: 0.8),
              ),
              child: fullImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        fullImageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                            'ERROR: Failed to load category icon "$label": $fullImageUrl - $error',
                          );
                          return Icon(
                            fallbackIcon,
                            color: AppColors.primary,
                            size: 26,
                          );
                        },
                      ),
                    )
                  : Icon(fallbackIcon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.darkText,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeServicesSection() {
    return Consumer<ServicesProvider>(
      builder: (context, servicesProvider, child) {
        if (servicesProvider.isLoading && servicesProvider.categories.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final categories = servicesProvider.categories;
        if (categories.isEmpty) return const SizedBox.shrink();

        final colors = [
          Colors.blue,
          Colors.orange,
          Colors.grey,
          Colors.amber,
          Colors.green,
          Colors.purple,
        ];

        return Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Home Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(categories.length, (index) {
                    final category = categories[index];
                    final color = colors[index % colors.length];
                    final bool hasImageIcon =
                        category.icon != null &&
                        category.icon!.startsWith('http');

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServicesListScreen(
                              categoryName: category.name,
                              categoryId: category.id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 72,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: hasImageIcon
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          category.icon!,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Icon(
                                            Icons.room_preferences,
                                            color: color,
                                            size: 28,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.handyman,
                                        color: color,
                                        size: 28,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkText,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEliteBuyerBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.lightGrey, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: AppColors.primary,
                  size: 20,
                ),
                Text(
                  'ELITE\nBUYER',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Become an Elite Buyer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  'Call Owners Directly',
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(80, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text(
              'Buy Now',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInteractionsSection(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        if (provider.recentListings.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Text(
                'Based on your recent activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: provider.recentListings.length,
                itemBuilder: (context, index) {
                  final listing = provider.recentListings[index];
                  return SizedBox(
                    width: 160,
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
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFreshRecommendations(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fresh recommendations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (provider.isLoading && provider.freshListings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.freshListings.isEmpty)
              Container(
                margin: const EdgeInsets.all(12),
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: const Center(
                  child: Text(
                    'No listings found. Be the first to post!',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                ),
                itemCount: provider.freshListings.length,
                itemBuilder: (context, index) {
                  final listing = provider.freshListings[index];
                  return ListingCard(
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
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
