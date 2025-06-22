import 'package:chat_app/chat_app_ui/core/error/exceptions.dart';
import 'package:chat_app/chat_app_ui/core/error/failures.dart';
import 'package:chat_app/chat_app_ui/features/call/data/datasources/call_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/call/data/models/call_model.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/repositories/call_repository.dart';
import 'package:dartz/dartz.dart';

class CallRepositoryImpl implements CallRepository {
  final CallRemoteDataSource remoteDataSource;

  CallRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CallModel>>> getCalls() async {
    try {
      final calls = await remoteDataSource.getCalls();
      return Right(calls);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
