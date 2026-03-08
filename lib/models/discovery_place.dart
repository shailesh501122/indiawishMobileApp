class DiscoveryPlace {
  final String id;
  final String name;
  final double rating;
  final String address;
  final String imageUrl;
  final String category;
  final String distance;

  DiscoveryPlace({
    required this.id,
    required this.name,
    required this.rating,
    required this.address,
    required this.imageUrl,
    required this.category,
    required this.distance,
  });

  factory DiscoveryPlace.fromJson(Map<String, dynamic> json) {
    return DiscoveryPlace(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      distance: json['distance'] ?? '',
    );
  }
}
