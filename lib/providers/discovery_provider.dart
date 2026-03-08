import 'package:flutter/material.dart';
import '../models/discovery_place.dart';
import '../services/api_service.dart';

class DiscoveryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<DiscoveryPlace> _nearbyPlaces = [];
  bool _isLoading = false;
  String _selectedCategory = 'tourist_attraction';
  
  // Default to a central location in India (e.g., New Delhi) if not set
  double _lat = 28.6139;
  double _lng = 77.2090;
  String _selectedLocationName = 'New Delhi, India';
  List<Map<String, dynamic>> _searchResults = [];

  List<DiscoveryPlace> get nearbyPlaces => _nearbyPlaces;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get selectedLocationName => _selectedLocationName;
  List<Map<String, dynamic>> get searchResults => _searchResults;

  void setLocation(double lat, double lng, String name) {
    _lat = lat;
    _lng = lng;
    _selectedLocationName = name;
    fetchNearbyPlaces();
    notifyListeners();
  }

  Future<void> searchLocations(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _searchResults = await _apiService.searchLocations(query);
    notifyListeners();
  }

  Future<void> selectLocation(String placeId, String description) async {
    _isLoading = true;
    notifyListeners();

    final details = await _apiService.getLocationDetails(placeId);
    if (details != null) {
      _lat = details['lat']!;
      _lng = details['lng']!;
      _selectedLocationName = description;
      await fetchNearbyPlaces();
    }

    _isLoading = false;
    _searchResults = [];
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    fetchNearbyPlaces();
    notifyListeners();
  }

  Future<void> fetchNearbyPlaces() async {
    _isLoading = true;
    notifyListeners();

    try {
      _nearbyPlaces = await _apiService.getNearbyDiscovery(
        lat: _lat,
        lng: _lng,
        category: _selectedCategory,
      );
    } catch (e) {
      debugPrint('Error in DiscoveryProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
