class Checkpoint {
  final String checkpointUUID;
  final String code;
  final String name;
  final String type;
  final String description;
  final String location;
  final String? houseUUID;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Checkpoint({
    required this.checkpointUUID,
    required this.code,
    required this.name,
    required this.type,
    required this.description,
    required this.location,
    this.houseUUID,
    this.createdAt,
    this.updatedAt,
  });

  factory Checkpoint.fromJson(Map<String, dynamic> json) {
    return Checkpoint(
      checkpointUUID: json['checkpointUUID'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'GATE',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      houseUUID: json['houseUUID'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkpointUUID': checkpointUUID,
      'code': code,
      'name': name,
      'type': type,
      'description': description,
      'location': location,
      'houseUUID': houseUUID,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get displayName => '$code - $name ($type)';
  String get fullInfo => '$code - $name\n$description\nLocation: $location';
}