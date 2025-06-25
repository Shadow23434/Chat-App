class ContactModel {
  final String contactId;
  final String userId;
  final String username;
  final String? profilePic;
  final String email;
  final String status;

  ContactModel({
    required this.contactId,
    required this.userId,
    required this.username,
    this.profilePic,
    required this.email,
    required this.status,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      contactId: json['contactId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      profilePic: json['profilePic'] as String?,
      email: json['email'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactId': contactId,
      'userId': userId,
      'username': username,
      'profilePic': profilePic,
      'email': email,
      'status': status,
    };
  }
}
