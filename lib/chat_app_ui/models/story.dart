import 'package:equatable/equatable.dart';

class Story extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String mediaUrl;
  final String mediaName;
  final String caption;
  final int likes;
  final DateTime createdAt;

  const Story({
    required this.id,
    required this.userId,
    required this.type,
    required this.mediaUrl,
    required this.mediaName,
    required this.caption,
    required this.likes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    mediaUrl,
    mediaName,
    caption,
    likes,
    createdAt,
  ];
}
