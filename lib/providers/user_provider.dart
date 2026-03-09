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
        _saveUserToPrefs(user);
      } else {
        // If we get null (401 from interceptor), we're not authenticated
        _isAuthenticated = false;
        _currentUser = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        await prefs.remove('user_data');
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      // Try to load from prefs if network fails
      await _loadUserFromPrefs();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveUserToPrefs(UserBasic user) async {
    final prefs = await SharedPreferences.getInstance();
    // Simple way: store as JSON string
    // Better: store individual fields if needed, but JSON is easier
    // For now, let's just rely on fetchProfile as it's called on every startup.
    // But we can store name/pic for immediate UI
    await prefs.setString('user_name', user.fullName);
    await prefs.setString('user_pic', user.profilePicUrl ?? '');
  }

  Future<void> _loadUserFromPrefs() async {
    // If we already have _currentUser, don't overwrite with partial data
    if (_currentUser != null) return;

    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    if (name != null) {
      // Create a dummy user object for immediate UI
      // We don't have all data, but this prevents "empty" profile
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _apiService.updateProfile(data);
      if (user != null) {
        _currentUser = user;
        _saveUserToPrefs(user);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating profile in provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
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
