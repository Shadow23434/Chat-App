import 'package:chat_app/admin_panel_ui/models/users.dart';
import 'package:faker/faker.dart';
import 'package:meta/meta.dart';

@immutable
class Story {
  const Story({
    required this.id,
    required this.userId,
    required this.caption,
    required this.mediaUrl,
    required this.mediaName,
    required this.type,
    required this.storyUrl,
    required this.createdAt,
    required this.expiresAt,
    required this.likes,
  });

  final String id;
  final String userId;
  final String caption;
  final String type;
  final String mediaUrl;
  final String mediaName;
  final String storyUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int likes;
}

final faker = Faker();
List<Story> generateDemoStories() {
  final now = DateTime.now();
  return [
    Story(
      id: faker.guid.guid(),
      userId: users[0].id, // Gordon Amat
      caption: 'Enjoying a sunny day at the beach!',
      mediaUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      mediaName: 'Beach Vibes',
      type: 'image',
      storyUrl: 'https://example.com/stories/story1',
      createdAt: now.subtract(const Duration(hours: 5)),
      expiresAt: now.add(const Duration(hours: 19)),
      likes: 12,
    ),
    Story(
      id: faker.guid.guid(),
      userId: users[1].id, // Jane Doe
      caption: 'Exploring the city at night.',
      mediaUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba',
      mediaName: 'City Lights',
      type: 'image',
      storyUrl: 'https://example.com/stories/story2',
      createdAt: now.subtract(const Duration(hours: 4)),
      expiresAt: now.add(const Duration(hours: 20)),
      likes: 55,
    ),
    Story(
      id: faker.guid.guid(),
      userId: users[2].id, // Alex Carter
      caption: 'Hiking in the mountains!',
      mediaUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e',
      mediaName: 'Mountain Adventure',
      type: 'image',
      storyUrl: 'https://example.com/stories/story3',
      createdAt: now.subtract(const Duration(hours: 3)),
      expiresAt: now.add(const Duration(hours: 21)),
      likes: 7,
    ),
    Story(
      id: faker.guid.guid(),
      userId: users[3].id, // Sofia Lopez
      caption: 'Coffee break with a view.',
      mediaUrl:
          'https://getwallpapers.com/wallpaper/full/c/c/c/826385-free-1920-by-1080-hd-wallpapers-1920x1080.jpg',
      mediaName: 'Morning Brew',
      type: 'image',
      storyUrl: 'https://example.com/stories/story4',
      createdAt: now.subtract(const Duration(hours: 2, minutes: 30)),
      expiresAt: now.add(const Duration(hours: 21, minutes: 30)),
      likes: 4,
    ),
    Story(
      id: faker.guid.guid(),
      userId: users[4].id, // Liam Nguyen
      caption: 'Chasing sunsets.',
      mediaUrl: 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0',
      mediaName: 'Sunset Glow',
      type: 'image',
      storyUrl: 'https://example.com/stories/story5',
      createdAt: now.subtract(const Duration(hours: 2)),
      expiresAt: now.add(const Duration(hours: 22)),
      likes: 6,
    ),
    Story(
      id: faker.guid.guid(),
      userId: users[5].id, // Emma Watson
      caption: 'Rainy days and cozy vibes.',
      mediaUrl: 'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0',
      mediaName: 'Rainy Mood',
      type: 'image',
      storyUrl: 'https://example.com/stories/story6',
      createdAt: now.subtract(const Duration(hours: 1, minutes: 45)),
      expiresAt: now.add(const Duration(hours: 22, minutes: 15)),
      likes: 11,
    ),
    Story(
      id: faker.guid.guid(),
      userId: users[6].id, // James Patel
      caption: 'Street food adventures!',
      mediaUrl:
          'https://getwallpapers.com/wallpaper/full/e/f/1/826377-1920-by-1080-hd-wallpapers-1920x1080-for-android-40.jpg',
      mediaName: 'Foodie Journey',
      type: 'image',
      storyUrl: 'https://example.com/stories/story7',
      createdAt: now.subtract(const Duration(hours: 1)),
      expiresAt: now.add(const Duration(hours: 23)),
      likes: 3,
    ),
    Story(
      id: faker.guid.guid(),
      userId: users[7].id, // Olivia Kim
      caption: 'Stargazing under the sky.',
      mediaUrl:
          'https://getwallpapers.com/wallpaper/full/9/d/f/826346-most-popular-1920-by-1080-hd-wallpapers-1920x1080-photos.jpg',
      mediaName: 'Starry Night',
      type: 'image',
      storyUrl: 'https://example.com/stories/story8',
      createdAt: now.subtract(const Duration(minutes: 45)),
      expiresAt: now.add(const Duration(hours: 23, minutes: 15)),
      likes: 4,
    ),
    Story(
      id: faker.guid.guid(),
      userId: users[8].id, // Noah Schmidt
      caption: 'Morning run by the lake.',
      mediaUrl:
          'https://getwallpapers.com/wallpaper/full/2/2/d/826461-free-download-1920-by-1080-hd-wallpapers-1920x1080-for-windows-7.jpg',
      mediaName: 'Lake Run',
      type: 'image',
      storyUrl: 'https://example.com/stories/story9',
      createdAt: now.subtract(const Duration(minutes: 30)),
      expiresAt: now.add(const Duration(hours: 23, minutes: 30)),
      likes: 5,
    ),
    Story(
      id: faker.guid.guid(),
      userId: users[9].id, // Isabella Rossi
      caption: 'Art gallery visit.',
      mediaUrl:
          'https://getwallpapers.com/wallpaper/full/5/5/6/826467-1920-by-1080-hd-wallpapers-1920x1080-for-ipad.jpg',
      mediaName: 'Gallery Day',
      type: 'image',
      storyUrl: 'https://example.com/stories/story10',
      createdAt: now.subtract(const Duration(minutes: 15)),
      expiresAt: now.add(const Duration(hours: 23, minutes: 45)),
      likes: 0,
    ),
  ];
}
