import 'package:dio/dio.dart';
import 'dart:io';
import '../core/constants.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/listing.dart';
import '../models/property.dart';
import '../models/chat.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/config.dart';
import '../models/discovery_place.dart';

class ApiService {
  late final Dio _dio;
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['accessToken']);
        await prefs.setString('refreshToken', data['refreshToken']);
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/register', data: userData);
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['accessToken']);
        await prefs.setString('refreshToken', data['refreshToken']);
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Register error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  Future<Map<String, dynamic>?> googleLogin(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google-login',
        data: {'idToken': idToken},
      );
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['accessToken']);
        await prefs.setString('refreshToken', data['refreshToken']);
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Google login error: $e');
      return null;
    }
  }

  Future<UserBasic?> getMe() async {
    try {
      final response = await _dio.get('/users/me');
      if (response.statusCode == 200) {
        return UserBasic.fromJson(Map<String, dynamic>.from(response.data));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      return null;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/users/profile', data: data);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  Future<UserBasic?> toggleElite() async {
    try {
      final response = await _dio.post('/users/toggle-elite');
      if (response.statusCode == 200) {
        return UserBasic.fromJson(Map<String, dynamic>.from(response.data));
      }
      return null;
    } catch (e) {
      debugPrint('Error toggling elite: $e');
      return null;
    }
  }

  Future<List<SystemConfig>> getConfigs() async {
    try {
      final response = await _dio.get('/config');
      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data
            .map<SystemConfig>(
              (json) => SystemConfig.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching configs: $e');
      return [];
    }
  }

  // ─── Marketplace ──────────────────────────────────────────────────────────

  Future<List<Listing>> getListings({
    String? categoryId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (filters != null) queryParams.addAll(filters);

      final response = await _dio.get(
        '/listings',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data.map<Listing>((json) {
          final listingJson = Map<String, dynamic>.from(json);
          if (listingJson['images'] != null) {
            listingJson['images'] = (listingJson['images'] as List)
                .map((img) => _normalizeImageUrl(img.toString()))
                .toList();
          }
          return Listing.fromJson(listingJson);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching listings: $e');
      return [];
    }
  }

  /// Feature: AI Price Suggestion — returns price range based on similar listings.
  Future<Map<String, dynamic>?> suggestPrice({
    required String categoryId,
    String? subcategoryId,
  }) async {
    try {
      final response = await _dio.post(
        '/listings/price-suggest',
        data: {
          'category_id': categoryId,
          if (subcategoryId != null) 'subcategory_id': subcategoryId,
        },
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      debugPrint('Error suggesting price: $e');
    }
    return null;
  }

  /// Feature: Phone Verification — sends OTP.
  Future<Map<String, dynamic>?> sendPhoneOtp(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/users/verify/phone/send',
        data: {'phone_number': phoneNumber},
      );
      if (response.statusCode == 200) return Map<String, dynamic>.from(response.data);
    } catch (e) {
      debugPrint('Error sending OTP: $e');
    }
    return null;
  }

  /// Feature: Phone Verification — confirms OTP and upgrades verification_level.
  Future<Map<String, dynamic>?> confirmPhoneOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post(
        '/users/verify/phone/confirm',
        data: {'phone_number': phoneNumber, 'otp': otp},
      );
      if (response.statusCode == 200) return Map<String, dynamic>.from(response.data);
    } catch (e) {
      debugPrint('Error confirming OTP: $e');
    }
    return null;
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/listings/categories');
      if (response.statusCode == 200) {
        final List data = (response.data is Map)
            ? response.data['categories'] ?? []
            : response.data as List;
        return data
            .map<Category>(
              (json) => Category.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<Listing>> getMyListings() async {
    try {
      final response = await _dio.get('/listings/my');
      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data.map<Listing>((json) {
          final listingJson = Map<String, dynamic>.from(json);
          if (listingJson['images'] != null) {
            listingJson['images'] = (listingJson['images'] as List)
                .map((img) => _normalizeImageUrl(img.toString()))
                .toList();
          }
          return Listing.fromJson(listingJson);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching my listings: $e');
      return [];
    }
  }

  Future<Listing?> createListing(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/listings', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Listing.fromJson(Map<String, dynamic>.from(response.data));
      }
      return null;
    } catch (e) {
      debugPrint('Error creating listing: $e');
      return null;
    }
  }

  Future<List<Property>> getProperties() async {
    try {
      final response = await _dio.get('/properties');
      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data.map<Property>((json) {
          final propJson = Map<String, dynamic>.from(json);
          if (propJson['images'] != null) {
            propJson['images'] = (propJson['images'] as List)
                .map((img) => _normalizeImageUrl(img.toString()))
                .toList();
          }
          return Property.fromJson(propJson);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching properties: $e');
      return [];
    }
  }

  Future<Property?> createProperty(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/properties', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Property.fromJson(Map<String, dynamic>.from(response.data));
      }
      return null;
    } catch (e) {
      debugPrint('Error creating property: $e');
      return null;
    }
  }

  Future<List<String>> uploadImages(List<dynamic> imageFiles) async {
    try {
      final List<MultipartFile> multipartFiles = [];
      for (var file in imageFiles) {
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          multipartFiles.add(
            MultipartFile.fromBytes(bytes, filename: file.name as String),
          );
        } else {
          multipartFiles.add(
            await MultipartFile.fromFile(
              file.path as String,
              filename: (file.path as String).split('/').last,
            ),
          );
        }
      }
      final formData = FormData.fromMap({'files': multipartFiles});
      final response = await _dio.post('/upload', data: formData);
      if (response.statusCode == 200) {
        final List urls = response.data['urls'] as List;
        final base = _dio.options.baseUrl.replaceAll('/api', '');
        return urls.map((url) => '$base$url').toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error uploading images: $e');
      return [];
    }
  }

  Future<String?> uploadVideo(File videoFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          videoFile.path,
          filename: videoFile.path.split('/').last,
        ),
      });
      final response = await _dio.post('/upload/video', data: formData);
      if (response.statusCode == 200) {
        final String url = response.data['url'] as String;
        final base = _dio.options.baseUrl.replaceAll('/api', '');
        return '$base$url';
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading video: $e');
      return null;
    }
  }

  Future<List<Listing>> getFreshRecommendations() async {
    try {
      final response = await _dio.get('/listings/home/fresh');
      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data.map<Listing>((json) {
          final listingJson = Map<String, dynamic>.from(json);
          if (listingJson['images'] != null) {
            listingJson['images'] = (listingJson['images'] as List)
                .map((img) => _normalizeImageUrl(img.toString()))
                .toList();
          }
          return Listing.fromJson(listingJson);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching fresh recommendations: $e');
      return [];
    }
  }

  Future<List<Listing>> getRecentInteractions() async {
    try {
      final response = await _dio.get('/listings/home/recent');
      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data.map<Listing>((json) {
          final listingJson = Map<String, dynamic>.from(json);
          if (listingJson['images'] != null) {
            listingJson['images'] = (listingJson['images'] as List)
                .map((img) => _normalizeImageUrl(img.toString()))
                .toList();
          }
          return Listing.fromJson(listingJson);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching recent interactions: $e');
      return [];
    }
  }

  Future<bool> trackInteraction(String listingId, String type) async {
    try {
      await _dio.post(
        '/listings/$listingId/interact',
        queryParameters: {'interaction_type': type},
      );
      return true;
    } catch (e) {
      debugPrint('Error tracking interaction: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getSellerProfile(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/profile');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching seller profile: $e');
      return null;
    }
  }

  Future<bool> followUser(String userId) async {
    try {
      final response = await _dio.post('/users/$userId/follow');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error following user: $e');
      return false;
    }
  }

  // ─── Chat ─────────────────────────────────────────────────────────────────

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _dio.get('/chat/conversations');
      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data
            .map(
              (json) => Conversation.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
      return [];
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final response = await _dio.get('/chat/messages/$conversationId');
      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data
            .map(
              (json) => ChatMessage.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      return [];
    }
  }

  Future<ChatMessage?> sendMessage(
    String conversationId,
    String content,
  ) async {
    try {
      final response = await _dio.post(
        '/chat/messages',
        data: {'conversation_id': conversationId, 'content': content},
      );
      if (response.statusCode == 200) {
        return ChatMessage.fromJson(Map<String, dynamic>.from(response.data));
      }
      return null;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return null;
    }
  }

  Future<Conversation?> startConversation(
    String otherUserId, {
    String? listingId,
    String? propertyId,
    String? initialMessage,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'other_user_id': otherUserId};
      if (listingId != null) queryParams['listing_id'] = listingId;
      if (propertyId != null) queryParams['property_id'] = propertyId;
      if (initialMessage != null) {
        queryParams['initial_message'] = initialMessage;
      }
      final response = await _dio.post(
        '/chat/start',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return Conversation.fromJson(Map<String, dynamic>.from(response.data));
      }
      return null;
    } catch (e) {
      debugPrint('Error starting conversation: $e');
      return null;
    }
  }

  String _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') return '';
    if (url.startsWith('http')) return url;

    // Sanitize Windows backslashes
    String sanitized = url.replaceAll('\\', '/');
    if (!sanitized.startsWith('/')) {
      sanitized = '/$sanitized';
    }

    return '$base$sanitized';
  }

  // ─── Discovery ────────────────────────────────────────────────────────────

  Future<List<DiscoveryPlace>> getNearbyDiscovery({
    required double lat,
    required double lng,
    String category = 'tourist_attraction',
  }) async {
    try {
      final response = await _dio.get(
        '/discovery/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'category': category,
        },
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => DiscoveryPlace.fromJson(json))
            .toList();
      }
    }
  }

  Future<List<Map<String, dynamic>>> searchLocations(String input) async {
    try {
      final response = await _dio.get('/discovery/autocomplete', queryParameters: {'input': input});
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      debugPrint('Autocomplete error: $e');
      return [];
    }
  }

  Future<Map<String, double>?> getLocationDetails(String placeId) async {
    try {
      final response = await _dio.get('/discovery/details', queryParameters: {'place_id': placeId});
      if (response.statusCode == 200) {
        return {
          'lat': (response.data['lat'] as num).toDouble(),
          'lng': (response.data['lng'] as num).toDouble(),
        };
      }
      return null;
    } catch (e) {
      debugPrint('Details error: $e');
      return null;
    }
  }
}
