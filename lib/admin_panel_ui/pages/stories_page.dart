import 'dart:convert';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_app/theme.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/admin_panel_ui/models/models.dart';
import 'package:chat_app/admin_panel_ui/widget/widgets.dart';
import 'package:chat_app/admin_panel_ui/services/image_service.dart';

// Define a custom User class specifically for this page to handle the JSON correctly
class UserData {
  final String id;
  final String username;
  final String email;
  final String profilePic;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePic,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id']['\$oid'],
      username: json['username'],
      email: json['email'],
      profilePic: json['profilePic'] ?? '',
    );
  }
}

// Define a custom Comment class to avoid model conflicts
class CommentData {
  final String id;
  final String storyId;
  final String? parentCommentId;
  final String content;
  final DateTime createdAt;
  final int likes;
  final String userId;
  String? username;
  String? userEmail;
  String? userProfilePic;

  CommentData({
    required this.id,
    required this.storyId,
    this.parentCommentId,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.userId,
    this.username,
    this.userEmail,
    this.userProfilePic,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) {
    return CommentData(
      id: json['_id']?['\$oid'] ?? '',
      storyId: json['storyId']?['\$oid'] ?? '',
      parentCommentId:
          json['parentCommentId'] != null
              ? json['parentCommentId']['\$oid'] ?? ''
              : null,
      content: json['content'] ?? '',
      createdAt:
          json['createdAt'] != null && json['createdAt']['\$date'] != null
              ? DateTime.parse(json['createdAt']['\$date'])
              : DateTime.now(),
      likes: json['likes'] ?? 0,
      userId: json['userId']?['\$oid'] ?? '',
    );
  }
}

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _sortAscending = true;
  List<Story> _stories = [];
  List<Story> _filteredStories = [];
  List<UserData> _users = [];
  List<CommentData> _comments = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  Map<String, UserData> _userMap = {};

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  List<Story> _paginatedStories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _searchController.addListener(() {
      _filterStories();
    });
  }

  Future<void> _loadData() async {
    try {
      // Load users first
      final String usersResponse = await rootBundle.loadString(
        'assets/demo_data/users.json',
      );
      final List<dynamic> usersData = json.decode(usersResponse);

      _users = usersData.map((json) => UserData.fromJson(json)).toList();
      // Create a map for easy lookup
      _userMap = {for (var user in _users) user.id: user};

      // Then load stories
      final String storiesResponse = await rootBundle.loadString(
        'assets/demo_data/stories.json',
      );
      final List<dynamic> storiesData = json.decode(storiesResponse);

      _stories = storiesData.map((json) => Story.fromJson(json)).toList();

      // Load comments
      final String commentsResponse = await rootBundle.loadString(
        'assets/demo_data/comments.json',
      );
      final List<dynamic> commentsData = json.decode(commentsResponse);

      _comments =
          commentsData.map((json) => CommentData.fromJson(json)).toList();

      // Associate user data with comments
      for (var comment in _comments) {
        final userData = _userMap[comment.userId];
        if (userData != null) {
          comment.username = userData.username;
          comment.userEmail = userData.email;
          comment.userProfilePic = userData.profilePic;
        }
      }

      setState(() {
        _filteredStories = List.from(_stories);
        _isLoading = false;
        // Explicitly update paginated stories after loading data
        _updatePaginatedStories();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading data: $e');
    }
  }

  List<CommentData> _getCommentsForStory(String storyId) {
    return _comments.where((comment) => comment.storyId == storyId).toList();
  }

  String _getUserEmail(String userId) {
    final user = _userMap[userId];
    return user?.email ?? 'Unknown User';
  }

  String? _getUserProfilePic(String userId) {
    final user = _userMap[userId];
    return user?.profilePic;
  }

  void _filterStories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStories =
            _stories.where((story) {
              if (_selectedFilter == 'All') return true;
              if (_selectedFilter == 'Active')
                return story.expiresAt.isAfter(DateTime.now());
              if (_selectedFilter == 'Expired')
                return story.expiresAt.isBefore(DateTime.now());
              return true;
            }).toList();
      } else {
        _filteredStories =
            _stories.where((story) {
              // Get the user for this story
              final user = _userMap[story.userId];

              // Search by caption or user email
              bool matchesQuery = story.caption.toLowerCase().contains(query);
              if (user != null) {
                matchesQuery =
                    matchesQuery || user.email.toLowerCase().contains(query);
              }

              bool matchesFilter = true;
              if (_selectedFilter == 'Active')
                matchesFilter = story.expiresAt.isAfter(DateTime.now());
              if (_selectedFilter == 'Expired')
                matchesFilter = story.expiresAt.isBefore(DateTime.now());

              return matchesQuery && matchesFilter;
            }).toList();
      }
      _sortStories();
      _updatePaginatedStories();
    });
  }

  void _sortStories() {
    setState(() {
      _filteredStories.sort((a, b) {
        return _sortAscending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt);
      });
      _updatePaginatedStories();
    });
  }

  void _updatePaginatedStories() {
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex =
        startIndex + _itemsPerPage > _filteredStories.length
            ? _filteredStories.length
            : startIndex + _itemsPerPage;

    if (startIndex >= _filteredStories.length && _currentPage > 1) {
      // If current page has no items (e.g., after filtering), go to previous page
      _currentPage = 1;
      _updatePaginatedStories();
      return;
    }

    _paginatedStories = _filteredStories.sublist(startIndex, endIndex);
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
      _updatePaginatedStories();
    });
  }

  int get _totalPages {
    return (_filteredStories.length / _itemsPerPage).ceil();
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterStories();
    });
  }

  void _toggleSort() {
    setState(() {
      _sortAscending = !_sortAscending;
      _sortStories();
    });
  }

  void _deleteStory(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Story'),
            content: Text('Are you sure you want to delete this story?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _stories.removeWhere((story) => story.id == id);
                    _filteredStories.removeWhere((story) => story.id == id);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Story deleted successfully')),
                  );
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _viewStoryComments(Story story) {
    final comments = _getCommentsForStory(story.id);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Story Comments'),
            content: Container(
              width: 500,
              height: 400, // Fixed height to avoid overflow
              child:
                  comments.isEmpty
                      ? Center(child: Text('No comments for this story'))
                      : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return _buildCommentItem(comment);
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildCommentItem(CommentData comment) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: AppColors.cardView,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ImageService.avatarImage(
                  url: comment.userProfilePic,
                  radius: 16,
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.username ?? 'Unknown User',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      comment.userEmail ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textFaded,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(comment.createdAt),
                  style: TextStyle(fontSize: 12, color: AppColors.textFaded),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(comment.content),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.favorite, color: AppColors.accent, size: 14),
                SizedBox(width: 4),
                Text('${comment.likes}', style: TextStyle(fontSize: 12)),
              ],
            ),
            comment.parentCommentId != null
                ? Container(
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.reply, size: 12, color: AppColors.textFaded),
                      SizedBox(width: 4),
                      Text(
                        'Reply to another comment',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textFaded,
                        ),
                      ),
                    ],
                  ),
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _viewStoryDetails(Story story) {
    final userEmail = _getUserEmail(story.userId);
    final commentsCount = _getCommentsForStory(story.id).length;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Story Details'),
            content: Container(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 200,
                        width: 200,
                        child: ImageService.optimizedNetworkImage(
                          url: story.backgroundUrl,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _detailItem('ID', story.id),
                    _detailItem('Caption', story.caption),
                    _detailItem('Media Name', story.mediaName),
                    _detailItem('Type', story.type),
                    _detailItem('User Email', userEmail),
                    _detailItem(
                      'Created',
                      DateFormat('yyyy-MM-dd HH:mm').format(story.createdAt),
                    ),
                    _detailItem(
                      'Expires',
                      DateFormat('yyyy-MM-dd HH:mm').format(story.expiresAt),
                    ),
                    _detailItem('Likes', story.likes.toString()),
                    _detailItem('Comments', commentsCount.toString()),
                    _detailItem('Media URL', story.mediaUrl),
                    _detailItem('Background URL', story.backgroundUrl),
                    _detailItem(
                      'Status',
                      story.expiresAt.isAfter(DateTime.now())
                          ? 'Active'
                          : 'Expired',
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _viewStoryComments(story);
                },
                child: Text('View Comments'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteStory(story.id);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: const Text(
              'Stories',
              style: TextStyle(color: AppColors.textLight, fontSize: 24),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search bar
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      hintText: 'Search by caption or user email',
                      hintStyle: TextStyle(color: AppColors.textFaded),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconBorder(
                          icon: Icons.search_rounded,
                          color: AppColors.secondary,
                          size: 20,
                          onTap: () => _filterStories(),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.cardView,
                    ),
                  ),
                ),
                SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              )
              : Column(
                children: [
                  // Filter and sort
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _filterButton('All', _selectedFilter == 'All'),
                        SizedBox(width: 8),
                        _filterButton('Active', _selectedFilter == 'Active'),
                        SizedBox(width: 8),
                        _filterButton('Expired', _selectedFilter == 'Expired'),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            _sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: AppColors.secondary,
                          ),
                          onPressed: _toggleSort,
                          tooltip:
                              _sortAscending ? 'Oldest first' : 'Newest first',
                        ),
                      ],
                    ),
                  ),
                  // Stories list
                  Expanded(
                    child:
                        _filteredStories.isEmpty
                            ? Center(child: Text('No stories found'))
                            : Column(
                              children: [
                                Expanded(
                                  child: GridView.builder(
                                    padding: EdgeInsets.all(16),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          childAspectRatio: 0.8,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                    itemCount: _paginatedStories.length,
                                    itemBuilder: (context, index) {
                                      final story = _paginatedStories[index];
                                      return _buildStoryCard(story);
                                    },
                                  ),
                                ),
                                // Pagination controls
                                if (_filteredStories.length > _itemsPerPage)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: PaginationControls(
                                      currentPage: _currentPage,
                                      totalPages: _totalPages,
                                      onPageChanged: _changePage,
                                      itemsPerPage: _itemsPerPage,
                                      totalItems: _filteredStories.length,
                                    ),
                                  ),
                              ],
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _filterButton(String label, bool isSelected) {
    return ElevatedButton(
      onPressed: () => _changeFilter(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.secondary : AppColors.cardView,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildStoryCard(Story story) {
    final isExpired = story.expiresAt.isBefore(DateTime.now());
    final userEmail = _getUserEmail(story.userId);
    final commentsCount = _getCommentsForStory(story.id).length;

    return GestureDetector(
      onTap: () => _viewStoryDetails(story),
      child: Card(
        color: AppColors.cardView,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  ImageService.optimizedNetworkImage(
                    url: story.backgroundUrl,
                    height: 150,
                    width: double.infinity,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    fit: BoxFit.cover,
                    placeholder:
                        isExpired
                            ? Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                            )
                            : null,
                  ),
                  if (isExpired)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          color: Colors.grey.withOpacity(0.7),
                        ),
                      ),
                    ),
                  if (isExpired)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Expired',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  if (commentsCount > 0)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.comment, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              '$commentsCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.mediaName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    story.caption,
                    style: TextStyle(fontSize: 12, color: AppColors.textFaded),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(fontSize: 10, color: AppColors.textFaded),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: AppColors.accent,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            story.likes.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        DateFormat('MMM dd').format(story.createdAt),
                        style: TextStyle(
                          fontSize: 12,
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
      ),
    );
  }
}
