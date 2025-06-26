import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/chat_app_ui/utils/helpers.dart';
import 'package:chat_app/chat_app_ui/features/comment/comment.dart';
import 'package:chat_app/chat_app_ui/features/story/story.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/screens/profile_screen.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class StoryScreen extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const StoryScreen());

  static Route routeWithStory(StoryEntity story) =>
      MaterialPageRoute(builder: (context) => StoryScreen(story: story));

  final StoryEntity? story;

  const StoryScreen({super.key, this.story});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late PageController _pageController;
  bool _isExpanded = false;
  late Map<String, List<CommentEntity>> _storyComments;
  int _currentIndex = 0;
  late CommentBloc _commentBloc;
  late StoryBloc _storyBloc;
  bool _storiesLoaded = false;
  List<StoryEntity> _currentStories = []; // Store current stories
  final Map<String, bool> _storyLikeStates =
      {}; // Track like states for each story
  final Map<String, bool> _processingLikeStates =
      {}; // Track if like/unlike is being processed

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeComments();
    _initializeCommentBloc();
    _initializeStoryBloc();

    // If a specific story is provided, we'll need to find its index after loading
    if (widget.story != null) {
      _storiesLoaded = false;
    }
  }

  void _initializeComments() {
    _storyComments = <String, List<CommentEntity>>{};
  }

  void _initializeCommentBloc() {
    final commentRepository = CommentRepositoryImpl(
      remoteDataSource: CommentRemoteDataSource(),
    );
    _commentBloc = CommentBloc(
      getCommentsUseCase: GetCommentsUseCase(repository: commentRepository),
      createCommentUseCase: CreateCommentUseCase(repository: commentRepository),
      likeCommentUseCase: LikeCommentUseCase(repository: commentRepository),
      unlikeCommentUseCase: UnlikeCommentUseCase(repository: commentRepository),
      deleteCommentUseCase: DeleteCommentUseCase(repository: commentRepository),
    );
  }

  void _initializeStoryBloc() {
    _storyBloc = StoryBloc(
      getStoriesUseCase: GetStoriesUseCase(
        StoryRepositoryImpl(remoteDataSource: StoryRemoteDataSource()),
      ),
      createStoryUseCase: CreateStoryUseCase(
        StoryRepositoryImpl(remoteDataSource: StoryRemoteDataSource()),
      ),
      likeStoryUseCase: LikeStoryUseCase(
        StoryRepositoryImpl(remoteDataSource: StoryRemoteDataSource()),
      ),
      unlikeStoryUseCase: UnlikeStoryUseCase(
        StoryRepositoryImpl(remoteDataSource: StoryRemoteDataSource()),
      ),
      deleteStoryUseCase: DeleteStoryUseCase(
        StoryRepositoryImpl(remoteDataSource: StoryRemoteDataSource()),
      ),
      getOwnStoriesUseCase: GetOwnStoriesUseCase(
        repository: StoryRepositoryImpl(
          remoteDataSource: StoryRemoteDataSource(),
        ),
      ),
    );

    // If a specific story is provided, load own stories instead of all stories
    if (widget.story != null) {
      _storyBloc.add(GetOwnStories());
    } else {
      // Load stories immediately
      _storyBloc.add(GetStories());
    }
  }

  void _navigateToSpecificStory() {
    if (widget.story != null && !_storiesLoaded) {
      final storyState = _storyBloc.state;
      List<StoryEntity> stories = [];

      if (storyState is StoriesLoaded) {
        stories = storyState.stories;
      } else if (storyState is OwnStoriesLoaded) {
        stories = storyState.stories;
      }

      if (stories.isNotEmpty) {
        final targetStoryId = widget.story!.id;
        final storyIndex = stories.indexWhere(
          (story) => story.id == targetStoryId,
        );

        if (storyIndex != -1) {
          setState(() {
            _currentIndex = storyIndex;
            _storiesLoaded = true;
          });

          // Animate to the specific story
          _pageController.animateToPage(
            storyIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          // Story not found in the list, show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Story not found or has expired')),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Remove the dependency on parent StoryBloc
  }

  void _addComment(String storyId, CommentEntity comment) {
    print(
      '_addComment called with storyId: $storyId, comment: ${comment.content}',
    );

    setState(() {
      _storyComments[storyId] = [...(_storyComments[storyId] ?? []), comment];
    });

    // Send comment to backend using comment bloc
    print(
      'Sending CreateCommentEvent with storyId: $storyId, content: ${comment.content}',
    );
    _commentBloc.add(
      CreateCommentEvent(storyId: storyId, content: comment.content ?? ''),
    );
  }

  void _toggleCommentField() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  StoryEntity? _getCurrentStory() {
    final storyState = _storyBloc.state;
    List<StoryEntity> stories = [];

    if (storyState is StoriesLoaded) {
      stories = storyState.stories;
    } else if (storyState is OwnStoriesLoaded) {
      stories = storyState.stories;
    }

    if (stories.isNotEmpty && _currentIndex < stories.length) {
      return stories[_currentIndex];
    }
    return null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentBloc.close();
    _storyBloc.close();
    super.dispose();
  }

  void _showReplyDialog(CommentEntity comment) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reply to ${comment.user?.username ?? 'User'}'),
            content: TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: 'Write your reply...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (replyController.text.isNotEmpty) {
                    final currentUserId = Helpers.getCurrentUserId(context);
                    if (currentUserId != null) {
                      final reply = CommentEntity(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: currentUserId,
                        storyId: widget.story!.id,
                        parentCommentId: comment.id,
                        content: replyController.text,
                        likes: 0,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        user: null,
                      );

                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('Reply'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _storyBloc),
        BlocProvider.value(value: _commentBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<CommentBloc, CommentState>(
            bloc: _commentBloc,
            listener: (context, state) {
              if (state is CommentFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  customSnackBar(
                    'Error',
                    state.error,
                    Icons.error_outline_rounded,
                    Colors.red,
                  ),
                );
              } else if (state is CommentCreated) {
                // Comment created successfully
                // ScaffoldMessenger.of(context).showSnackBar(
                //   customSnackBar(
                //     'Success',
                //     'Comment added successfully!',
                //     Icons.check_circle_outline_rounded,
                //     Colors.green,
                //   ),
                // );
              } else if (state is CommentsLoaded) {
                // Update comments for current story
                setState(() {
                  final currentStory = _getCurrentStory();
                  if (currentStory != null) {
                    _storyComments[currentStory.id] = state.comments;
                  }
                });
              }
            },
          ),
        ],
        child: Scaffold(
          body: BlocConsumer<StoryBloc, StoryState>(
            listener: (context, state) {
              if (state is StoryError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  customSnackBar(
                    'Error',
                    state.message,
                    Icons.error_outline_rounded,
                    Colors.red,
                  ),
                );
                // Reset processing flags for all stories on error
                setState(() {
                  _processingLikeStates.clear();
                });
              } else if (state is StoryCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  customSnackBar(
                    'Success',
                    'Story created successfully!',
                    Icons.check_circle_outline_rounded,
                    Colors.green,
                  ),
                );
              } else if (state is StoryDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  customSnackBar(
                    'Success',
                    'Story deleted successfully!',
                    Icons.check_circle_outline_rounded,
                    Colors.green,
                  ),
                );
              } else if (state is StoryLiked) {
                print('StoryLiked event received for story: ${state.storyId}');
                // Update the like count in stored stories
                final storyIndex = _currentStories.indexWhere(
                  (s) => s.id == state.storyId,
                );
                if (storyIndex != -1) {
                  final oldStory = _currentStories[storyIndex];
                  setState(() {
                    _currentStories[storyIndex] = StoryEntity(
                      id: oldStory.id,
                      userId: oldStory.userId,
                      caption: oldStory.caption,
                      type: oldStory.type,
                      backgroundUrl: oldStory.backgroundUrl,
                      mediaName: oldStory.mediaName,
                      mediaUrl: oldStory.mediaUrl,
                      createdAt: oldStory.createdAt,
                      expiresAt: oldStory.expiresAt,
                      likes: state.likes,
                      user: oldStory.user,
                    );
                    // Update like state to true
                    _storyLikeStates[state.storyId] = true;
                    // Reset processing flag
                    _processingLikeStates[state.storyId] = false;
                    print(
                      'Story ${state.storyId} is now LIKED. Total likes: ${state.likes}. Like state updated to: ${_storyLikeStates[state.storyId]}',
                    );
                  });
                }
              } else if (state is StoryUnliked) {
                print(
                  'StoryUnliked event received for story: ${state.storyId}',
                );
                // Update the like count in stored stories
                final storyIndex = _currentStories.indexWhere(
                  (s) => s.id == state.storyId,
                );
                if (storyIndex != -1) {
                  final oldStory = _currentStories[storyIndex];
                  setState(() {
                    _currentStories[storyIndex] = StoryEntity(
                      id: oldStory.id,
                      userId: oldStory.userId,
                      caption: oldStory.caption,
                      type: oldStory.type,
                      backgroundUrl: oldStory.backgroundUrl,
                      mediaName: oldStory.mediaName,
                      mediaUrl: oldStory.mediaUrl,
                      createdAt: oldStory.createdAt,
                      expiresAt: oldStory.expiresAt,
                      likes: state.likes,
                      user: oldStory.user,
                    );
                    // Update like state to false
                    _storyLikeStates[state.storyId] = false;
                    // Reset processing flag
                    _processingLikeStates[state.storyId] = false;
                    print(
                      'Story ${state.storyId} is now UNLIKED. Total likes: ${state.likes}. Like state updated to: ${_storyLikeStates[state.storyId]}',
                    );
                  });
                }
              } else if (state is StoriesLoaded) {
                // Navigate to specific story if provided
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _navigateToSpecificStory();
                });
              } else if (state is OwnStoriesLoaded) {
                // Navigate to specific story if provided (when viewing own stories)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _navigateToSpecificStory();
                });
              }
            },
            builder: (context, state) {
              if (state is StoryLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (state is StoriesLoaded || state is OwnStoriesLoaded) {
                List<StoryEntity> stories = [];
                if (state is StoriesLoaded) {
                  stories = state.stories;
                } else if (state is OwnStoriesLoaded) {
                  stories = state.stories;
                }

                // Store the current stories
                _currentStories = stories;

                // Initialize like states for new stories (default to false)
                for (final story in stories) {
                  if (!_storyLikeStates.containsKey(story.id)) {
                    _storyLikeStates[story.id] = false;
                    print(
                      'Initialized like state for story ${story.id}: false',
                    );
                  } else {
                    print(
                      'Existing like state for story ${story.id}: ${_storyLikeStates[story.id]}',
                    );
                  }
                  // Initialize processing flag
                  _processingLikeStates[story.id] = false;
                }

                if (stories.isEmpty) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Stories'),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).push(CreateStoryScreen.route());
                          },
                        ),
                      ],
                    ),
                    body: const Center(child: Text('No stories available')),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          if (widget.story != null) {
                            _storyBloc.add(GetOwnStories());
                          } else {
                            _storyBloc.add(GetStories());
                          }
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                        },
                        child: PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          itemCount: stories.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final story = stories[index];

                            // Load comments for this story if not loaded yet
                            if (_storyComments[story.id] == null) {
                              _commentBloc.add(
                                GetCommentsEvent(storyId: story.id),
                              );
                            }

                            return _StoryContent(
                              key: ValueKey(
                                '${story.id}_${_storyLikeStates[story.id]}',
                              ),
                              story: story,
                              isExpanded: _isExpanded,
                              onToggleComment: _toggleCommentField,
                              comments: _storyComments[story.id] ?? [],
                              onAddComment:
                                  (comment) => _addComment(story.id, comment),
                              onLike: () {
                                final storyId = story.id;
                                if (_processingLikeStates[storyId] == true) {
                                  print(
                                    'Like already processing for story: $storyId',
                                  );
                                  return;
                                }
                                setState(() {
                                  _processingLikeStates[storyId] = true;
                                });
                                print('Calling LikeStory for story: $storyId');
                                _storyBloc.add(LikeStory(storyId: storyId));
                              },
                              onUnlike: () {
                                final storyId = story.id;
                                if (_processingLikeStates[storyId] == true) {
                                  print(
                                    'Unlike already processing for story: $storyId',
                                  );
                                  return;
                                }
                                setState(() {
                                  _processingLikeStates[storyId] = true;
                                });
                                print(
                                  'Calling UnlikeStory for story: $storyId',
                                );
                                _storyBloc.add(UnlikeStory(storyId: storyId));
                              },
                              onDelete: () {
                                _showDeleteDialog(story);
                              },
                              isLiked: _storyLikeStates[story.id] ?? false,
                            );
                          },
                        ),
                      ),
                    ),
                    _ActionBar(
                      onSendComment: (comment) {
                        final currentStory = stories[_currentIndex];
                        _addComment(currentStory.id, comment);
                      },
                      currentStoryId:
                          stories.isNotEmpty && _currentIndex < stories.length
                              ? stories[_currentIndex].id
                              : '',
                    ),
                  ],
                );
              } else if (state is StoryLiked || state is StoryUnliked) {
                // Use stored stories for like/unlike states
                if (_currentStories.isEmpty) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Stories')),
                    body: const Center(child: Text('No stories available')),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          if (widget.story != null) {
                            _storyBloc.add(GetOwnStories());
                          } else {
                            _storyBloc.add(GetStories());
                          }
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                        },
                        child: PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          itemCount: _currentStories.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final story = _currentStories[index];

                            // Load comments for this story if not loaded yet
                            if (_storyComments[story.id] == null) {
                              _commentBloc.add(
                                GetCommentsEvent(storyId: story.id),
                              );
                            }

                            return _StoryContent(
                              key: ValueKey(
                                '${story.id}_${_storyLikeStates[story.id]}',
                              ),
                              story: story,
                              isExpanded: _isExpanded,
                              onToggleComment: _toggleCommentField,
                              comments: _storyComments[story.id] ?? [],
                              onAddComment:
                                  (comment) => _addComment(story.id, comment),
                              onLike: () {
                                final storyId = story.id;
                                if (_processingLikeStates[storyId] == true) {
                                  print(
                                    'Like already processing for story: $storyId',
                                  );
                                  return;
                                }
                                setState(() {
                                  _processingLikeStates[storyId] = true;
                                });
                                print('Calling LikeStory for story: $storyId');
                                _storyBloc.add(LikeStory(storyId: storyId));
                              },
                              onUnlike: () {
                                final storyId = story.id;
                                if (_processingLikeStates[storyId] == true) {
                                  print(
                                    'Unlike already processing for story: $storyId',
                                  );
                                  return;
                                }
                                setState(() {
                                  _processingLikeStates[storyId] = true;
                                });
                                print(
                                  'Calling UnlikeStory for story: $storyId',
                                );
                                _storyBloc.add(UnlikeStory(storyId: storyId));
                              },
                              onDelete: () {
                                _showDeleteDialog(story);
                              },
                              isLiked: _storyLikeStates[story.id] ?? false,
                            );
                          },
                        ),
                      ),
                    ),
                    _ActionBar(
                      onSendComment: (comment) {
                        final currentStory = _currentStories[_currentIndex];
                        _addComment(currentStory.id, comment);
                      },
                      currentStoryId:
                          _currentStories.isNotEmpty &&
                                  _currentIndex < _currentStories.length
                              ? _currentStories[_currentIndex].id
                              : '',
                    ),
                  ],
                );
              } else if (state is StoryError) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Stories')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}'),
                        ElevatedButton(
                          onPressed: () {
                            if (widget.story != null) {
                              _storyBloc.add(GetOwnStories());
                            } else {
                              _storyBloc.add(GetStories());
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const Scaffold(
                body: Center(child: Text('No stories available')),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(StoryEntity story) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Story'),
            content: const Text('Are you sure you want to delete this story?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _storyBloc.add(DeleteStory(storyId: story.id));
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

class _StoryContent extends StatefulWidget {
  const _StoryContent({
    super.key,
    required this.story,
    required this.comments,
    required this.isExpanded,
    required this.onToggleComment,
    required this.onAddComment,
    required this.onLike,
    required this.onUnlike,
    required this.onDelete,
    required this.isLiked,
  });

  final StoryEntity story;
  final List<CommentEntity> comments;
  final bool isExpanded;
  final VoidCallback onToggleComment;
  final Function(CommentEntity) onAddComment;
  final VoidCallback onLike;
  final VoidCallback onUnlike;
  final VoidCallback onDelete;
  final bool isLiked;

  @override
  State<_StoryContent> createState() => _StoryContentState();
}

class _StoryContentState extends State<_StoryContent>
    with TickerProviderStateMixin {
  late AnimationController _shareController;
  late AnimationController _likeController;
  late AnimationController _commentController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _commentScaleAnimation;
  late Animation<double> _shareScaleAnimation;
  double _brightness = 1.0;
  late Map<String, bool> _commentLikes;
  late Map<String, int> _commentLikesCount;
  late Map<String, List<CommentEntity>> _commentReplies;

  // Reply functionality
  String? _replyingToCommentId;
  final TextEditingController _replyController = TextEditingController();

  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isAudioPlaying = false;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
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
        _commentLikes[comment.id] = false;
        _commentLikesCount[comment.id] = comment.likes;
        _commentReplies[comment.id] = [];
      } else {
        final parentId = comment.parentCommentId!;
        _commentReplies[parentId] = [
          ...(_commentReplies[parentId] ?? []),
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

    if (widget.story.type == 'image' &&
        widget.story.mediaUrl != null &&
        widget.story.mediaUrl!.isNotEmpty) {
      _calculateImageBrightness();
    } else if (widget.story.type == 'video' && widget.story.mediaUrl != null && widget.story.mediaUrl!.isNotEmpty) {
      _videoController = VideoPlayerController.network(widget.story.mediaUrl!)
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController?.play();
        });
    } else if (widget.story.type == 'audio' && widget.story.mediaUrl != null && widget.story.mediaUrl!.isNotEmpty) {
      _audioPlayer = AudioPlayer();
      _audioPlayer!.play(UrlSource(widget.story.mediaUrl!));
      _isAudioPlaying = true;
    }
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
    // TODO: Update backend
  }

  Future<void> _calculateImageBrightness() async {
    try {
      final response = await http.get(Uri.parse(widget.story.mediaUrl!));
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
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Widget _buildComment(CommentEntity comment, {int depth = 0}) {
    // Use user info from comment if available, otherwise fallback to Helpers
    final commentUser = comment.user;
    final fallbackUser = Helpers.getUserById(comment.userId);

    // Get current user for comparison
    final currentUser = Helpers.getCurrentUser(context);
    final currentUserId = Helpers.getCurrentUserId(context);

    // Use comment.user if available, otherwise use fallback user
    // If this is the current user's comment, use current user info
    String displayName;
    String? profilePic;
    String userId;

    if (comment.userId == currentUserId && currentUser != null) {
      // This is the current user's comment
      displayName = currentUser.username;
      profilePic = currentUser.profilePic;
      userId = currentUser.id;
    } else {
      // Use comment.user if available, otherwise use fallback user
      displayName =
          commentUser?.username ?? fallbackUser?.username ?? 'Unknown User';
      profilePic = commentUser?.profilePic ?? fallbackUser?.profilePic;
      userId = commentUser?.id ?? fallbackUser?.id ?? comment.userId;
    }

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
                url: profilePic,
                onTap:
                    () => Navigator.of(
                      context,
                    ).push(ProfileScreen.routeWithBloc(userId)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(comment.content ?? ''),
                    const SizedBox(height: 4),
                    Row(
                      children: [
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
                        Text(
                          '$commentLikesCount',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textFaded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // GestureDetector(
                        //   onTap: () {
                        //     // TODO: Implement reply functionality
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       const SnackBar(
                        //         content: Text('Reply feature coming soon!'),
                        //       ),
                        //     );
                        //   },
                        //   child: const Text(
                        //     'Reply',
                        //     style: TextStyle(
                        //       fontSize: 11,
                        //       color: AppColors.textFaded,
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(width: 12),
                        Text(
                          Helpers.formatTimeAgo(comment.createdAt),
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
    Widget backgroundWidget;
    if (widget.story.type == 'video' && _videoController != null && _isVideoInitialized) {
      backgroundWidget = Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    } else {
      backgroundWidget = Container(
        decoration: BoxDecoration(image: _getBackgroundDecoration()),
        child: _getBackgroundDecoration() == null
            ? Container(
                color: Colors.grey[300],
                child: const Center(child: Text('No Image Available')),
              )
            : null,
      );
    }

    // Use user info from story if available, otherwise fallback to Helpers
    final storyUser = widget.story.user;
    final fallbackUser =
        widget.story.userId.isNotEmpty
            ? Helpers.getUserById(widget.story.userId)
            : null;

    // Use story.user if available, otherwise use fallback user
    final displayName =
        storyUser?.username ?? fallbackUser?.username ?? 'Unknown User';
    final profilePic = storyUser?.profilePic ?? fallbackUser?.profilePic;
    final userId = storyUser?.id ?? fallbackUser?.id ?? widget.story.userId;

    return Stack(
      children: [
        // Background or video
        backgroundWidget,
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
                      url: profilePic,
                      onTap:
                          userId != null
                              ? () => Navigator.of(
                                context,
                              ).push(ProfileScreen.routeWithBloc(userId))
                              : null,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                widget.story.mediaName ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
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
                  // Add story button
                  IconNoBorder(
                    icon: Icons.add,
                    color: Colors.white,
                    size: 24,
                    onTap: () {
                      Navigator.of(context).push(CreateStoryScreen.route());
                    },
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.story.caption?.isNotEmpty == true)
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            widget.story.caption!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
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
                                      widget.isLiked
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_outlined,
                                  color:
                                      widget.isLiked
                                          ? AppColors.secondary
                                          : Colors.white,
                                  size: 26,
                                  onTap: () {
                                    print(
                                      'Like button tapped. Current isLiked: ${widget.isLiked}',
                                    );
                                    // Prevent multiple rapid taps
                                    if (_likeController.isAnimating) return;

                                    _likeController.forward(from: 0.0);

                                    try {
                                      if (widget.isLiked) {
                                        print(
                                          'Calling onUnlike() for story: ${widget.story.id}',
                                        );
                                        widget.onUnlike();
                                      } else {
                                        print(
                                          'Calling onLike() for story: ${widget.story.id}',
                                        );
                                        widget.onLike();
                                      }
                                    } catch (e) {
                                      print('Error in like/unlike: $e');
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error: ${e.toString()}',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              BlocBuilder<StoryBloc, StoryState>(
                                builder: (context, state) {
                                  if (state is StoryLiked &&
                                      state.storyId == widget.story.id) {
                                    return Text(
                                      state.likes.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  } else if (state is StoryUnliked &&
                                      state.storyId == widget.story.id) {
                                    return Text(
                                      state.likes.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }
                                  return Text(
                                    widget.story.likes.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                },
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
                              const SizedBox(height: 4),
                              Text(
                                widget.comments.length.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
              decoration: const BoxDecoration(
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
                          children: widget.comments
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

  DecorationImage? _getBackgroundDecoration() {
    // Ưu tiên mediaUrl nếu có và không rỗng
    if (widget.story.type == 'image' &&
        widget.story.mediaUrl != null &&
        widget.story.mediaUrl!.isNotEmpty) {
      return DecorationImage(
        image: CachedNetworkImageProvider(
          widget.story.mediaUrl!,
          errorListener: (exception) {
            print('Image loading error: $exception');
          },
        ),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.matrix(_brightnessMatrix(_brightness)),
      );
    }
    // Nếu không có mediaUrl hoặc mediaUrl rỗng, sử dụng backgroundUrl
    else if (widget.story.backgroundUrl != null &&
        widget.story.backgroundUrl!.isNotEmpty) {
      return DecorationImage(
        image: CachedNetworkImageProvider(
          widget.story.backgroundUrl!,
          errorListener: (exception) {
            print('Background image loading error: $exception');
          },
        ),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  /// Xác định URL hiển thị chính cho story
  /// Ưu tiên mediaUrl nếu có và không rỗng, nếu không thì dùng backgroundUrl
  String? _getPrimaryDisplayUrl() {
    if (widget.story.mediaUrl != null && widget.story.mediaUrl!.isNotEmpty) {
      return widget.story.mediaUrl;
    } else if (widget.story.backgroundUrl != null &&
        widget.story.backgroundUrl!.isNotEmpty) {
      return widget.story.backgroundUrl;
    }
    return null;
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

class _ActionBar extends StatefulWidget {
  final Function(CommentEntity) onSendComment;
  final String currentStoryId;

  const _ActionBar({required this.onSendComment, required this.currentStoryId});

  @override
  State<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<_ActionBar> {
  final TextEditingController commentController = TextEditingController();

  String? _getCurrentUserId(BuildContext context) {
    return Helpers.getCurrentUserId(context);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

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
                    controller: commentController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Write your comment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
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
                  onPressed: () {
                    print('GlowingActionButton pressed');
                    final currentUserId = _getCurrentUserId(context);
                    final currentUser = Helpers.getCurrentUser(context);
                    print('Current user ID: $currentUserId');
                    print('Comment text: ${commentController.text}');
                    print('Current story ID: ${widget.currentStoryId}');

                    if (currentUserId != null &&
                        commentController.text.isNotEmpty) {
                      final comment = CommentEntity(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: currentUserId,
                        storyId: widget.currentStoryId,
                        content: commentController.text,
                        likes: 0,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        user: null, // Will be handled in _buildComment
                      );
                      print(
                        'Creating comment: ${comment.content} for story: ${comment.storyId}',
                      );
                      print('Comment user ID: $currentUserId');
                      widget.onSendComment(comment);
                      commentController.clear();
                    } else if (currentUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please login to add comments'),
                        ),
                      );
                    } else if (commentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a comment')),
                      );
                    }
                  },
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
