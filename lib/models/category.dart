class SubCategory {
  final String id;
  final String name;
  final String? icon;

  SubCategory({required this.id, required this.name, this.icon});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }
}

class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final List<SubCategory>? subcategories;
  final List<Map<String, dynamic>>? filterConfig;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.subcategories,
    this.filterConfig,
  });

  String? get fullIconUrl {
    if (icon == null || icon!.isEmpty) return null;
    if (icon!.startsWith('http')) return icon;
    // Assuming ApiConfig.baseUrl is available or will be handled in the widget
    // For now, let's keep it as is or add a helper that takes baseUrl
    return icon;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'],
      subcategories: json['subcategory_list'] != null
          ? (json['subcategory_list'] as List)
                .map((subJson) => SubCategory.fromJson(subJson))
                .toList()
          : [],
      filterConfig: json['filter_config'] != null
          ? List<Map<String, dynamic>>.from(json['filter_config'])
          : [],
    );
  }
}
