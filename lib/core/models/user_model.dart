class UserModel {
  final String id;
  final String username;
  final String email;
  final String gender;
  final String? phoneNumber;
  final String profilePic;
  final String role;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.gender,
    this.phoneNumber,
    required this.profilePic,
    required this.role,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw Exception('Empty JSON data provided to UserModel.fromJson');
    }

    // Handle MongoDB ObjectId format or regular string/number format
    String userId = '';
    if (json['_id'] is Map && json['_id'].containsKey('\$oid')) {
      userId = json['_id']['\$oid'].toString();
    } else if (json['_id'] != null) {
      userId = json['_id'].toString();
    } else if (json['id'] != null) {
      userId = json['id'].toString();
    } else {
      userId = 'unknown';
    }

    return UserModel(
      id: userId,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'unknown',
      phoneNumber: json['phoneNumber']?.toString(),
      profilePic: json['profilePic']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      lastLogin:
          json['lastLogin'] != null
              ? DateTime.tryParse(
                json['lastLogin'] is String
                    ? json['lastLogin']
                    : (json['lastLogin']?['\$date']?.toString() ?? ''),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'role': role,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}
