import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/chat_app_ui/features/auth/data/models/user_model.dart';
import 'package:chat_app/chat_app_ui/utils/helpers.dart';
import 'package:chat_app/chat_app_ui/models/models.dart';
import 'package:chat_app/chat_app_ui/screens/profiles/profile_screen.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class StoryScreen extends StatefulWidget {
  static Route route(List<Story> stories, int initialIndex) =>
      MaterialPageRoute(
        builder:
            (context) =>
                StoryScreen(stories: stories, initialIndex: initialIndex),
      );

  const StoryScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  final List<Story> stories;
  final int initialIndex;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late PageController _pageController;
  bool _isExpanded = false;
  late Map<String, List<Comment>> _storyComments;
  late Map<String, int> _storyLikes;
  late Map<String, bool> _userLikes;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _preloadImages();
    _initializeComments();
    _initializeLikes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _preloadImages() async {
    for (var story in widget.stories) {
      if (story.type == 'image' && story.mediaUrl.isNotEmpty) {
        await precacheImage(NetworkImage(story.mediaUrl), context);
      }
    }
  }

  List<UserModel> users = Helpers.users;
  void _initializeComments() {
    _storyComments = [] as Map<String, List<Comment>>;
  }

  Future<void> _initializeLikes() async {
    _userLikes = {};
    _storyLikes = {};
    const currentUserId = 'current_user_id';

    for (var story in widget.stories) {
      _storyLikes[story.id] = story.likes;
      _userLikes[story.id] = false;
      setState(() {});

      final userHasLiked = await checkIfUserLikedStory(story.id, currentUserId);
      _userLikes[story.id] = userHasLiked;
    }
  }

  Future<bool> checkIfUserLikedStory(String storyId, String userId) async {
    // Check backend
    return false;
  }

  void _addComment(String storyId, Comment comment) {
    setState(() {
      _storyComments[storyId] = [..._storyComments[storyId]!, comment];
    });
    // Update backend
  }

  void _toggleCommentField() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                return _StoryContent(
                  story: story,
                  likes: _storyLikes[story.id] ?? 0,
                  isLiked: _userLikes[story.id] ?? false,
                  isExpanded: _isExpanded,
                  onToggleComment: _toggleCommentField,
                  comments: _storyComments[widget.stories[index].id] ?? [],
                  onAddComment:
                      (comment) =>
                          _addComment(widget.stories[index].id, comment),
                );
              },
            ),
          ),
          _ActionBar(),
        ],
      ),
    );
  }
}

class _StoryContent extends StatefulWidget {
  _StoryContent({
    required this.story,
    required this.comments,
    required this.isExpanded,
    required this.onToggleComment,
    required this.onAddComment,
    required this.likes,
    required this.isLiked,
  });

  final Story story;
  final List<Comment> comments;
  final bool isExpanded;
  final VoidCallback onToggleComment;
  final Function(Comment) onAddComment;
  int likes;
  final bool isLiked;

  @override
  State<_StoryContent> createState() => _StoryContentState();
}

