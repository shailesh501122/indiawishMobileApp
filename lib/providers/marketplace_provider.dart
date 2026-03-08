import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../models/property.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'dart:io';

class MarketplaceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  List<Listing> _listings = [];
  List<Listing> _freshListings = [];
  List<Listing> _recentListings = [];
  List<Property> _properties = [];
  List<Category> _categories = [];
  bool _isLoading = false;

  MarketplaceProvider() {
    _initSocket();
  }

  void _initSocket() {
    _socketService.addListingListener((listing) {
      _listings.insert(0, listing);
      _freshListings.insert(0, listing);
      notifyListeners();
    });
    _socketService.addPropertyListener((property) {
      _properties.insert(0, property);
      notifyListeners();
    });
  }

  List<Listing> get listings => _listings;
  List<Listing> get freshListings => _freshListings;
  List<Listing> get recentListings => _recentListings;
  List<Property> get properties => _properties;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchListings({
    String? categoryId,
    Map<String, dynamic>? filters,
  }) async {
    _isLoading = true;
    notifyListeners();

    _listings = await _apiService.getListings(
      categoryId: categoryId,
      filters: filters,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFreshRecommendations() async {
    _freshListings = await _apiService.getFreshRecommendations();
    notifyListeners();
  }

  Future<void> fetchRecentInteractions() async {
    _recentListings = await _apiService.getRecentInteractions();
    notifyListeners();
  }

  Future<void> trackInteraction(String listingId, String type) async {
    await _apiService.trackInteraction(listingId, type);
    // Refresh recent interactions after a short delay or immediately
    fetchRecentInteractions();
  }

  Future<void> fetchProperties() async {
    _isLoading = true;
    notifyListeners();

    _properties = await _apiService.getProperties();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _apiService.getCategories();

    _isLoading = false;
    notifyListeners();
  }

  Future<List<String>> uploadImages(List<dynamic> files) async {
    return await _apiService.uploadImages(files);
  }

  Future<String?> uploadVideo(File file) async {
    return await _apiService.uploadVideo(file);
  }

  Future<bool> postListing(Map<String, dynamic> data) async {
    final listing = await _apiService.createListing(data);
    return listing != null;
  }

  Future<bool> postProperty(Map<String, dynamic> data) async {
    final property = await _apiService.createProperty(data);
    return property != null;
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}
