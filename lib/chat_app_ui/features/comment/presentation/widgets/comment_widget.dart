import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/comment/comment.dart';
import 'package:chat_app/chat_app_ui/utils/helpers.dart';

class CommentWidget extends StatelessWidget {
  final String storyId;
  final List<CommentEntity> comments;
  final Function(CommentEntity) onAddComment;

  const CommentWidget({
    super.key,
    required this.storyId,
    required this.comments,
    required this.onAddComment,
  });

  String? _getCurrentUserId(BuildContext context) {
    return Helpers.getCurrentUserId(context);
  }

  @override
  Widget build(BuildContext context) {
    final commentRepository = CommentRepositoryImpl(
      remoteDataSource: CommentRemoteDataSource(),
    );

    return BlocProvider(
      create:
          (context) => CommentBloc(
            getCommentsUseCase: GetCommentsUseCase(
              repository: commentRepository,
            ),
            createCommentUseCase: CreateCommentUseCase(
              repository: commentRepository,
            ),
            likeCommentUseCase: LikeCommentUseCase(
              repository: commentRepository,
            ),
            unlikeCommentUseCase: UnlikeCommentUseCase(
              repository: commentRepository,
            ),
            deleteCommentUseCase: DeleteCommentUseCase(
              repository: commentRepository,
            ),
          ),
      child: BlocConsumer<CommentBloc, CommentState>(
        listener: (context, state) {
          if (state is CommentFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is CommentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _CommentItem(comment: comment);
                  },
                ),
              ),
              _CommentInput(
                onSendComment: (content) {
                  final currentUserId = _getCurrentUserId(context);
                  if (currentUserId != null) {
                    final comment = CommentEntity(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: currentUserId,
                      storyId: storyId,
                      content: content,
                      likes: 0,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    onAddComment(comment);

                    // Send to backend
                    context.read<CommentBloc>().add(
                      CreateCommentEvent(storyId: storyId, content: content),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please login to add comments'),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommentEntity comment;

  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            comment.user?.profilePic != null
                ? NetworkImage(comment.user!.profilePic!)
                : null,
        child:
            comment.user?.profilePic == null
                ? Text(
                  comment.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                )
                : null,
      ),
      title: Text(comment.user?.username ?? 'Unknown User'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.content ?? ''),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.read<CommentBloc>().add(
                    LikeCommentEvent(commentId: comment.id),
                  );
                },
                child: Text('Like (${comment.likes})'),
              ),
              TextButton(
                onPressed: () {
                  context.read<CommentBloc>().add(
                    DeleteCommentEvent(commentId: comment.id),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatefulWidget {
  final Function(String) onSendComment;

  const _CommentInput({required this.onSendComment});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                widget.onSendComment(_controller.text);
                _controller.clear();
              }
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
