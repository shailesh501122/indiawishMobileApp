import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/discovery_provider.dart';
import '../../widgets/discovery_card.dart';
import '../../core/constants.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isActive) {
        context.read<DiscoveryProvider>().fetchNearbyPlaces();
      }
    });
  }

  @override
  void didUpdateWidget(DiscoveryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      context.read<DiscoveryProvider>().fetchNearbyPlaces();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Nearby', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
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
                      final isSelected = discovery.selectedCategory == cat['id'];
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
                            color: isSelected ? Colors.white : AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : AppColors.primary.withOpacity(0.3),
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
          Expanded(
            child: Consumer<DiscoveryProvider>(
              builder: (context, discovery, child) {
                if (discovery.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                
                if (discovery.nearbyPlaces.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No places found nearby',
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: discovery.nearbyPlaces.length,
                  itemBuilder: (context, index) {
                    return DiscoveryCard(place: discovery.nearbyPlaces[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
