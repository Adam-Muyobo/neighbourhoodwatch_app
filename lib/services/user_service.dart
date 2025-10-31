import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final String baseUrl = API_BASE_URL;

  // Update user profile
  Future<User> updateProfile(String userUUID, String name, String email, String phoneNumber) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userUUID'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Profile update failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Profile update error: $e');
    }
  }

  // Get user by ID
  Future<User> getUser(String userUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userUUID'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading user: $e');
    }
  }
}