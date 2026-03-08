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
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            right: BorderSide(color: AppColors.lightGrey, width: 0.5),
            bottom: BorderSide(color: AppColors.lightGrey, width: 0.8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              child: Stack(
                children: [
                  // Main image
                  SizedBox(
                    width: double.infinity,
                    child: listing.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: listing.images[0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: AppColors.lightGrey),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFEEEEEE),
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
                            color: const Color(0xFFEEEEEE),
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: AppColors.grey,
                                size: 32,
                              ),
                            ),
                          ),
                  ),
                  // FEATURED badge (top-left)
                  if (featured)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: AppColors.featured,
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  // RENT badge (top-left if not featured)
                  if (!featured && listing.listingType == 'rent')
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Colors.teal,
                        child: const Text(
                          'FOR RENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  // Heart / wishlist icon (top-right)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    listing.listingType == 'rent' && listing.rentPrice != null
                        ? '${currencyFormatter.format(listing.rentPrice!)}/${listing.rentPeriod ?? 'mo'}'
                        : currencyFormatter.format(listing.price),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkText),
                  ),
                  const SizedBox(height: 2),
                  // Title / Category + Verification badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (listing.categoryName ?? 'Marketplace').toUpperCase(),
                          style: const TextStyle(fontSize: 10, color: AppColors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (listing.owner != null)
                        VerificationBadge(level: listing.owner!.verificationLevel, compact: true),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          'India',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
