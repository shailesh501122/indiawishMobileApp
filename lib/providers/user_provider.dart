import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserBasic? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _hasSkipped = false;

  UserBasic? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasSkipped => _hasSkipped;

  UserProvider() {
    checkToken();
  }

  Future<void> checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token != null) {
      _isAuthenticated = true;
      notifyListeners();
      await fetchProfile();
    }
  }

  void setSkipped(bool value) {
    _hasSkipped = value;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _apiService.getMe();
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
      } else {
        // If we get null (401 from interceptor), we're not authenticated
        _isAuthenticated = false;
        _currentUser = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      // On network error, keep current auth state but show logs
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final data = await _apiService.login(email, password);
    if (data != null) {
      _currentUser = UserBasic.fromJson(data['user']);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> googleLogin(String idToken) async {
    _isLoading = true;
    notifyListeners();

    final data = await _apiService.googleLogin(idToken);
    if (data != null) {
      _currentUser = UserBasic.fromJson(data['user']);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    final data = await _apiService.register(userData);
    if (data != null) {
      _currentUser = UserBasic.fromJson(data['user']);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> toggleElite() async {
    try {
      final user = await _apiService.toggleElite();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling elite in provider: $e');
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _currentUser = null;
    _isAuthenticated = false;
    _hasSkipped = false;
    notifyListeners();
  }
}
