import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/checkpoint.dart';

class CheckpointService {
  static final CheckpointService _instance = CheckpointService._internal();
  factory CheckpointService() => _instance;
  CheckpointService._internal();

  final String baseUrl = API_BASE_URL;

  // Get all checkpoints
  Future<List<Checkpoint>> getCheckpoints() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/checkpoints'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((checkpoint) => Checkpoint.fromJson(checkpoint)).toList();
      } else {
        throw Exception('Failed to load checkpoints: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading checkpoints: $e');
    }
  }

  // Get checkpoint by UUID
  Future<Checkpoint> getCheckpoint(String checkpointUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/checkpoints/$checkpointUUID'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Checkpoint.fromJson(data);
      } else {
        throw Exception('Failed to load checkpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading checkpoint: $e');
    }
  }

  // Get checkpoint by code
  Future<Checkpoint> getCheckpointByCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/checkpoints/code/$code'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Checkpoint.fromJson(data);
      } else {
        throw Exception('Failed to load checkpoint by code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading checkpoint by code: $e');
    }
  }
}