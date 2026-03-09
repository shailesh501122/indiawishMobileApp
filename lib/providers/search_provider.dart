import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SearchProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _suggestions = [];
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  String _lastQuery = '';

  List<Map<String, dynamic>> get suggestions => _suggestions;
  List<Map<String, dynamic>> get results => _results;
  bool get isLoading => _isLoading;

  Future<void> updateSuggestions(String query) async {
    if (query.length < 2) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    if (query == _lastQuery) return;
    _lastQuery = query;

    // We use the same global search for suggestions, just limited or processed differently
    try {
      final data = await _apiService.searchGlobal(query);
      _suggestions = data;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
    }
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _suggestions = [];
    notifyListeners();

    try {
      _results = await _apiService.searchGlobal(query);
    } catch (e) {
      debugPrint('Error performing global search: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _suggestions = [];
    _results = [];
    _lastQuery = '';
    notifyListeners();
  }
}
