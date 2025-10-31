class User {
  final String userUUID;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.userUUID,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userUUID: json['userUUID'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'MEMBER',
      status: json['status'] ?? 'INACTIVE',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userUUID': userUUID,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get isActive => status == 'ACTIVE';
  bool get isPending => status == 'INACTIVE';
  bool get isSuspended => status == 'SUSPENDED';
  bool get isBlocked => status == 'BLOCKED';
  bool get isMember => role == 'MEMBER';
  bool get isOfficer => role == 'OFFICER';
  bool get isAdmin => role == 'ADMIN';
}