import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../constants/app_constants.dart';
import '../../services/patrol_service.dart';
import '../../services/auth_service.dart';
import '../../models/checkpoint.dart';
import '../../widgets/shared/neumorphic_card.dart';
import '../../widgets/shared/gradient_button.dart';

class LogPatrolPage extends StatefulWidget {
  final Checkpoint checkpoint;
  final double latitude;
  final double longitude;

  const LogPatrolPage({
    super.key,
    required this.checkpoint,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<LogPatrolPage> createState() => _LogPatrolPageState();
}

class _LogPatrolPageState extends State<LogPatrolPage> {
  final TextEditingController _commentController = TextEditingController();
  final PatrolService _patrolService = PatrolService();
  final AuthService _authService = AuthService();
  bool _anomalyFlag = false;
  bool _isLoading = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _currentPosition = position);
    } catch (e) {
      // Use the provided coordinates as fallback
    }
  }

  Future<void> _submitPatrol() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a comment for this patrol'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _patrolService.createPatrol(
        officerUUID: user.userUUID,
        checkpointUUID: widget.checkpoint.checkpointUUID,
        comment: _commentController.text.trim(),
        anomalyFlag: _anomalyFlag,
        latitude: _currentPosition?.latitude ?? widget.latitude,
        longitude: _currentPosition?.longitude ?? widget.longitude,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patrol logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log patrol: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Patrol'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkpoint Info
              NeumorphicCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Checkpoint Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: Colors.green),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.checkpoint.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.checkpoint.description,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.code, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Code: ${widget.checkpoint.code}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Location: ${widget.checkpoint.location}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.category, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Type: ${widget.checkpoint.type}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.gps_fixed, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Coordinates: ${_currentPosition?.latitude.toStringAsFixed(6) ?? widget.latitude.toStringAsFixed(6)}, '
                              '${_currentPosition?.longitude.toStringAsFixed(6) ?? widget.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Time: ${DateTime.now().toString().substring(0, 16)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Comment Section
              NeumorphicCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patrol Comments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Describe what you observed during this patrol:',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Routine check, all secure. No issues observed.',
                        border: OutlineInputBorder(),
                        labelText: 'Patrol Comments',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Anomaly Flag
              NeumorphicCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report Anomaly',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            'Check this if you observed any suspicious activity or issues',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _anomalyFlag,
                      onChanged: (value) => setState(() => _anomalyFlag = value),
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: _isLoading ? 'LOGGING PATROL...' : 'SUBMIT PATROL',
                  onPressed: _isLoading ? null : _submitPatrol,
                  isLoading: _isLoading,
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.green),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}