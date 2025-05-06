class UserEntity {
  final String id;
  final String username;
  final String email;
  final String password;
  final String? phoneNumber;
  final String? gender;
  final String? profilePic;
  final DateTime? lastLogin;
  final String? token;

  UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.gender,
    this.profilePic,
    this.lastLogin,
    this.token,
  });
}
