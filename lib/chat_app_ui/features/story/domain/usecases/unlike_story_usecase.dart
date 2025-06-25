import 'package:chat_app/chat_app_ui/features/story/domain/repositories/story_repository.dart';
import 'package:chat_app/chat_app_ui/core/usecases/usecase.dart';
import 'package:chat_app/chat_app_ui/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class UnlikeStoryParams {
  final String storyId;

  UnlikeStoryParams({required this.storyId});
}

class UnlikeStoryUseCase implements UseCase<int, UnlikeStoryParams> {
  final StoryRepository repository;

  UnlikeStoryUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(UnlikeStoryParams params) async {
    try {
      final likes = await repository.unlikeStory(params.storyId);
      return Right(likes);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
