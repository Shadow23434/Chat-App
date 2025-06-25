import 'package:equatable/equatable.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

class GetStories extends StoryEvent {}

class GetOwnStories extends StoryEvent {}

class CreateStory extends StoryEvent {
  final String caption;
  final String type;
  final String? mediaName;
  final String? mediaUrl;
  final String? backgroundUrl;

  const CreateStory({
    required this.caption,
    required this.type,
    this.mediaName,
    this.mediaUrl,
    this.backgroundUrl,
  });

  @override
  List<Object?> get props => [
    caption,
    type,
    mediaName,
    mediaUrl,
    backgroundUrl,
  ];
}

class LikeStory extends StoryEvent {
  final String storyId;

  const LikeStory({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

class UnlikeStory extends StoryEvent {
  final String storyId;

  const UnlikeStory({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

class DeleteStory extends StoryEvent {
  final String storyId;

  const DeleteStory({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}
