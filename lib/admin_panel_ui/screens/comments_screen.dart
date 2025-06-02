import 'package:flutter/material.dart';
import 'package:chat_app/admin_panel_ui/services/index.dart';
import 'package:chat_app/core/models/index.dart';
import 'package:chat_app/theme.dart';
import 'package:intl/intl.dart';

// Define a wrapper class for hierarchical comments
class CommentNode {
  final CommentModel comment;
  List<CommentNode> replies;

  CommentNode({required this.comment, List<CommentNode>? replies})
    : replies = replies ?? [];
}

class CommentScreen extends StatefulWidget {
  final String storyId;
  final String storyCaption;

  const CommentScreen({
    super.key,
    required this.storyId,
    required this.storyCaption,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final StoryService _storyService = StoryService();
  List<CommentNode> _commentHierarchy = []; // Use CommentNode for hierarchy
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  // Helper function to build hierarchical comments
  List<CommentNode> _buildCommentHierarchy(List<CommentModel> comments) {
    final Map<String, CommentNode> commentMap = {};
    final List<CommentNode> topLevelComments = [];

    // Create CommentNode for each comment and store in map
    for (var comment in comments) {
      commentMap[comment.id] = CommentNode(comment: comment, replies: []);
    }

    // Build the hierarchy
    for (var comment in comments) {
      final commentNode = commentMap[comment.id]!;
      if (comment.parentCommentId == null) {
        // This is a top-level comment
        topLevelComments.add(commentNode);
      } else {
        // This is a reply
        final parentNode = commentMap[comment.parentCommentId];
        if (parentNode != null) {
          // Add this reply to the parent's replies list
          parentNode.replies.add(commentNode);
        } else {
          // Parent not found, treat as top-level comment (or handle as error)
          topLevelComments.add(commentNode);
        }
      }
    }

    // Optional: Sort top-level comments and replies if needed
    topLevelComments.sort(
      (a, b) => a.comment.createdAt.compareTo(b.comment.createdAt),
    );
    for (var node in commentMap.values) {
      node.replies.sort(
        (a, b) => a.comment.createdAt.compareTo(b.comment.createdAt),
      );
    }

    return topLevelComments;
  }

  Future<void> _loadComments() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      final comments = await _storyService.getComments(widget.storyId);
      final hierarchicalComments = _buildCommentHierarchy(comments);
      setState(() {
        _commentHierarchy = hierarchicalComments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load comments: \$e';
        _isLoading = false;
      });
    }
  }

  // Widget to display a single comment and its replies
  Widget _buildCommentItem(CommentNode commentNode, {double indent = 0.0}) {
    final comment = commentNode.comment;
    return Padding(
      padding: EdgeInsets.only(left: indent), // Apply indentation for replies
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            key: ValueKey(comment.id),
            leading: CircleAvatar(
              backgroundImage:
                  comment.userId?.profilePic != null
                      ? NetworkImage(
                        comment.userId!.profilePic,
                      ) // Use NetworkImage if profilePic exists
                      : null,
              backgroundColor: AppColors.secondary,
              child:
                  comment.userId?.profilePic == null
                      ? Icon(Icons.person, color: Colors.white)
                      : null,
            ),
            title: Text(comment.userId?.username ?? 'Unknown User'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.content),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      DateFormat('MMM dd, HH:mm').format(comment.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textFaded,
                      ),
                    ),
                    SizedBox(width: 12), // Add spacing between date and likes
                    Icon(
                      Icons.favorite,
                      color: AppColors.accent,
                      size: 14,
                    ), // Heart icon
                    SizedBox(width: 4), // Spacing between icon and count
                    Text(
                      comment.likes.toString(), // Display likes count
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textFaded,
                      ),
                    ),
                  ],
                ),
                // You can add Reply button here later
                // Row(...),
              ],
            ),
          ),
          // Recursively build replies
          if (commentNode.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
              ), // Additional indent for replies
              child: ListView.builder(
                key: ValueKey('replies_${comment.id}'),
                shrinkWrap: true,
                physics:
                    NeverScrollableScrollPhysics(), // Disable scrolling within the comment item
                itemCount: commentNode.replies.length,
                itemBuilder: (context, index) {
                  final reply = commentNode.replies[index];
                  return _buildCommentItem(
                    reply,
                    indent: indent + 16.0,
                  ); // Increase indent for nested replies
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comments for: ${widget.storyCaption}',
          style: TextStyle(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.cardView,
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
              : _commentHierarchy.isEmpty
              ? Center(child: Text('No comments yet.'))
              : ListView.builder(
                itemCount: _commentHierarchy.length,
                itemBuilder: (context, index) {
                  final commentNode = _commentHierarchy[index];
                  return _buildCommentItem(commentNode);
                },
              ),
    );
  }
}
