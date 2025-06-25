import 'package:chat_app/chat_app_ui/features/call/data/datasources/call_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/entities/call.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/repositories/call_repository.dart';

class CallRepositoryImpl implements CallRepository {
  final CallRemoteDataSource callRemoteDataSource;

  CallRepositoryImpl({required this.callRemoteDataSource});

  @override
  Future<List<CallEntity>> getCalls() async {
    return await callRemoteDataSource.getCalls();
  }

  @override
  Future<CallEntity> createCall(String participantId, String callType) async {
    return await callRemoteDataSource.createCall(
      participantId: participantId,
      callType: callType,
    );
  }

  @override
  Future<void> endCall(String callId, String status) async {
    return await callRemoteDataSource.endCall(callId: callId, status: status);
  }

  @override
  Future<void> answerCall(String callId) async {
    return await callRemoteDataSource.answerCall(callId: callId);
  }

  @override
  Future<void> declineCall(String callId) async {
    return await callRemoteDataSource.declineCall(callId: callId);
  }
}
