import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/patrol.dart';

class PatrolService {
  static final PatrolService _instance = PatrolService._internal();
  factory PatrolService() => _instance;
  PatrolService._internal();

  final String baseUrl = API_BASE_URL;

  // Get all patrols
  Future<List<Patrol>> getPatrols() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patrols'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((patrol) => Patrol.fromJson(patrol)).toList();
      } else {
        throw Exception('Failed to load patrols: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading patrols: $e');
    }
  }

  // Get patrols by officer
  Future<List<Patrol>> getPatrolsByOfficer(String officerUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patrols/officer/$officerUUID'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((patrol) => Patrol.fromJson(patrol)).toList();
      } else {
        throw Exception('Failed to load officer patrols: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading officer patrols: $e');
    }
  }

  // Get patrol stats
  Future<Map<String, dynamic>> getPatrolStats() async {
    try {
      final patrols = await getPatrols();
      final totalPatrols = patrols.length;
      final anomalies = patrols.where((p) => p.anomalyFlag).length;
      final todayPatrols = patrols.where((p) {
        final today = DateTime.now();
        return p.timestamp.year == today.year &&
            p.timestamp.month == today.month &&
            p.timestamp.day == today.day;
      }).length;

      return {
        'totalPatrols': totalPatrols,
        'anomalies': anomalies,
        'todayPatrols': todayPatrols,
        'completionRate': totalPatrols > 0 ? ((todayPatrols / 10) * 100).clamp(0, 100).toInt() : 0,
      };
    } catch (e) {
      throw Exception('Error calculating patrol stats: $e');
    }
  }

  // Create new patrol
  Future<Patrol> createPatrol({
    required String officerUUID,
    required String checkpointUUID,
    required String comment,
    required bool anomalyFlag,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patrols/$officerUUID/$checkpointUUID?'
            'comment=${Uri.encodeComponent(comment)}'
            '&anomalyFlag=$anomalyFlag'
            '&latitude=$latitude'
            '&longitude=$longitude'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Patrol.fromJson(data);
      } else {
        throw Exception('Failed to create patrol: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating patrol: $e');
    }
  }
}