class _StoryContentState extends State<_StoryContent>
    with TickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _shareController;
  late AnimationController _likeController;
  late AnimationController _commentController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _commentScaleAnimation;
  late Animation<double> _shareScaleAnimation;
  double _brightness = 1.0;
  late Map<String, bool> _commentLikes;
  late Map<String, int> _commentLikesCount;
  late Map<String, List<Comment>> _commentReplies;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.easeInOut),
    );

    _commentLikes = {};
    _commentLikesCount = {};
    _commentReplies = {};
    for (var comment in widget.comments) {
      if (comment.parentCommentId == null) {
        // comment parent
        _commentLikes[comment.id] = false; // check backend
        _commentLikesCount[comment.id] = comment.likes;
        _commentReplies[comment.id] = [];
      } else {
        // comment children
        _commentReplies[comment.parentCommentId!] = [
          ...(_commentReplies[comment.parentCommentId!] ?? []),
          comment,
        ];
        _commentLikes[comment.id] = false;
        _commentLikesCount[comment.id] = 0;
      }
    }

    _commentController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _commentScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _commentController, curve: Curves.easeInOut),
    );

    _shareController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shareScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _shareController, curve: Curves.easeInOut),
    );

    if (widget.story.type == 'image' && widget.story.mediaUrl.isNotEmpty) {
      _calculateImageBrightness();
    }
  }

  Future<void> onToggleLike() async {
    setState(() {
      if (_isLiked) {
        widget.likes += 1;
      } else if (widget.likes > 0) {
        widget.likes -= 1;
      }
    });
  }

  Future<void> _toggleCommentLike(String commentId) async {
    setState(() {
      final wasLiked = _commentLikes[commentId] ?? false;
      _commentLikes[commentId] = !wasLiked;
      _commentLikesCount[commentId] =
          (wasLiked
              ? (_commentLikesCount[commentId] ?? 0) - 1
              : (_commentLikesCount[commentId] ?? 0) + 1);
      if (_commentLikesCount[commentId]! < 0) {
        _commentLikesCount[commentId] = 0;
      }
    });
    // Update backend
  }

  Future<void> _calculateImageBrightness() async {
    try {
      final response = await http.get(Uri.parse(widget.story.mediaUrl));
      if (response.statusCode == 200) {
        final image = img.decodeImage(response.bodyBytes);
        if (image != null) {
          double totalLuminance = 0;
          int pixelCount = 0;
          for (int y = 0; y < image.height; y += 10) {
            for (int x = 0; x < image.width; x += 10) {
              final pixel = image.getPixel(x, y);
              final r = pixel.r.toDouble();
              final g = pixel.g.toDouble();
              final b = pixel.b.toDouble();
              final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
              totalLuminance += luminance;
              pixelCount++;
            }
          }
          final avgLuminance = totalLuminance / pixelCount;

          setState(() {
            _brightness = _adjustBrightness(avgLuminance);
          });
        }
      }
    } catch (e) {
      // print('Error calculating brightness: $e');
      setState(() {
        _brightness = 0.7;
      });
    }
  }

  double _adjustBrightness(double luminance) {
    if (luminance > 0.7) {
      return 0.5;
    } else if (luminance < 0.3) {
      return 0.9;
    } else {
      return 0.7;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _shareController.dispose();
    _likeController.dispose();
    super.dispose();
  }

  Widget _buildComment(Comment comment, {int depth = 0}) {
    final commentUser = Helpers.getUserById(comment.userId);
    final isCommentLiked = _commentLikes[comment.id] ?? false;
    final commentLikesCount = _commentLikesCount[comment.id] ?? 0;
    final replies = _commentReplies[comment.id] ?? [];

    return Padding(
      padding: EdgeInsets.only(left: 16.0 * depth * 2.6, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar.small(
                url: commentUser!.profilePic,
                onTap:
                    () => Navigator.of(
                      context,
                    ).push(ProfileScreen.route(commentUser)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commentUser.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(comment.content),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Like button
                        IconNoBorder(
                          icon:
                              isCommentLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_alt_outlined,
                          onTap: () => _toggleCommentLike(comment.id),
                          size: 16,
                          color:
                              isCommentLiked
                                  ? AppColors.secondary
                                  : AppColors.textFaded,
                        ),
                        const SizedBox(width: 4),
                        // Like count
                        Text(
                          '$commentLikesCount',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textFaded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Reply',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textFaded,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Timestamp
                        Text(
                          '${DateTime.now().difference(comment.createdAt).inMinutes}m',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textFaded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // comment children
          if (replies.isNotEmpty)
            Column(
              children:
                  replies
                      .map((reply) => _buildComment(reply, depth: depth + 1))
                      .toList(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Helpers.getUserById(widget.story.userId);
    return Stack(
      children: [
        // Background Image
        Container(
          decoration: BoxDecoration(
            image:
                widget.story.type == 'image' && widget.story.mediaUrl.isNotEmpty
                    ? DecorationImage(
                      image: CachedNetworkImageProvider(
                        widget.story.mediaUrl,
                        errorListener: (exception) {
                          if (mounted) {
                            setState(() => _brightness = 0.7);
                          }
                        },
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.matrix(
                        _brightnessMatrix(_brightness),
                      ),
                    )
                    : null,
          ),
          child:
              widget.story.type == 'image' && widget.story.mediaUrl.isNotEmpty
                  ? null
                  : Container(
                    color: Colors.grey[300],
                    child: const Center(child: Text('No Image Available')),
                  ),
        ),
        // Loading Placeholder
        if (widget.story.type == 'image' && widget.story.mediaUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: widget.story.mediaUrl,
            placeholder:
                (context, url) => Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                ),
            errorWidget:
                (context, url, error) => customSnackBar(
                  'Image Loading Error!',
                  'Oops, something went wrong.',
                  Icons.info_outline,
                  AppColors.accent,
                ),
            imageBuilder: (context, imageProvider) => Container(),
          ),
        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
          child: Column(
            children: [
              // Avatar
              Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: IconNoBorder(
                      icon: Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Avatar.small(
                      url: user?.profilePic,
                      onTap:
                          () => Navigator.of(
                            context,
                          ).push(ProfileScreen.route(user!)),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user!.username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                widget.story.mediaName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Caption
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Text(widget.story.caption),
                  ),
                ),
              ),
              // Button Column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 36, right: 8),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: 180,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              ScaleTransition(
                                scale: _likeScaleAnimation,
                                child: IconNoBorder(
                                  icon:
                                      _isLiked
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_outlined,
                                  color:
                                      _isLiked
                                          ? AppColors.secondary
                                          : Colors.white,
                                  size: 26,
                                  onTap: () {
                                    setState(() {
                                      _isLiked = !_isLiked;
                                    });
                                    _likeController.forward(from: 0.0);
                                    onToggleLike();
                                    // Update backend
                                  },
                                ),
                              ),
                              Text(
                                widget.likes.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              ScaleTransition(
                                scale: _commentScaleAnimation,
                                child: IconNoBorder(
                                  icon: CupertinoIcons.chat_bubble,
                                  color: Colors.white,
                                  size: 26,
                                  onTap: () {
                                    widget.onToggleComment();
                                    _commentController.forward(from: 0.0);
                                  },
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.comments.length.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          ScaleTransition(
                            scale: _shareScaleAnimation,
                            child: IconNoBorder(
                              icon: CupertinoIcons.share_up,
                              color: Colors.white,
                              size: 26,
                              onTap: () {
                                _shareController.forward(from: 0.0);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Comment container
        if (widget.isExpanded)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              decoration: BoxDecoration(
                color: Color(0xFF1B1E1F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(width: 1, color: Colors.grey),
                ),
              ),
              child: Stack(
                children: [
                  widget.comments.isEmpty
                      ? const Center(
                        child: Text(
                          'No comments yet',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                      : ListView(
                        padding: const EdgeInsets.all(8),
                        children:
                            widget.comments
                                .where((c) => c.parentCommentId == null)
                                .map((comment) => _buildComment(comment))
                                .toList(),
                      ),
                  // Close comment container
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconNoBorder(
                      icon: Icons.close_rounded,
                      onTap: () => widget.onToggleComment(),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<double> _brightnessMatrix(double value) {
    return [
      value,
      0,
      0,
      0,
      0,
      0,
      value,
      0,
      0,
      0,
      0,
      0,
      value,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20, left: 24),
                  child: TextField(
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Write your comment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                child: GlowingActionButton(
                  color: AppColors.secondary,
                  icon: Icons.send_rounded,
                  onPressed: () {},
                  size: 38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
