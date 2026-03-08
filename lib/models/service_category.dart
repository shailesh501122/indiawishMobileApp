class ServiceCategory {
  final String id;
  final String name;
  final String? description;
  final String? icon;

  ServiceCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'],
    );
  }
}
