import 'package:chat_app/chat_app_ui/features/story/domain/entities/story_entity.dart';

abstract class StoryRepository {
  Future<List<StoryEntity>> getStories();
  Future<List<StoryEntity>> getOwnStories();
  Future<StoryEntity> createStory({
    required String caption,
    required String type,
    String? mediaName,
    String? mediaUrl,
    String? backgroundUrl,
  });
  Future<int> likeStory(String storyId);
  Future<int> unlikeStory(String storyId);
  Future<void> deleteStory(String storyId);
}
