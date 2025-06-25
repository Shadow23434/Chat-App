abstract class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {
  final String userId;
  GetProfileEvent(this.userId);
}

class EditProfileEvent extends ProfileEvent {
  final Map<String, dynamic> data;
  EditProfileEvent(this.data);
}

class SearchProfileEvent extends ProfileEvent {
  final String query;
  SearchProfileEvent(this.query);
}
