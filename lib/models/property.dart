import 'user.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String type;
  final String? address;
  final String? city;
  final double? area;
  final int? bedrooms;
  final int? bathrooms;
  final List<String> images;
  final String status;
  final String userId;
  final DateTime createdAt;
  final UserBasic? owner;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    this.address,
    this.city,
    this.area,
    this.bedrooms,
    this.bathrooms,
    required this.images,
    required this.status,
    required this.userId,
    required this.createdAt,
    this.owner,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Handle both 'images' list and 'image_url' string (from socket events)
    List<String> imagesList = [];
    if (json['images'] != null) {
      imagesList = List<String>.from(json['images']);
    } else if (json['image_url'] != null) {
      imagesList = [json['image_url']];
    }

    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      type: json['type'] ?? 'House',
      address: json['address'],
      city: json['city'],
      area: json['area']?.toDouble(),
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      images: imagesList,
      status: json['status'] ?? 'Active',
      userId: json['user_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      owner: json['owner'] != null ? UserBasic.fromJson(json['owner']) : null,
    );
  }
}
