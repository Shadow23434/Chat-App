import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_state.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/usecases/get_chats_usecase.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatsUseCase getChatsUseCase;

  ChatBloc({required this.getChatsUseCase}) : super(ChatInitial()) {
    on<GetChatsEvent>(_onGetChats);
    on<UpdateChatEvent>(_onUpdateChat);
    on<RefreshChatsEvent>(_onRefreshChats);
  }

  Future<void> _onGetChats(GetChatsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chats = await getChatsUseCase(event.userId);
      emit(ChatLoaded(chats));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onUpdateChat(UpdateChatEvent event, Emitter<ChatState> emit) {
    print('ChatBloc: _onUpdateChat called with chat: ${event.updatedChat.id}');
    print('ChatBloc: Current state: ${state.runtimeType}');

    if (state is ChatLoaded) {
      final currentChats = List<ChatEntity>.from((state as ChatLoaded).chats);
      print('ChatBloc: Current chats count: ${currentChats.length}');
      print(
        'ChatBloc: Current chat IDs: ${currentChats.map((c) => c.id).toList()}',
      );

      // Find and update the existing chat
      final index = currentChats.indexWhere(
        (chat) => chat.id == event.updatedChat.id,
      );

      print('ChatBloc: Found chat at index: $index');

      if (index != -1) {
        // Update existing chat
        print('ChatBloc: Updating existing chat at index $index');
        currentChats[index] = event.updatedChat;
      } else {
        // Add new chat if it doesn't exist
        print('ChatBloc: Adding new chat');
        currentChats.add(event.updatedChat);
      }

      // Sort chats by last message time (most recent first)
      currentChats.sort((a, b) {
        final aTime = a.lastMessageAt ?? DateTime(1900);
        final bTime = b.lastMessageAt ?? DateTime(1900);
        return bTime.compareTo(aTime);
      });

      print('ChatBloc: Emitting ChatLoaded with ${currentChats.length} chats');
      emit(ChatLoaded(currentChats));
    } else {
      print('ChatBloc: Cannot update chat - state is not ChatLoaded');
    }
  }

  Future<void> _onRefreshChats(
    RefreshChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      try {
        final chats = await getChatsUseCase(event.userId);
        emit(ChatLoaded(chats));
      } catch (e) {
        // Keep current state if refresh fails
        print('Failed to refresh chats: $e');
      }
    }
  }
}
