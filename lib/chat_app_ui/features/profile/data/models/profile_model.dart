import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.id,
    required super.username,
    required super.email,
    super.gender,
    super.phoneNumber,
    super.profilePic,
    super.contactStatus,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      profilePic: json['profilePic'],
      contactStatus: json['contactStatus'],
    );
  }
}
