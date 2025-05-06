import 'package:chat_app/chat_app_ui/features/chat/domain/usecases/fetch_chats_use_case.dart';
import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchChatsUseCase fetchChatsUseCase;

  ChatBloc(this.fetchChatsUseCase) : super(ChatInitial()) {
    on<FetchChats>(_onFetchChats);
  }

  Future<void> _onFetchChats(FetchChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chats = await fetchChatsUseCase();
      emit(ChatLoaded(chats));
    } catch (error) {
      emit(ChatError('Failed to load chats'));
    }
  }
}
