import 'package:flutter/material.dart';
import '../models/discovery_place.dart';
import '../models/listing.dart';
import '../models/service_profile.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<Listing> _trendingListings = [];
  List<ServiceProfile> _trendingServices = [];
  List<ServiceProfile> _recommendedServices = [];

  List<DiscoveryPlace> get nearbyPlaces => _nearbyPlaces;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get selectedLocationName => _selectedLocationName;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  List<Listing> get trendingListings => _trendingListings;
  List<ServiceProfile> get trendingServices => _trendingServices;
  List<ServiceProfile> get recommendedServices => _recommendedServices;

  DiscoveryProvider() {
    _loadSavedLocation();
    fetchAllDiscovery();
  }

  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lat = prefs.getDouble('selected_lat') ?? 28.6139;
      _lng = prefs.getDouble('selected_lng') ?? 77.2090;
      _selectedLocationName =
          prefs.getString('selected_location_name') ?? 'New Delhi, India';
      notifyListeners();
      fetchNearbyPlaces();
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  Future<void> _saveLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('selected_lat', _lat);
      await prefs.setDouble('selected_lng', _lng);
      await prefs.setString('selected_location_name', _selectedLocationName);
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  void setLocation(double lat, double lng, String name) {
    _lat = lat;
    _lng = lng;
    _selectedLocationName = name;
    _saveLocation();
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
      await _saveLocation();
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

  Future<void> fetchAllDiscovery() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchTrendingListings(),
        fetchTrendingServices(),
        fetchRecommendedServices(),
      ]);
    } catch (e) {
      debugPrint('Error fetching all discovery: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTrendingListings() async {
    _trendingListings = await _apiService.getTrendingListings();
    notifyListeners();
  }

  Future<void> fetchTrendingServices() async {
    _trendingServices = await _apiService.getTrendingServices();
    notifyListeners();
  }

  Future<void> fetchRecommendedServices() async {
    _recommendedServices = await _apiService.getRecommendedServices();
    notifyListeners();
  }
}
