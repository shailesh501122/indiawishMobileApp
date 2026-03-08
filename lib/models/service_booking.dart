class ServiceBooking {
  final String id;
  final String customerId;
  final String serviceProfileId;
  final String providerId;
  final DateTime scheduledDate;
  final String serviceAddress;
  final String? instructions;
  final double quotedPrice;
  final String priceType;
  final String status;
  final DateTime createdAt;

  ServiceBooking({
    required this.id,
    required this.customerId,
    required this.serviceProfileId,
    required this.providerId,
    required this.scheduledDate,
    required this.serviceAddress,
    this.instructions,
    required this.quotedPrice,
    required this.priceType,
    required this.status,
    required this.createdAt,
  });

  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      serviceProfileId: json['service_profile_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      scheduledDate: DateTime.parse(json['scheduled_date']),
      serviceAddress: json['service_address'] ?? '',
      instructions: json['instructions'],
      quotedPrice: (json['quoted_price'] ?? 0).toDouble(),
      priceType: json['price_type'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
