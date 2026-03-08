import 'package:flutter/material.dart';
import '../models/service_category.dart';
import '../models/service_profile.dart';
import '../models/service_booking.dart';
import '../services/api_service.dart';

class ServicesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ServiceCategory> _categories = [];
  List<ServiceProfile> _searchedProfiles = [];
  List<ServiceBooking> _myBookings = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceCategory> get categories => _categories;
  List<ServiceProfile> get searchedProfiles => _searchedProfiles;
  List<ServiceBooking> get myBookings => _myBookings;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    try {
      _setLoading(true);
      _categories = await _apiService.getServiceCategories();
    } catch (e) {
      _errorMessage = 'Failed to load service categories.';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchProfiles({String? categoryId, String? location}) async {
    try {
      _setLoading(true);
      _searchedProfiles = await _apiService.searchServiceProfiles(
        categoryId: categoryId,
        location: location,
      );
    } catch (e) {
      _errorMessage = 'Failed to search service profiles.';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createBooking(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      final booking = await _apiService.createServiceBooking(data);
      if (booking != null) {
        _myBookings.insert(0, booking); // Add immediately to local state
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create booking.';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyBookings({String role = 'customer'}) async {
    try {
      _setLoading(true);
      _myBookings = await _apiService.getMyServiceBookings(role: role);
    } catch (e) {
      _errorMessage = 'Failed to load bookings.';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
