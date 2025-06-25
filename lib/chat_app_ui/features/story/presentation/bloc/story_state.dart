import 'package:equatable/equatable.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/entities/story_entity.dart';

abstract class StoryState extends Equatable {
  const StoryState();

  @override
  List<Object?> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoriesLoaded extends StoryState {
  final List<StoryEntity> stories;

  const StoriesLoaded({required this.stories});

  @override
  List<Object?> get props => [stories];
}

class OwnStoriesLoaded extends StoryState {
  final List<StoryEntity> stories;

  const OwnStoriesLoaded({required this.stories});

  @override
  List<Object?> get props => [stories];
}

class StoryCreated extends StoryState {
  final StoryEntity story;

  const StoryCreated({required this.story});

  @override
  List<Object?> get props => [story];
}

class StoryLiked extends StoryState {
  final String storyId;
  final int likes;

  const StoryLiked({required this.storyId, required this.likes});

  @override
  List<Object?> get props => [storyId, likes];
}

class StoryUnliked extends StoryState {
  final String storyId;
  final int likes;

  const StoryUnliked({required this.storyId, required this.likes});

  @override
  List<Object?> get props => [storyId, likes];
}

class StoryDeleted extends StoryState {
  final String storyId;

  const StoryDeleted({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

class StoryError extends StoryState {
  final String message;

  const StoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
