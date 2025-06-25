import 'package:chat_app/chat_app_ui/features/story/domain/repositories/story_repository.dart';
import 'package:chat_app/chat_app_ui/core/usecases/usecase.dart';
import 'package:chat_app/chat_app_ui/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class LikeStoryParams {
  final String storyId;

  LikeStoryParams({required this.storyId});
}

class LikeStoryUseCase implements UseCase<int, LikeStoryParams> {
  final StoryRepository repository;

  LikeStoryUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(LikeStoryParams params) async {
    try {
      final likes = await repository.likeStory(params.storyId);
      return Right(likes);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
