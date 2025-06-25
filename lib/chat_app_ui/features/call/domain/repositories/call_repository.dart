import 'package:chat_app/chat_app_ui/features/call/domain/entities/call.dart';

abstract class CallRepository {
  Future<List<CallEntity>> getCalls();
  Future<CallEntity> createCall(String participantId, String callType);
  Future<void> endCall(String callId, String status);
  Future<void> answerCall(String callId);
  Future<void> declineCall(String callId);
}
