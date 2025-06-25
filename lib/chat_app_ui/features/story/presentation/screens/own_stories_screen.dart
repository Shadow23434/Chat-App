import 'package:chat_app/chat_app_ui/features/story/story.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OwnStoriesScreen extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const OwnStoriesScreen());

  const OwnStoriesScreen({super.key});

  @override
  State<OwnStoriesScreen> createState() => _OwnStoriesScreenState();
}

class _OwnStoriesScreenState extends State<OwnStoriesScreen>
    with WidgetsBindingObserver {
  late StoryBloc _storyBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _storyBloc = StoryBloc(
      getStoriesUseCase: GetStoriesUseCase(
        StoryRepositoryImpl(remoteDataSource: StoryRemoteDataSource()),
      ),
      getOwnStoriesUseCase: GetOwnStoriesUseCase(
        repository: StoryRepositoryImpl(
          remoteDataSource: StoryRemoteDataSource(),
        ),
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
    );

    // Load own stories
    _storyBloc.add(GetOwnStories());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _storyBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh stories when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _storyBloc.add(GetOwnStories());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _storyBloc,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 54,
          leading: Align(
            alignment: Alignment.centerRight,
            child: IconNoBorder(
              icon: Icons.arrow_back_ios_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          title: const Text('My Stories'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.of(
                  context,
                ).push(CreateStoryScreen.route());
                // Refresh stories when returning from create story screen
                if (result == true) {
                  _storyBloc.add(GetOwnStories());
                }
              },
            ),
          ],
        ),
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
            } else if (state is StoryDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                customSnackBar(
                  'Success',
                  'Story deleted successfully!',
                  Icons.check_circle_outline_rounded,
                  Colors.green,
                ),
              );
              // Reload stories after deletion
              _storyBloc.add(GetOwnStories());
            }
          },
          builder: (context, state) {
            if (state is StoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              );
            } else if (state is OwnStoriesLoaded) {
              if (state.stories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No stories yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first story to share with friends',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(
                            context,
                          ).push(CreateStoryScreen.route());
                          // Refresh stories when returning from create story screen
                          if (result == true) {
                            _storyBloc.add(GetOwnStories());
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create Story'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.secondary,
                onRefresh: () async {
                  _storyBloc.add(GetOwnStories());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.stories.length,
                  itemBuilder: (context, index) {
                    final story = state.stories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              story.mediaUrl != null &&
                                      story.mediaUrl!.isNotEmpty
                                  ? NetworkImage(story.mediaUrl!)
                                  : story.backgroundUrl != null &&
                                      story.backgroundUrl!.isNotEmpty
                                  ? NetworkImage(story.backgroundUrl!)
                                  : null,
                          child:
                              (story.mediaUrl == null ||
                                          story.mediaUrl!.isEmpty) &&
                                      (story.backgroundUrl == null ||
                                          story.backgroundUrl!.isEmpty)
                                  ? const Icon(Icons.image)
                                  : null,
                        ),
                        title: Text(
                          story.caption ?? 'No caption',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: ${story.type}'),
                            Text('Likes: ${story.likes}'),
                            Text('Created: ${_formatDate(story.createdAt)}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteDialog(story);
                            } else if (value == 'view') {
                              Navigator.of(
                                context,
                              ).push(StoryScreen.routeWithStory(story));
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility),
                                      SizedBox(width: 8),
                                      Text('View'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is StoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _storyBloc.add(GetOwnStories());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('No stories available'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(
              context,
            ).push(CreateStoryScreen.route());
            // Refresh stories when returning from create story screen
            if (result == true) {
              _storyBloc.add(GetOwnStories());
            }
          },
          backgroundColor: AppColors.secondary,
          child: const Icon(Icons.add, color: Colors.white),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
