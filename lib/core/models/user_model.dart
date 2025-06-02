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

    // Handle MongoDB ObjectId format or regular string format
    String userId;
    if (json['_id'] is Map && json['_id'].containsKey('\$oid')) {
      userId = json['_id']['\$oid'];
    } else if (json['_id'] is String) {
      userId = json['_id'];
    } else if (json['id'] is String) {
      userId = json['id'];
    } else {
      userId = json['_id']?.toString() ?? '';
    }

    if (userId.isEmpty) {
      throw Exception('Invalid user ID in UserModel.fromJson');
    }

    return UserModel(
      id: userId,
      username: json['username'].toString(),
      email: json['email'].toString(),
      gender: json['gender'].toString(),
      phoneNumber: json['phoneNumber']?.toString() ?? 'Unknown',
      profilePic: json['profilePic'].toString(),
      role: json['role'].toString(),
      lastLogin:
          json['lastLogin'] != null
              ? DateTime.parse(
                json['lastLogin'] is String
                    ? json['lastLogin']
                    : json['lastLogin']['\$date'],
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
