import 'user.dart';

class Listing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String categoryId;
  final String? subcategoryId;
  final String? location;
  final List<String> images;
  final String status;
  final String userId;
  final DateTime createdAt;
  final UserBasic? owner;
  final String? categoryName;
  final Map<String, dynamic>? properties;
  final String listingType; // 'sell' or 'rent'
  final double? rentPrice;
  final String? rentPeriod; // 'daily', 'weekly', 'monthly'
  final String? videoUrl;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.categoryId,
    this.subcategoryId,
    this.location,
    required this.images,
    required this.status,
    required this.userId,
    required this.createdAt,
    this.owner,
    this.categoryName,
    this.properties,
    this.listingType = 'sell',
    this.rentPrice,
    this.rentPeriod,
    this.videoUrl,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    // Handle both 'images' list and 'image_url' string (from socket events)
    List<String> imagesList = [];
    if (json['images'] != null) {
      imagesList = List<String>.from(json['images']);
    } else if (json['image_url'] != null) {
      imagesList = [json['image_url']];
    }

    String? catName;
    if (json['category'] != null && json['category']['name'] != null) {
      catName = json['category']['name'];
    }

    return Listing(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      categoryId: json['category_id'] ?? '',
      subcategoryId:
          json['subcategory_id'] ??
          json['subcategory'], // fallback to old schema name if exists
      location: json['location'],
      images: imagesList,
      status: json['status'] ?? 'Active',
      userId: json['user_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      owner: json['owner'] != null ? UserBasic.fromJson(json['owner']) : null,
      categoryName: json['category_name'] ?? catName,
      properties: json['properties'] != null
          ? Map<String, dynamic>.from(json['properties'])
          : {},
      listingType: json['listing_type'] ?? 'sell',
      rentPrice: (json['rent_price'] as num?)?.toDouble(),
      rentPeriod: json['rent_period'],
      videoUrl: json['video_url'],
    );
  }

  String? get userName => owner?.fullName;
}
