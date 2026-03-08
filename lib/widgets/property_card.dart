import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants.dart';
import '../models/property.dart';
import 'package:intl/intl.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({super.key, required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.lightGrey, width: 0.8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: property.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: property.images[0],
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppColors.lightGrey),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFEEEEEE),
                            child: const Center(
                              child: Icon(
                                Icons.apartment_outlined,
                                color: AppColors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFEEEEEE),
                          child: const Center(
                            child: Icon(
                              Icons.apartment_outlined,
                              color: AppColors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                ),
                // Property type badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(color: AppColors.featured),
                    child: Text(
                      property.type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                // Wishlist icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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

            // Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyFormatter.format(property.price),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    property.title,
                    style: const TextStyle(fontSize: 14, color: AppColors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          property.address ?? property.city ?? 'India',
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.lightGrey),
                  const SizedBox(height: 10),
                  // Features row
                  Row(
                    children: [
                      _buildFeatureChip(
                        Icons.king_bed_outlined,
                        '${property.bedrooms ?? 0} Beds',
                      ),
                      const SizedBox(width: 16),
                      _buildFeatureChip(
                        Icons.bathtub_outlined,
                        '${property.bathrooms ?? 0} Baths',
                      ),
                      const SizedBox(width: 16),
                      _buildFeatureChip(
                        Icons.square_foot,
                        '${property.area ?? 0} sqft',
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

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.grey),
        ),
      ],
    );
  }
}
