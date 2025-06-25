import 'package:chat_app/chat_app_ui/features/story/domain/entities/story_entity.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/repositories/story_repository.dart';
import 'package:chat_app/chat_app_ui/features/story/data/datasources/story_remote_data_source.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource remoteDataSource;

  StoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<StoryEntity>> getStories() async {
    return await remoteDataSource.getStories();
  }

  @override
  Future<List<StoryEntity>> getOwnStories() async {
    return await remoteDataSource.getOwnStories();
  }

  @override
  Future<StoryEntity> createStory({
    required String caption,
    required String type,
    String? mediaName,
    String? mediaUrl,
    String? backgroundUrl,
  }) async {
    return await remoteDataSource.createStory(
      caption: caption,
      type: type,
      mediaName: mediaName,
      mediaUrl: mediaUrl,
      backgroundUrl: backgroundUrl,
    );
  }

  @override
  Future<int> likeStory(String storyId) async {
    return await remoteDataSource.likeStory(storyId);
  }

  @override
  Future<int> unlikeStory(String storyId) async {
    return await remoteDataSource.unlikeStory(storyId);
  }

  @override
  Future<void> deleteStory(String storyId) async {
    return await remoteDataSource.deleteStory(storyId);
  }
}
