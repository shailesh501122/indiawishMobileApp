class ServiceProfile {
  final String id;
  final String providerId;
  final String categoryId;
  final String title;
  final String description;
  final double basePrice;
  final String priceType;
  final String? location;
  final double serviceRadiusKm;
  final List<String> images;
  final bool isVerified;
  final double rating;
  final int totalReviews;

  ServiceProfile({
    required this.id,
    required this.providerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.priceType,
    this.location,
    required this.serviceRadiusKm,
    required this.images,
    required this.isVerified,
    required this.rating,
    required this.totalReviews,
  });

  factory ServiceProfile.fromJson(Map<String, dynamic> json) {
    return ServiceProfile(
      id: json['id'] ?? '',
      providerId: json['provider_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      basePrice: (json['base_price'] ?? 0).toDouble(),
      priceType: json['price_type'] ?? 'hourly',
      location: json['location'],
      serviceRadiusKm: (json['service_radius_km'] ?? 10.0).toDouble(),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      isVerified: json['is_verified'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}
