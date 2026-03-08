import 'package:flutter/material.dart';
import '../models/config.dart';
import '../services/api_service.dart';

class ConfigProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, String> _configs = {};
  bool _isLoading = false;

  Map<String, String> get configs => _configs;
  bool get isLoading => _isLoading;

  String get(String key, String defaultValue) {
    return _configs[key] ?? defaultValue;
  }

  Future<void> fetchConfigs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final configList = await _apiService.getConfigs();
      _configs = {for (var cfg in configList) cfg.key: cfg.value};
    } catch (e) {
      debugPrint('Error in ConfigProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
