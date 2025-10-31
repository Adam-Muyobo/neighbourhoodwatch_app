import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../services/patrol_service.dart';
import '../../services/auth_service.dart';
import '../../models/patrol.dart';
import '../../widgets/shared/neumorphic_card.dart';

class PatrolHistoryPage extends StatefulWidget {
  const PatrolHistoryPage({super.key});

  @override
  State<PatrolHistoryPage> createState() => _PatrolHistoryPageState();
}

class _PatrolHistoryPageState extends State<PatrolHistoryPage> {
  final PatrolService _patrolService = PatrolService();
  final AuthService _authService = AuthService();
  List<Patrol> _patrols = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatrols();
  }

  Future<void> _loadPatrols() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final patrols = await _patrolService.getPatrolsByOfficer(user.userUUID);
        setState(() {
          _patrols = patrols;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load patrol history: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(Patrol patrol) {
    return patrol.anomalyFlag ? Colors.orange : Colors.green;
  }

  IconData _getStatusIcon(Patrol patrol) {
    return patrol.anomalyFlag ? Icons.warning : Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrol History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadPatrols,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultMargin),
          child: Column(
            children: [
              // Summary Card
              NeumorphicCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.green, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Patrol History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            '${_patrols.length} patrol${_patrols.length != 1 ? 's' : ''} logged',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Officer',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Patrol List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _patrols.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Patrols Logged',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Scan checkpoint QR codes to log patrols',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: _loadPatrols,
                  child: ListView.builder(
                    itemCount: _patrols.length,
                    itemBuilder: (context, index) {
                      final patrol = _patrols[index];
                      return _buildPatrolCard(patrol);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatrolCard(Patrol patrol) {
    return NeumorphicCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(patrol).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(patrol),
              color: _getStatusColor(patrol),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patrol.checkpointName ?? 'Checkpoint ${patrol.checkpointUUID.substring(0, 8)}...',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patrol.comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${patrol.latitude.toStringAsFixed(4)}, ${patrol.longitude.toStringAsFixed(4)}',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                patrol.formattedTime,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              if (patrol.anomalyFlag)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    'ANOMALY',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}