import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants.dart';
import '../models/listing.dart';
import '../widgets/verification_badge.dart';
import 'package:intl/intl.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final bool featured;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.lightGrey.withOpacity(0.5), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Main image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: listing.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: listing.images[0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: AppColors.background),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.background,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.grey,
                                  size: 32,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.background,
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: AppColors.grey,
                                size: 32,
                              ),
                            ),
                          ),
                  ),
                  
                  // Bottom gradient for text readability (if we add elements there later)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // FEATURED badge (top-left)
                  if (featured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.featured,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  // RENT badge (top-left if not featured)
                  if (!featured && listing.listingType == 'rent')
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Text(
                          'FOR RENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  // Heart / wishlist icon (top-right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price
                        Text(
                          listing.listingType == 'rent' && listing.rentPrice != null
                              ? '${currencyFormatter.format(listing.rentPrice!)}/${listing.rentPeriod ?? 'mo'}'
                              : currencyFormatter.format(listing.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.darkText,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Title
                        Text(
                          listing.title,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category + Verification badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                (listing.categoryName ?? 'Marketplace').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.primary.withOpacity(0.8),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (listing.owner != null)
                              VerificationBadge(level: listing.owner!.verificationLevel, compact: true),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppColors.grey.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                listing.location?.isNotEmpty == true
                                    ? listing.location!
                                    : 'Location not specified',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
