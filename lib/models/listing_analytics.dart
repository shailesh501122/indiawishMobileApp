class ListingAnalytics {
  final String listingId;
  final String title;
  final int totalViews;
  final int totalLeads;
  final double conversionRate;

  ListingAnalytics({
    required this.listingId,
    required this.title,
    required this.totalViews,
    required this.totalLeads,
    required this.conversionRate,
  });

  factory ListingAnalytics.fromJson(Map<String, dynamic> json) {
    return ListingAnalytics(
      listingId: json['listing_id'] ?? '',
      title: json['title'] ?? '',
      totalViews: json['total_views'] ?? 0,
      totalLeads: json['total_leads'] ?? 0,
      conversionRate: (json['conversion_rate'] ?? 0.0).toDouble(),
    );
  }
}
