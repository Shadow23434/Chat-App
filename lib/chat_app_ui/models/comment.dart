import 'package:chat_app/admin_panel_ui/models/users.dart';
import 'package:chat_app/chat_app_ui/models/models.dart';

class Comment {
  Comment({
    required this.id,
    required this.userId,
    required this.storyId,
    this.parentCommentId,
    required this.content,
    required this.createdAt,
    required this.likes,
  });

  final String id;
  final String userId;
  final String storyId;
  final String? parentCommentId;
  final String content;
  final DateTime createdAt;
  final int likes;

  static Map<String, List<Comment>> generateDemoComments(
    List<Story> stories,
    List<User> users,
  ) {
    final Map<String, List<Comment>> storyComments = {};

    for (var story in stories) {
      storyComments[story.id] = [];
    }

    final parentComment1Id = faker.guid.guid();
    storyComments[stories[0].id] = [
      Comment(
        id: parentComment1Id,
        userId: users[1].id, // Jane Doe
        storyId: stories[0].id,
        parentCommentId: null,
        content: 'Looks amazing! Where is this beach?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
        likes: 5,
      ),
      Comment(
        id: faker.guid.guid(),
        userId: users[2].id, // Alex Carter
        storyId: stories[0].id,
        parentCommentId: null,
        content: 'Love the vibes!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
        likes: 0,
      ),
      Comment(
        id: faker.guid.guid(),
        userId: users[0].id, // Gordon Amat
        storyId: stories[0].id,
        parentCommentId: parentComment1Id,
        content: faker.lorem.sentence(),
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        likes: faker.randomGenerator.integer(5),
      ),
      Comment(
        id: faker.guid.guid(),
        userId: users[2].id, // Alex Carter
        storyId: stories[0].id,
        parentCommentId: parentComment1Id,
        content: 'I’ve been there too!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 42)),
        likes: 3,
      ),
    ];

    final parentComment2Id = faker.guid.guid();
    storyComments[stories[1].id] = [
      Comment(
        id: parentComment2Id,
        userId: users[0].id, // Gordon Amat
        storyId: stories[1].id,
        parentCommentId: null,
        content: 'Which city is this?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likes: 2,
      ),
      Comment(
        id: faker.guid.guid(),
        userId: users[1].id, // Jane Doe
        storyId: stories[1].id,
        parentCommentId: parentComment2Id,
        content: 'Looks like New York!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        likes: faker.randomGenerator.integer(3),
      ),
      Comment(
        id: faker.guid.guid(),
        userId: users[2].id, // Alex Carter
        storyId: stories[1].id,
        parentCommentId: null,
        content: faker.lorem.sentence(),
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        likes: 1,
      ),
    ];

    return storyComments;
  }
}
