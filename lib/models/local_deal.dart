class LocalDeal {
  final String id;
  final String title;
  final String description;
  final double originalPrice;
  final double discountPrice;
  final String expiryDate;
  final String categoryId;
  final String sellerId;
  final String location;
  final String? imageUrl;
  final DateTime createdAt;

  LocalDeal({
    required this.id,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.discountPrice,
    required this.expiryDate,
    required this.categoryId,
    required this.sellerId,
    required this.location,
    this.imageUrl,
    required this.createdAt,
  });

  factory LocalDeal.fromJson(Map<String, dynamic> json) {
    return LocalDeal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      originalPrice: (json['original_price'] ?? 0).toDouble(),
      discountPrice: (json['discount_price'] ?? 0).toDouble(),
      expiryDate: json['expiry_date'] ?? '',
      categoryId: json['category_id'] ?? '',
      sellerId: json['seller_id'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
