class Patrol {
  final String patrolUUID;
  final String officerUUID;
  final String checkpointUUID;
  final String? officerName;
  final String? checkpointName;
  final String? checkpointCode;
  final String? checkpointType;
  final String comment;
  final bool anomalyFlag;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Patrol({
    required this.patrolUUID,
    required this.officerUUID,
    required this.checkpointUUID,
    this.officerName,
    this.checkpointName,
    this.checkpointCode,
    this.checkpointType,
    required this.comment,
    required this.anomalyFlag,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory Patrol.fromJson(Map<String, dynamic> json) {
    return Patrol(
      patrolUUID: json['patrolUUID'] ?? '',
      officerUUID: json['officerUUID'] ?? '',
      checkpointUUID: json['checkpointUUID'] ?? '',
      officerName: json['officerName'],
      checkpointName: json['checkpointName'],
      checkpointCode: json['checkpointCode'],
      checkpointType: json['checkpointType'],
      comment: json['comment'] ?? '',
      anomalyFlag: json['anomalyFlag'] ?? false,
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  // Helper method to get display name for checkpoint
  String get checkpointDisplayName {
    if (checkpointName != null && checkpointCode != null) {
      return '$checkpointCode - $checkpointName';
    } else if (checkpointName != null) {
      return checkpointName!;
    } else if (checkpointCode != null) {
      return checkpointCode!;
    } else {
      return 'Checkpoint ${checkpointUUID.substring(0, 8)}...';
    }
  }
}