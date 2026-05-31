import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/SeekerProfile.dart';

class ApiService {
  // Note:change Url when connection to onther WI-FI
  static const String baseUrl = 'http://192.168.1.145:8000/api';

  // ── Helpers ──────────────────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  /*
  This function prepares the headers for API requests, including the data type (JSON)
  and the authentication token (Bearer token) if the user is logged in,
   so the server can identify the user and handle the request correctly.
   */

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Auth ──────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: await _getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      return data;
    }
    throw Exception(data['message'] ?? 'Login failed');
  }

  static Future<bool> logout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      return data;
    }
    String errorMsg = data['message'] ?? 'Registration failed';
    if (data['errors'] != null) {
      errorMsg = (data['errors'] as Map).values.first[0];
    }
    throw Exception(errorMsg);
  }

  // ── Profile ───────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load profile');
  }

  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/profile'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) return true;
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Failed to update profile');
  }

  static Future<bool> updateCity(String city) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/profile/city'),
      headers: await _getHeaders(),
      body: jsonEncode({'city': city}),
    );
    return response.statusCode == 200;
  }

  // ── Change password ───────────────────────────────────────────────────────────
  // Endpoint: POST /api/profile/password  (ProfileController::changePassword)
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/password'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    if (response.statusCode == 200) return true;
    final data = jsonDecode(response.body);
    throw Exception(data['message'] ?? 'Password change failed');
  }

  // ── Forgot password ───────────────────────────────────────────────────────────
  // Endpoint: POST /api/forgot-password  (AuthController::forgotPassword)
  // Backend uses Password::sendResetLink() → returns {"success":true} on 200
  // or {"success":false,"message":"Email not found"} on 404.
  static Future<bool> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );
    final data = jsonDecode(response.body);
    debugPrint("Forgot Password Response: $data");

    // Backend returns 200 + {success:true} on success
    if (response.statusCode == 200 && data['success'] == true) return true;

    // Surface the server message ("Email not found", etc.)
    throw Exception(data['message'] ?? 'Failed to send reset link');
  }

  // ── Reset password ────────────────────────────────────────────────────────────
  // Laravel's Password::sendResetLink sends a signed URL pointing to the WEB
  // reset form — there is no dedicated API reset endpoint by default.
  // To support in-app reset you must add a custom API route in api.php:
  //   Route::post('/reset-password', [AuthController::class, 'resetPassword']);
  // and implement it to call Password::reset().
  // Until then this method calls that custom endpoint.
  static Future<bool> resetPassword({
    required String email,
    required String code, // the token from the reset URL query param
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'token': code,
        'password': newPassword,
        'password_confirmation': newPassword,
      }),
    );
    if (response.statusCode == 200) return true;
    final data = jsonDecode(response.body);
    throw Exception(data['message'] ?? 'Failed to reset password');
  }

  // ── Jobs ──────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getJobs(
      {String? search, String? location, int? skillId, int page = 1}) async {
    String url = '$baseUrl/jobs?page=$page';
    if (search != null) url += '&search=$search';
    if (location != null) url += '&location=$location';
    if (skillId != null) url += '&skill_id=$skillId';

    final response =
        await http.get(Uri.parse(url), headers: await _getHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('فشل في جلب الوظائف');
  }

  static Future<bool> applyToJob(int jobId, String? message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/jobs/$jobId/apply'),
      headers: await _getHeaders(),
      body: jsonEncode({'message': message}),
    );
    return response.statusCode == 201;
  }

  static Future<List<dynamic>> getMyApplications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/applications'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // BUG FIX #4: ApplicationController returns a plain JSON array [], not
      // {"data":[...]}. Guard both shapes so a future backend change won't break.
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['data'] is List) return decoded['data'];
      return [];
    }
    throw Exception('فشل في جلب قائمة التقديم');
  }

  // BUG FIX #5: new method that calls the real backend MatchingService.
  // Returns the same shape as JobController::match() → List of match objects.
  static Future<List<dynamic>> getMatchedJobs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/jobs/match'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['data'] is List) return decoded['data'];
      return [];
    }
    throw Exception('فشل في جلب الوظائف المقترحة');
  }

  static Future<bool> cancelApplication(int applicationId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/applications/$applicationId/cancel'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }

  // ── Skills ────────────────────────────────────────────────────────────────────

  // Returns raw categories list: [{name, skills:[{id,name},...]}]
  static Future<List<dynamic>> getSkills() async {
    final response = await http.get(
      Uri.parse('$baseUrl/skills'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load skills");
    }
  }

  // BUG FIX #2: getSkillsFlat() — new helper that flattens the nested categories
  // response into a simple list of SkillItem objects.
  // The profile screen was using a hardcoded _databaseSkills list instead of
  // fetching from the real database, so the user could not pick backend skills.
  static Future<List<SkillItem>> getSkillsFlat() async {
    final categories = await getSkills();

    final List<SkillItem> flat = [];

    for (final cat in categories) {
      final categoryName = cat['category_name']?.toString() ?? '';

      final skills = cat['skills'] as List<dynamic>? ?? [];

      for (final s in skills) {
        flat.add(
          SkillItem(
            id: s['skill_id'],
            name: s['skill_name'],
            category: categoryName,
          ),
        );
      }
    }

    return flat;
  }

  // Syncs the user's selected skills by sending IDs to the backend
  static Future<bool> syncUserSkills(List<int> skillIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/skills'),
      headers: await _getHeaders(),
      body: jsonEncode({'skill_ids': skillIds}),
    );
    return response.statusCode == 200;
  }

  // ── Notifications ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('فشل في جلب الإشعارات');
  }

  static Future<bool> markNotificationAsRead(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }

  static Future<bool> markAllNotificationsAsRead() async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }

  // Endpoint: DELETE /api/notifications/{id}  (NotificationController::destroy)
  static Future<bool> deleteNotification(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$id'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }

  // ── Availability ──────────────────────────────────────────────────────────────
  static Future<bool> addAvailability(String date, String time) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/availability'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'available_date': date,
        'available_time': time,
      }),
    );
    return response.statusCode == 201;
  }

  static Future<bool> deleteAvailability(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/profile/availability/$id'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }

  // ── Cities ────────────────────────────────────────────────────────────────────
  // BUG FIX #1: getCities() was returning wrong data in some cases.
  // The old code did: jsonResponse['data'] ?? jsonResponse
  // which failed when the backend returned a plain array [] without a 'data' key,
  // or when it returned an object without the expected shape.
  // New code handles all three common shapes the backend might return.
  static Future<List<dynamic>> getCities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cities'),
        headers: await _getHeaders(),
      );
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);

      // Shape A: plain array  → [{"id":1,"name":"عمان"}, ...]
      if (decoded is List) return decoded;

      // Shape B: Laravel paginator or resource  → {"data": [...]}
      if (decoded is Map && decoded['data'] is List) return decoded['data'];

      // Shape C: {"cities": [...]}
      if (decoded is Map && decoded['cities'] is List) return decoded['cities'];

      return [];
    } catch (e) {
      debugPrint('getCities error: $e');
      return [];
    }
  }
}
