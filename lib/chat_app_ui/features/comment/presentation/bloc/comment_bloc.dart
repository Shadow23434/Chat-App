import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/comment/domain/usecases/usecases.dart';
import 'package:chat_app/chat_app_ui/features/comment/presentation/bloc/comment_event.dart';
import 'package:chat_app/chat_app_ui/features/comment/presentation/bloc/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetCommentsUseCase getCommentsUseCase;
  final CreateCommentUseCase createCommentUseCase;
  final LikeCommentUseCase likeCommentUseCase;
  final UnlikeCommentUseCase unlikeCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;

  CommentBloc({
    required this.getCommentsUseCase,
    required this.createCommentUseCase,
    required this.likeCommentUseCase,
    required this.unlikeCommentUseCase,
    required this.deleteCommentUseCase,
  }) : super(CommentInitial()) {
    on<GetCommentsEvent>(_onGetComments);
    on<CreateCommentEvent>(_onCreateComment);
    on<LikeCommentEvent>(_onLikeComment);
    on<UnlikeCommentEvent>(_onUnlikeComment);
    on<DeleteCommentEvent>(_onDeleteComment);
  }

  Future<void> _onGetComments(
    GetCommentsEvent event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    try {
      final comments = await getCommentsUseCase(event.storyId);
      emit(CommentsLoaded(comments: comments));
    } catch (e) {
      emit(CommentFailure(error: e.toString()));
    }
  }

  Future<void> _onCreateComment(
    CreateCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    try {
      final comment = await createCommentUseCase(
        storyId: event.storyId,
        parentCommentId: event.parentCommentId,
        content: event.content,
        mediaUrl: event.mediaUrl,
      );
      emit(CommentCreated(comment: comment));
    } catch (e) {
      emit(CommentFailure(error: e.toString()));
    }
  }

  Future<void> _onLikeComment(
    LikeCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    try {
      final likes = await likeCommentUseCase(event.commentId);
      emit(CommentLiked(commentId: event.commentId, likes: likes));
    } catch (e) {
      emit(CommentFailure(error: e.toString()));
    }
  }

  Future<void> _onUnlikeComment(
    UnlikeCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    try {
      final likes = await unlikeCommentUseCase(event.commentId);
      emit(CommentUnliked(commentId: event.commentId, likes: likes));
    } catch (e) {
      emit(CommentFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteComment(
    DeleteCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await deleteCommentUseCase(event.commentId);
      emit(CommentDeleted(commentId: event.commentId));
    } catch (e) {
      emit(CommentFailure(error: e.toString()));
    }
  }
}
