import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/listing.dart';
import '../../core/constants.dart';
import '../../providers/marketplace_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';
import '../chat/chat_detail_screen.dart';
import 'seller_profile_screen.dart';
import 'safe_deal_screen.dart';
import '../../widgets/video_player_widget.dart';
import '../chat/call_screen.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _isConnecting = false;
  int _currentImageIndex = 0;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    // Track view interaction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().trackInteraction(
        widget.listing.id,
        'view',
      );
    });
  }

  void _startChat() async {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.currentUser?.id;

    if (widget.listing.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot chat with this seller')),
      );
      return;
    }

    if (currentUserId == widget.listing.userId) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('This is your own listing')));
      return;
    }

    setState(() => _isConnecting = true);

    try {
      final chatProvider = context.read<ChatProvider>();
      final conv = await chatProvider.startConversation(
        widget.listing.userId,
        listingId: widget.listing.id,
        initialMessage: "Hi, I'm interested in ${widget.listing.title}",
      );

      if (mounted) {
        setState(() => _isConnecting = false);
        if (conv != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(conversation: conv),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to start conversation')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConnecting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _initiateCall() {
    if (widget.listing.owner == null) return;

    context.read<ChatProvider>().initiateCall(
      widget.listing.userId,
      'voice_offer',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CallScreen(otherUser: widget.listing.owner!, isVideoCall: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );
    final images = widget.listing.images;
    final userProvider = context.watch<UserProvider>();
    final isOwner = userProvider.currentUser?.id == widget.listing.userId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Image section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full-width image carousel
                  Stack(
                    children: [
                      // Image
                      SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: images.isNotEmpty
                            ? PageView.builder(
                                itemCount: images.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return CachedNetworkImage(
                                    imageUrl: images[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColors.lightGrey,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: AppColors.lightGrey,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                  );
                                },
                              )
                            : Container(
                                color: AppColors.lightGrey,
                                child: const Icon(
                                  Icons.image,
                                  size: 80,
                                  color: AppColors.grey,
                                ),
                              ),
                      ),
                      // Back button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ),
                      // Share button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.share_outlined,
                              size: 20,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ),
                      // Dot indicators
                      if (images.length > 1)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (i) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: i == _currentImageIndex ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: i == _currentImageIndex
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              );
                            }),
                          ),
                        ),
                      // Image count
                      if (images.isNotEmpty)
                        Positioned(
                          bottom: 10,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1}/${images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      // Video Play Button Overlay
                      if (widget.listing.videoUrl != null)
                        Positioned(
                          top: 130,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog.fullscreen(
                                    backgroundColor: Colors.black,
                                    child: Stack(
                                      children: [
                                        VideoPlayerWidget(
                                          videoUrl: widget.listing.videoUrl,
                                          autoPlay: true,
                                          showControls: true,
                                        ),
                                        Positioned(
                                          top: 40,
                                          right: 20,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.listing.videoUrl != null)
                        Positioned(
                          top: 185,
                          left: 0,
                          right: 0,
                          child: const Center(
                            child: Text(
                              'WATCH VIDEO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(blurRadius: 10, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Price & Title section
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currencyFormatter.format(
                                      widget.listing.price,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.listing.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => _isFavorited = !_isFavorited);
                                context
                                    .read<MarketplaceProvider>()
                                    .trackInteraction(
                                      widget.listing.id,
                                      'like',
                                    );
                              },
                              child: Icon(
                                _isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorited
                                    ? Colors.red
                                    : AppColors.grey,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'India',
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'TODAY',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Details section
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.darkText,
                          ),
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Category',
                          widget.listing.categoryName ??
                              widget.listing.categoryId,
                        ),
                        if (widget.listing.properties != null &&
                            widget.listing.properties!.isNotEmpty)
                          ...widget.listing.properties!.entries.map((e) {
                            // Format key: brand -> Brand, fuel_type -> Fuel Type
                            String label =
                                e.key[0].toUpperCase() +
                                e.key.substring(1).replaceAll('_', ' ');
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(height: 24),
                                _buildDetailRow(label, e.value.toString()),
                              ],
                            );
                          }).toList(),
                        const Divider(height: 24),

                        const Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.listing.description,
                          style: const TextStyle(
                            color: AppColors.grey,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Seller card
                  if (widget.listing.owner != null) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SellerProfileScreen(
                              userId: widget.listing.userId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        color: AppColors.white,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seller Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFFFFF3CD),
                                  backgroundImage:
                                      widget.listing.owner!.profilePicUrl !=
                                          null
                                      ? CachedNetworkImageProvider(
                                          widget.listing.owner!.profilePicUrl!,
                                        )
                                      : null,
                                  child:
                                      widget.listing.owner!.profilePicUrl ==
                                          null
                                      ? const Icon(
                                          Icons.person,
                                          color: AppColors.primary,
                                          size: 28,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${widget.listing.owner!.firstName} ${widget.listing.owner!.lastName}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Member since ${widget.listing.owner!.createdAt?.year ?? 2024}',
                                        style: const TextStyle(
                                          color: AppColors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          // Bottom action bar (OLX-style)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Chat button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (_isConnecting || isOwner) ? null : _startChat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOwner
                            ? AppColors.grey
                            : AppColors.primary,
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      icon: _isConnecting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              isOwner
                                  ? Icons.info_outline
                                  : Icons.chat_bubble_outline_rounded,
                              size: 18,
                            ),
                      label: Text(
                        _isConnecting
                            ? 'Connecting...'
                            : (isOwner ? 'My Ad' : 'Chat'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Make Offer button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isOwner
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SafeDealScreen(listing: widget.listing),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOwner
                            ? AppColors.grey
                            : AppColors.swiggyOrange,
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.security, size: 18),
                      label: const Text(
                        'Safe Deal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Call button
                  GestureDetector(
                    onTap: isOwner ? null : _initiateCall,
                    child: Opacity(
                      opacity: isOwner ? 0.5 : 1.0,
                      child: Container(
                        width: 50,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.featured,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.phone,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'New',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              key,
              style: const TextStyle(color: AppColors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.darkText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
