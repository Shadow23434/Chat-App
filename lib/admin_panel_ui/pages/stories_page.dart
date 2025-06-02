import 'package:chat_app/admin_panel_ui/screens/comments_screen.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/theme.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/core/models/index.dart';
import 'package:chat_app/admin_panel_ui/widgets/widgets.dart';
import 'package:chat_app/admin_panel_ui/services/index.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final StoryService _storyService = StoryService();
  bool _isFocused = false;
  bool _sortAscending = true;
  List<StoryModel> _stories = [];
  List<StoryModel> _filteredStories = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _errorMessage = '';

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  int _totalPages = 1;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final result = await _storyService.getStories(
        page: _currentPage,
        limit: _itemsPerPage,
        sort: _sortAscending ? 'asc' : 'desc',
        search: _searchController.text.toLowerCase(),
        status: _selectedFilter,
      );

      setState(() {
        _stories = result['stories'];
        _filteredStories = List.from(_stories);
        _totalItems = result['pagination']['total'];
        _totalPages = result['pagination']['pages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _changePage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    setState(() {
      _currentPage = page;
      _isLoading = true;
    });
    await _loadData();
  }

  void _changeFilter(String filter) async {
    setState(() {
      _selectedFilter = filter.toLowerCase();
      _currentPage = 1;
      _isLoading = true;
    });
    await _loadData();
  }

  void _toggleSort() async {
    setState(() {
      _sortAscending = !_sortAscending;
      _currentPage = 1;
      _isLoading = true;
    });
    await _loadData();
  }

  Future<void> _deleteStory(String id) async {
    try {
      await _storyService.deleteStory(id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Success',
            'Story deleted successfully',
            Icons.check_circle_outline,
            Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete story: $e')));
      }
    }
  }

  void _viewStoryDetails(StoryModel story) async {
    try {
      final storyDetails = story;

      if (!mounted) return;

      // Show the AlertDialog with story details and a button to view comments
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Story Details'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: ImageService.optimizedNetworkImage(
                            url: storyDetails.backgroundUrl,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      _detailItem('ID', storyDetails.id),
                      _detailItem('Caption', storyDetails.caption),
                      _detailItem('Media Name', storyDetails.mediaName ?? ''),
                      _detailItem('Type', storyDetails.type),
                      _detailItem(
                        'User Email',
                        storyDetails.user?.email ?? 'Unknown User',
                      ),
                      _detailItem(
                        'Created',
                        DateFormat(
                          'yyyy-MM-dd HH:mm',
                        ).format(storyDetails.createdAt),
                      ),
                      _detailItem(
                        'Expires',
                        DateFormat(
                          'yyyy-MM-dd HH:mm',
                        ).format(storyDetails.expiresAt),
                      ),
                      _detailItem('Likes', storyDetails.likeCount.toString()),
                      _detailItem(
                        'Comments',
                        storyDetails.commentCount.toString(),
                      ),
                      _detailItem('Media URL', storyDetails.mediaUrl ?? ''),
                      _detailItem(
                        'Background URL',
                        storyDetails.backgroundUrl ?? '',
                      ),
                      _detailItem(
                        'Status',
                        storyDetails.isExpired ? 'Expired' : 'Active',
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to CommentsScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CommentScreen(
                              storyId: storyDetails.id,
                              storyCaption: storyDetails.caption,
                            ),
                      ),
                    );
                  },
                  child: Text('View Comments'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog before deleting
                    _deleteStory(storyDetails.id);
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Error',
            'Failed to load story details: $e',
            Icons.info_outline_rounded,
            AppColors.accent,
          ),
        );
      }
    }
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

  Widget _buildStoryCard(StoryModel story) {
    final isExpired = story.isExpired;

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
                  if (story.commentCount > 0)
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
                              '${story.commentCount}',
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
                    story.mediaName ?? '',
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
                    story.user?.email ?? 'Unknown User',
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
                            story.likeCount.toString(),
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
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    textAlign: TextAlign.start,
                    onFieldSubmitted: (_) => _loadData(),
                    decoration: InputDecoration(
                      hintText: 'Search by caption or user email',
                      hintStyle: TextStyle(color: AppColors.textFaded),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconBorder(
                          icon: Icons.search_rounded,
                          color: AppColors.secondary,
                          size: 20,
                          onTap: () => _loadData(),
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
              : _errorMessage.isNotEmpty
              ? Center(
                child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _filterButton('All', _selectedFilter == 'all'),
                        SizedBox(width: 8),
                        _filterButton('Active', _selectedFilter == 'active'),
                        SizedBox(width: 8),
                        _filterButton('Expired', _selectedFilter == 'expired'),
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
                                    itemCount: _filteredStories.length,
                                    itemBuilder: (context, index) {
                                      final story = _filteredStories[index];
                                      return _buildStoryCard(story);
                                    },
                                  ),
                                ),
                                if (_totalPages > 1)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: PaginationControls(
                                      currentPage: _currentPage,
                                      totalPages: _totalPages,
                                      onPageChanged: _changePage,
                                      itemsPerPage: _itemsPerPage,
                                      totalItems: _totalItems,
                                    ),
                                  ),
                              ],
                            ),
                  ),
                ],
              ),
    );
  }
}
