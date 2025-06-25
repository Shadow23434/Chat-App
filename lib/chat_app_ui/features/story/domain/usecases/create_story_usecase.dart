import 'package:chat_app/chat_app_ui/features/story/domain/entities/story_entity.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/repositories/story_repository.dart';
import 'package:chat_app/chat_app_ui/core/usecases/usecase.dart';
import 'package:chat_app/chat_app_ui/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class CreateStoryParams {
  final String caption;
  final String type;
  final String? mediaName;
  final String? mediaUrl;
  final String? backgroundUrl;

  CreateStoryParams({
    required this.caption,
    required this.type,
    this.mediaName,
    this.mediaUrl,
    this.backgroundUrl,
  });
}

class CreateStoryUseCase implements UseCase<StoryEntity, CreateStoryParams> {
  final StoryRepository repository;

  CreateStoryUseCase(this.repository);

  @override
  Future<Either<Failure, StoryEntity>> call(CreateStoryParams params) async {
    try {
      final story = await repository.createStory(
        caption: params.caption,
        type: params.type,
        mediaName: params.mediaName,
        mediaUrl: params.mediaUrl,
        backgroundUrl: params.backgroundUrl,
      );
      return Right(story);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
