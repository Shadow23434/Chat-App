class ProfileEntity {
  final String id;
  final String username;
  final String email;
  final String? gender;
  final String? phoneNumber;
  final String? profilePic;
  final String? contactStatus;

  ProfileEntity({
    required this.id,
    required this.username,
    required this.email,
    this.gender,
    this.phoneNumber,
    this.profilePic,
    this.contactStatus,
  });
}
