import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Add this import
import '../../constants/app_constants.dart';
import '../../services/checkpoint_service.dart';
import '../../services/auth_service.dart';
import '../../models/checkpoint.dart';
import '../../widgets/shared/neumorphic_card.dart';
import '../../widgets/shared/gradient_button.dart';
import 'log_patrol_page.dart';

class CheckpointSelectionPage extends StatefulWidget {
  const CheckpointSelectionPage({super.key});

  @override
  State<CheckpointSelectionPage> createState() => _CheckpointSelectionPageState();
}

class _CheckpointSelectionPageState extends State<CheckpointSelectionPage> {
  final CheckpointService _checkpointService = CheckpointService();
  final AuthService _authService = AuthService();

  List<Checkpoint> _checkpoints = [];
  Checkpoint? _selectedCheckpoint;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCheckpoints();
  }

  Future<void> _loadCheckpoints() async {
    try {
      final checkpoints = await _checkpointService.getCheckpoints();
      setState(() {
        _checkpoints = checkpoints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load checkpoints: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _proceedToLogPatrol() async {
    if (_selectedCheckpoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a checkpoint'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Navigate to patrol logging page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LogPatrolPage(
              checkpoint: _selectedCheckpoint!,
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCheckpointCard(Checkpoint checkpoint) {
    final isSelected = _selectedCheckpoint?.checkpointUUID == checkpoint.checkpointUUID;

    return NeumorphicCard(
      padding: const EdgeInsets.all(16), // Added margin for better spacing
      color: isSelected ? Colors.green[50] : null,
      onTap: () => setState(() => _selectedCheckpoint = checkpoint),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCheckpointIcon(checkpoint.type),
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checkpoint.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSelected ? Colors.green : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  checkpoint.description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      checkpoint.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }

  IconData _getCheckpointIcon(String type) {
    switch (type.toUpperCase()) {
      case 'GATE':
        return Icons.fence;
      case 'HOUSE':
        return Icons.house;
      case 'PATROL':
        return Icons.directions_walk;
      case 'SECURITY':
        return Icons.security;
      default:
        return Icons.location_on;
    }
  }

  String _getCheckpointTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'GATE':
        return 'Gate Checkpoint';
      case 'HOUSE':
        return 'House Checkpoint';
      case 'PATROL':
        return 'Patrol Point';
      case 'SECURITY':
        return 'Security Post';
      default:
        return 'Checkpoint';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Checkpoint'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadCheckpoints,
            tooltip: 'Refresh Checkpoints',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              NeumorphicCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Checkpoint',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the checkpoint you are patrolling from the list below.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Selected Checkpoint (if any)
              if (_selectedCheckpoint != null) ...[
                NeumorphicCard(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green[50],
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Checkpoint:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              _selectedCheckpoint!.displayName,
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Checkpoints List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _checkpoints.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No Checkpoints Available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Checkpoints will appear here once configured by administrators.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        text: 'REFRESH',
                        onPressed: _loadCheckpoints,
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.lightGreen],
                        ),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: _loadCheckpoints,
                  child: ListView.builder(
                    itemCount: _checkpoints.length,
                    itemBuilder: (context, index) {
                      return _buildCheckpointCard(_checkpoints[index]);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: _isSubmitting ? 'PROCESSING...' : 'LOG PATROL AT SELECTED CHECKPOINT',
                  onPressed: _isSubmitting ? null : _proceedToLogPatrol,
                  isLoading: _isSubmitting,
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
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