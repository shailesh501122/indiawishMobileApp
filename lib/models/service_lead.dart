class ServiceLead {
  final String id;
  final String userId;
  final String categoryId;
  final String location;
  final String description;
  final DateTime createdAt;

  ServiceLead({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.location,
    required this.description,
    required this.createdAt,
  });

  factory ServiceLead.fromJson(Map<String, dynamic> json) {
    return ServiceLead(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class LeadAssignment {
  final String id;
  final String leadId;
  final String providerId;
  final String status;
  final DateTime createdAt;

  LeadAssignment({
    required this.id,
    required this.leadId,
    required this.providerId,
    required this.status,
    required this.createdAt,
  });

  factory LeadAssignment.fromJson(Map<String, dynamic> json) {
    return LeadAssignment(
      id: json['id'] ?? '',
      leadId: json['lead_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
