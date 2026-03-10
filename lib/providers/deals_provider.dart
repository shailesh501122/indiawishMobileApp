import 'package:flutter/foundation.dart';
import '../models/local_deal.dart';
import '../services/api_service.dart';

class DealsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<LocalDeal> _nearbyDeals = [];
  bool _isLoading = false;

  List<LocalDeal> get nearbyDeals => _nearbyDeals;
  bool get isLoading => _isLoading;

  Future<void> fetchNearbyDeals({
    double? lat,
    double? lng,
    double? radius,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _nearbyDeals = await _apiService.getNearbyDeals(
        lat: lat,
        lng: lng,
        radiusKm: radius,
      );
    } catch (e) {
      debugPrint('Error fetching nearby deals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
