class Story {
  final String id;
  final String caption;
  final String type;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String mediaName;
  final int likes;
  final String mediaUrl;
  final String userId;
  final String backgroundUrl;

  Story({
    required this.id,
    required this.caption,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    required this.mediaName,
    required this.likes,
    required this.mediaUrl,
    required this.userId,
    required this.backgroundUrl,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['_id']?['\$oid'] ?? '',
      caption: json['caption'] ?? '',
      type: json['type'] ?? '',
      createdAt:
          json['createdAt'] != null && json['createdAt']['\$date'] != null
              ? DateTime.parse(json['createdAt']['\$date'])
              : DateTime.now(),
      expiresAt:
          json['expiresAt'] != null && json['expiresAt']['\$date'] != null
              ? DateTime.parse(json['expiresAt']['\$date'])
              : DateTime.now().add(Duration(hours: 24)),
      mediaName: json['mediaName'] ?? '',
      likes: json['likes'] ?? 0,
      mediaUrl: json['mediaUrl'] ?? '',
      userId: json['userId']?['\$oid'] ?? '',
      backgroundUrl: json['backgroundUrl'] ?? '',
    );
  }
}
