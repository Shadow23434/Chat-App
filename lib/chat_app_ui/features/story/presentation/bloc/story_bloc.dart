import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/get_stories_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/get_own_stories_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/create_story_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/like_story_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/unlike_story_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/delete_story_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/presentation/bloc/story_event.dart';
import 'package:chat_app/chat_app_ui/features/story/presentation/bloc/story_state.dart';
import 'package:chat_app/chat_app_ui/core/usecases/usecase.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final GetStoriesUseCase getStoriesUseCase;
  final GetOwnStoriesUseCase getOwnStoriesUseCase;
  final CreateStoryUseCase createStoryUseCase;
  final LikeStoryUseCase likeStoryUseCase;
  final UnlikeStoryUseCase unlikeStoryUseCase;
  final DeleteStoryUseCase deleteStoryUseCase;

  StoryBloc({
    required this.getStoriesUseCase,
    required this.getOwnStoriesUseCase,
    required this.createStoryUseCase,
    required this.likeStoryUseCase,
    required this.unlikeStoryUseCase,
    required this.deleteStoryUseCase,
  }) : super(StoryInitial()) {
    on<GetStories>(_onGetStories);
    on<GetOwnStories>(_onGetOwnStories);
    on<CreateStory>(_onCreateStory);
    on<LikeStory>(_onLikeStory);
    on<UnlikeStory>(_onUnlikeStory);
    on<DeleteStory>(_onDeleteStory);
  }

  Future<void> _onGetStories(GetStories event, Emitter<StoryState> emit) async {
    emit(StoryLoading());

    final result = await getStoriesUseCase(NoParams());

    result.fold(
      (failure) => emit(StoryError(message: failure.toString())),
      (stories) => emit(StoriesLoaded(stories: stories)),
    );
  }

  Future<void> _onGetOwnStories(
    GetOwnStories event,
    Emitter<StoryState> emit,
  ) async {
    emit(StoryLoading());

    final result = await getOwnStoriesUseCase(NoParams());

    result.fold(
      (failure) => emit(StoryError(message: failure.toString())),
      (stories) => emit(OwnStoriesLoaded(stories: stories)),
    );
  }

  Future<void> _onCreateStory(
    CreateStory event,
    Emitter<StoryState> emit,
  ) async {
    emit(StoryLoading());

    final params = CreateStoryParams(
      caption: event.caption,
      type: event.type,
      mediaName: event.mediaName,
      mediaUrl: event.mediaUrl,
      backgroundUrl: event.backgroundUrl,
    );

    final result = await createStoryUseCase(params);

    result.fold(
      (failure) => emit(StoryError(message: failure.toString())),
      (story) => emit(StoryCreated(story: story)),
    );
  }

  Future<void> _onLikeStory(LikeStory event, Emitter<StoryState> emit) async {
    final params = LikeStoryParams(storyId: event.storyId);

    final result = await likeStoryUseCase(params);

    result.fold(
      (failure) => emit(StoryError(message: failure.toString())),
      (likes) => emit(StoryLiked(storyId: event.storyId, likes: likes)),
    );
  }

  Future<void> _onUnlikeStory(
    UnlikeStory event,
    Emitter<StoryState> emit,
  ) async {
    final params = UnlikeStoryParams(storyId: event.storyId);

    final result = await unlikeStoryUseCase(params);

    result.fold(
      (failure) => emit(StoryError(message: failure.toString())),
      (likes) => emit(StoryUnliked(storyId: event.storyId, likes: likes)),
    );
  }

  Future<void> _onDeleteStory(
    DeleteStory event,
    Emitter<StoryState> emit,
  ) async {
    final params = DeleteStoryParams(storyId: event.storyId);

    final result = await deleteStoryUseCase(params);

    result.fold(
      (failure) => emit(StoryError(message: failure.toString())),
      (_) => emit(StoryDeleted(storyId: event.storyId)),
    );
  }
}
