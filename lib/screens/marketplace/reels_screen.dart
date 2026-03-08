import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/listing.dart';
import '../../core/constants.dart';
import '../../widgets/video_player_widget.dart';
import 'listing_detail_screen.dart';

class ReelsScreen extends StatefulWidget {
  final bool isActive;
  const ReelsScreen({super.key, this.isActive = true});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().fetchListings(
        filters: {'has_video': true}
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          final videoListings = provider.listings.where((l) => l.videoUrl != null).toList();

          if (provider.isLoading && videoListings.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (videoListings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.videocam_off, color: Colors.white54, size: 60),
                   SizedBox(height: 16),
                   Text('No video listings yet', style: TextStyle(color: Colors.white)),
                ],
              ),
            );
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: videoListings.length,
            itemBuilder: (context, index) {
              final listing = videoListings[index];
              final bool isCurrentlyOnScreen = index == _currentPage && widget.isActive;

              return Stack(
                fit: StackFit.expand,
                children: [
                   // Video Player (The core player)
                  VideoPlayerWidget(
                    videoUrl: listing.videoUrl,
                    autoPlay: isCurrentlyOnScreen,
                    loop: true,
                    showControls: true,
                  ),
                  
                  // Bottom Gradient for legibility
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Profile & Description (Bottom Layer)
                  Positioned(
                    bottom: 30,
                    left: 16,
                    right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person, size: 16, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              listing.userName ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white, width: 1.2),
                              ),
                              child: const Text(
                                'Follow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          listing.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          listing.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.music_note, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Original Audio - ${listing.userName ?? "User"}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Sidebar (Like, Comment, Share)
                  Positioned(
                    right: 12,
                    bottom: 40,
                    child: Column(
                      children: [
                        _buildInstagramAction(Icons.favorite_outline, '1.2k'),
                        const SizedBox(height: 18),
                        _buildInstagramAction(Icons.chat_bubble_outline_rounded, '45'),
                        const SizedBox(height: 18),
                        _buildInstagramAction(Icons.send_rounded, ''),
                        const SizedBox(height: 25),
                        _buildInstagramAction(Icons.more_vert_rounded, ''),
                         const SizedBox(height: 20),
                        // Mini Audio Profile
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white38, width: 2),
                            color: Colors.black,
                          ),
                          child: const Icon(Icons.music_note, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInstagramAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
