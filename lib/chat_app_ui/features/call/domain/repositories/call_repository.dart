import 'package:chat_app/chat_app_ui/core/error/failures.dart';
import 'package:chat_app/chat_app_ui/features/call/data/models/call_model.dart';
import 'package:dartz/dartz.dart';

abstract class CallRepository {
  Future<Either<Failure, List<CallModel>>> getCalls();
}
