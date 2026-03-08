class SystemConfig {
  final String key;
  final String value;
  final String? description;

  SystemConfig({
    required this.key,
    required this.value,
    this.description,
  });

  factory SystemConfig.fromJson(Map<String, dynamic> json) {
    return SystemConfig(
      key: json['key'],
      value: json['value'],
      description: json['description'],
    );
  }
}
