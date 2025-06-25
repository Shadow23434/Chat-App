class ContactEntity {
  final String contactId;
  final String userId;
  final String username;
  final String? profilePic;
  final String email;
  final String status;

  ContactEntity({
    required this.contactId,
    required this.userId,
    required this.username,
    this.profilePic,
    required this.email,
    required this.status,
  });
}
