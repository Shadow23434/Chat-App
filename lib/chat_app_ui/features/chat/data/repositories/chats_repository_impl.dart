import 'package:chat_app/chat_app_ui/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/chat/data/models/chat_model.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/repositories/chat_repository.dart';

class ChatsRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatModel>> fetchChats() async {
    return await remoteDataSource.fetchChats();
  }
}
