import 'package:chat_app/core/models/index.dart';
import 'package:chat_app/admin_panel_ui/services/base/base_service.dart';

class StoryService extends BaseService {
  static final StoryService _instance = StoryService._internal();
  factory StoryService() => _instance;
  StoryService._internal();

  Future<Map<String, dynamic>> getStories({
    int page = 1,
    int limit = 20,
    String sort = 'desc',
    String search = '',
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        if (search.isNotEmpty) 'search': search,
        if (status != null && status != 'all') 'status': status.toLowerCase(),
      };

      final response = await dio.get('/stories', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'stories':
              (data['stories'] as List)
                  .map((story) => StoryModel.fromJson(story))
                  .toList(),
          'pagination': data['pagination'],
        };
      } else {
        throw Exception('Failed to load stories');
      }
    } catch (e) {
      throw Exception('Failed to load stories: $e');
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      final response = await dio.post('/stories/delete/$storyId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete story: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }

  Future<List<CommentModel>> getComments(String storyId) async {
    try {
      final response = await dio.get('/comments/$storyId');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((commentJson) => CommentModel.fromJson(commentJson))
            .toList();
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }
}
