import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/admin_panel_ui/models/users.dart';
import 'package:chat_app/chat_app_ui/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ProfileScreen extends StatelessWidget {
  static Route route(User data) =>
      MaterialPageRoute(builder: (context) => ProfileScreen(user: data));

  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Avatar.large(url: user.profileUrl),
              Padding(padding: const EdgeInsets.all(8), child: Text(user.name)),
              _ButtonRow(isContacted: true, user: user),
              SizedBox(height: 32),
              _InfoContainer(user: user),
              SizedBox(height: 32),
              _MediaView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ButtonRow extends StatefulWidget {
  const _ButtonRow({required this.isContacted, required this.user});
  final bool isContacted;
  final User user;

  @override
  State<_ButtonRow> createState() => __ButtonRowState();
}

class __ButtonRowState extends State<_ButtonRow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconBackGround(
            icon: CupertinoIcons.chat_bubble,
            onTap: () {},
            // () => Navigator.of(context).push(ChatScreen.route(widget.user)),
            circularBorder: true,
          ),
          IconBackGround(
            icon: CupertinoIcons.video_camera,
            onTap: () {},
            size: 24,
            circularBorder: true,
          ),
          IconBackGround(
            icon: CupertinoIcons.phone,
            onTap: () {},
            circularBorder: true,
          ),
          IconBackGround(
            icon:
                widget.isContacted
                    ? Icons.person_remove_outlined
                    : Icons.person_add_alt_1_outlined,
            circularBorder: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _InfoContainer extends StatelessWidget {
  const _InfoContainer({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.circularIcon,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name', style: TextStyle(color: AppColors.textFaded)),
              Text(user.name),
            ],
          ),
          SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gender', style: TextStyle(color: AppColors.textFaded)),
              Text(user.gender, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email', style: TextStyle(color: AppColors.textFaded)),
              Text(user.email),
            ],
          ),
          SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone Number',
                style: TextStyle(color: AppColors.textFaded),
              ),
              Text(user.phoneNumber),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaView extends StatelessWidget {
  const _MediaView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stories Shared',
              style: TextStyle(color: AppColors.textFaded),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 0),
              child: Text(
                'View All',
                style: TextStyle(color: AppColors.secondary, fontSize: 14),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _MediaList(),
      ],
    );
  }
}

class _MediaList extends StatefulWidget {
  const _MediaList();

  @override
  State<_MediaList> createState() => __MediaListState();
}

class __MediaListState extends State<_MediaList> {
  final List<Map<String, String>> mediaItems = [
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/200/300?random=1',
      'caption': 'Image 1',
    },
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/100/300?random=1',
      'caption': 'Image 2',
    },
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/300/300?random=1',
      'caption': 'Image 3',
    },
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/150/300?random=1',
      'caption': 'Image 3',
    },
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/250/300?random=1',
      'caption': 'Image 3',
    },
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/50/300?random=1',
      'caption': 'Image 3',
    },
    // {
    //   'type': 'video',
    //   'mediaUrl':
    //       'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    //   'caption': 'Video 1',
    // },
    // {
    //   'type': 'audio',
    //   'mediaUrl':
    //       'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    //   'caption': 'Audio 1',
    // },
  ];

  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, AudioPlayer> _audioPlayers = {};

  @override
  void initState() {
    super.initState();
    _initializeMediaControllers();
  }

  void _initializeMediaControllers() {
    for (int i = 0; i < mediaItems.length; i++) {
      if (mediaItems[i]['type'] == 'video') {
        _videoControllers[i] = VideoPlayerController.networkUrl(
            Uri.parse(mediaItems[i]['mediaUrl']!),
          )
          ..initialize().then((_) {
            setState(() {});
          });
      } else if (mediaItems[i]['type'] == 'audio') {
        _audioPlayers[i] = AudioPlayer();
      }
    }
  }

  @override
  void dispose() {
    _videoControllers.forEach((_, controller) => controller.dispose());
    _audioPlayers.forEach((_, player) => player.dispose());
    super.dispose();
  }

  Widget _buildMediaItem(int index) {
    final mediaType = mediaItems[index]['type'];

    switch (mediaType) {
      case 'image':
        return Container(
          width: 90,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: CachedNetworkImageProvider(mediaItems[index]['mediaUrl']!),
              fit: BoxFit.cover,
            ),
          ),
        );

      case 'video':
        if (!_videoControllers[index]!.value.isInitialized) {
          return Container(
            width: 90,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
            ),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
          );
        }
        return Column(
          children: [
            Container(
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VideoPlayer(_videoControllers[index]!),
              ),
            ),
          ],
        );

      case 'audio':
        return Column(
          children: [
            Container(
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              child: Center(child: Icon(Icons.audiotrack, size: 40)),
            ),
          ],
        );

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCount = mediaItems.length > 3 ? 2 : mediaItems.length;
    final hasMoreItems = mediaItems.length > 3;

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (hasMoreItems && index == displayCount) {
            return Container(
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  opacity: 0.3,
                  image: NetworkImage(mediaItems[index]['mediaUrl']!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  '+${mediaItems.length - 2}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          return InkWell(onTap: () {}, child: _buildMediaItem(index));
        },
        separatorBuilder: (context, index) => SizedBox(width: 12),
        itemCount: displayCount + (hasMoreItems ? 1 : 0),
      ),
    );
  }
}
