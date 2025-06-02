import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/usecases/get_chats_usecase.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatsUseCase getChatsUseCase;

  ChatBloc({required this.getChatsUseCase}) : super(ChatInitial()) {
    on<GetChatsEvent>(_onGetChats);
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
}
