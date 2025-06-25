import 'package:chat_app/chat_app_ui/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.password,
    super.gender,
    super.phoneNumber,
    super.profilePic,
    super.lastLogin,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      profilePic: json['profilePic'] as String? ?? '',
      lastLogin:
          json['lastLogin'] != null
              ? DateTime.parse(json['lastLogin'] as String)
              : null,
      token: json['token'],
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? gender,
    String? phoneNumber,
    String? profilePic,
    DateTime? lastLogin,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePic: profilePic ?? this.profilePic,
      lastLogin: lastLogin ?? this.lastLogin,
      token: token ?? this.token,
    );
  }
}
