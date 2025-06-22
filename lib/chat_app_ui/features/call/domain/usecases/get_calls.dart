import 'package:chat_app/chat_app_ui/core/error/failures.dart';
import 'package:chat_app/chat_app_ui/core/usecases/usecase.dart';
import 'package:chat_app/chat_app_ui/features/call/data/models/call_model.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/repositories/call_repository.dart';
import 'package:dartz/dartz.dart';

class GetCalls implements UseCase<List<CallModel>, NoParams> {
  final CallRepository repository;

  GetCalls(this.repository);

  @override
  Future<Either<Failure, List<CallModel>>> call(NoParams params) async {
    return await repository.getCalls();
  }
}
