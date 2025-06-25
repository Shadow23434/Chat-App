import 'package:chat_app/chat_app_ui/features/story/domain/entities/story_entity.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/repositories/story_repository.dart';
import 'package:chat_app/chat_app_ui/core/usecases/usecase.dart';
import 'package:chat_app/chat_app_ui/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class GetOwnStoriesUseCase implements UseCase<List<StoryEntity>, NoParams> {
  final StoryRepository repository;

  GetOwnStoriesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<StoryEntity>>> call(NoParams params) async {
    try {
      final stories = await repository.getOwnStories();
      return Right(stories);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
