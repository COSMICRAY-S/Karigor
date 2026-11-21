import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/provider_model.dart';

class ApiService {
  // For Android Emulator, use 'http://10.0.2.2:3000/api'
  // For iOS Simulator / Web, use 'http://localhost:3000/api'
  // For Physical Device, use your computer's local IP (e.g. 'http://192.168.0.117:3000/api')
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      }
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  static const bool USE_MOCK = true;

  // ─── AUTH ────────────────────────────────────────────────

  static Future<UserModel?> login(
      String phone, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password, 'role': role}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data['user'], token: data['token']);
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<UserModel?> register(
      String name, String phone, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'role': role
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data['user'], token: data['token']);
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<bool> forgotPassword(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error'] ?? 'Password reset failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ─── PROVIDERS ───────────────────────────────────────────

  static Future<List<ProviderModel>> getProviders({
    String? category,
    double? lat,
    double? lng,
    double radius = 5.0,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (lat != null) queryParams['lat'] = lat.toString();
      if (lng != null) queryParams['lng'] = lng.toString();
      queryParams['radius'] = radius.toString();

      final uri = Uri.parse('$baseUrl/providers').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      print('DEBUG getProviders url: $uri');
      print('DEBUG getProviders status: ${response.statusCode}');
      print('DEBUG getProviders body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('DEBUG parsed ${data.length} providers');
        return data.map((e) => ProviderModel.fromJson(e)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG getProviders error: $e');
      throw Exception('Provider load failed: $e');
    }
  }

  static Future<ProviderModel?> getProviderById(int id) async {
    try {
      final response =
      await http.get(Uri.parse('$baseUrl/providers/$id'));
      if (response.statusCode == 200) {
        return ProviderModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      throw Exception('Provider load failed: $e');
    }
    return null;
  }

  static Future<List<dynamic>> getProviderReviews(int karigorId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/providers/$karigorId/reviews'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception('Reviews load failed: $e');
    }
    return [];
  }

  static Future<bool> updateOnlineStatus(int providerId, bool isOnline) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/providers/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'provider_id': providerId, 'is_online': isOnline}),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Online status update failed: $e');
    }
  }

  static Future<bool> updateLocation(int providerId, double lat, double lng) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/providers/location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'provider_id': providerId, 'latitude': lat, 'longitude': lng}),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Location update failed: $e');
    }
  }

  static Future<bool> addReview(int providerId, int seekerId, int rating, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/providers/$providerId/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'seeker_id': seekerId, 'rating': rating, 'comment': comment}),
      );
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Review submission failed: $e');
    }
  }

  // ─── JOBS ────────────────────────────────────────────────

  static Future<bool> sendJobRequest({
    required int seekerId,
    required int karigorId,
    required String description,
    required String location,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jobs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'seeker_id': seekerId,
          'karigor_id': karigorId,
          'description': description,
          'location': location,
          'amount': amount,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Job request failed: $e');
    }
  }

  static Future<List<dynamic>> getJobsForKarigor(int karigorId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/jobs/karigor/$karigorId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception('Jobs load failed: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getJobsForSeeker(int seekerId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/jobs/seeker/$seekerId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception('Jobs load failed: $e');
    }
    return [];
  }

  static Future<bool> updateJobStatus(int jobId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/jobs/$jobId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Status update failed: $e');
    }
  }
}