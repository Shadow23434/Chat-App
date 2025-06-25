import 'package:chat_app/chat_app_ui/features/story/domain/repositories/story_repository.dart';
import 'package:chat_app/chat_app_ui/core/usecases/usecase.dart';
import 'package:chat_app/chat_app_ui/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class DeleteStoryParams {
  final String storyId;

  DeleteStoryParams({required this.storyId});
}

class DeleteStoryUseCase implements UseCase<void, DeleteStoryParams> {
  final StoryRepository repository;

  DeleteStoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteStoryParams params) async {
    try {
      await repository.deleteStory(params.storyId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
