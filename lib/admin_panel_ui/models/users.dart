class User {
  final String id;
  final String username;
  final String email;
  final String gender;
  final String profilePic;
  final String phoneNumber;
  final bool isVerified;
  final String lastLogin;
  final String createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.gender,
    required this.profilePic,
    this.phoneNumber = '',
    this.isVerified = false,
    required this.lastLogin,
    required this.createdAt,
  });
}
