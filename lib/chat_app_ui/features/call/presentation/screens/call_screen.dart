import 'package:chat_app/chat_app_ui/features/call/presentation/bloc/call_bloc.dart';
import 'package:chat_app/chat_app_ui/features/call/presentation/widgets/call_list.dart';
import 'package:chat_app/chat_app_ui/features/call/data/datasources/call_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/call/data/repositories/call_repository_impl.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/usecases/get_calls.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/usecases/create_call_use_case.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/usecases/end_call_use_case.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/usecases/answer_call_use_case.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/usecases/decline_call_use_case.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder:
          (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create:
                    (_) => CallBloc(
                      getCallsUseCase: GetCallsUseCase(
                        repository: CallRepositoryImpl(
                          callRemoteDataSource: CallRemoteDataSource(),
                        ),
                      ),
                      createCallUseCase: CreateCallUseCase(
                        repository: CallRepositoryImpl(
                          callRemoteDataSource: CallRemoteDataSource(),
                        ),
                      ),
                      endCallUseCase: EndCallUseCase(
                        repository: CallRepositoryImpl(
                          callRemoteDataSource: CallRemoteDataSource(),
                        ),
                      ),
                      answerCallUseCase: AnswerCallUseCase(
                        repository: CallRepositoryImpl(
                          callRemoteDataSource: CallRemoteDataSource(),
                        ),
                      ),
                      declineCallUseCase: DeclineCallUseCase(
                        repository: CallRepositoryImpl(
                          callRemoteDataSource: CallRemoteDataSource(),
                        ),
                      ),
                    )..add(GetCallsEvent()),
              ),
            ],
            child: const CallScreen(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      context.read<CallBloc>();
      return Scaffold(
        appBar: AppBar(),
        body: RefreshIndicator(
          color: AppColors.secondary,
          onRefresh: () async {
            context.read<CallBloc>().add(GetCallsEvent());
          },
          child: const CallList(),
        ),
      );
    } catch (e) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (_) => CallBloc(
                  getCallsUseCase: GetCallsUseCase(
                    repository: CallRepositoryImpl(
                      callRemoteDataSource: CallRemoteDataSource(),
                    ),
                  ),
                  createCallUseCase: CreateCallUseCase(
                    repository: CallRepositoryImpl(
                      callRemoteDataSource: CallRemoteDataSource(),
                    ),
                  ),
                  endCallUseCase: EndCallUseCase(
                    repository: CallRepositoryImpl(
                      callRemoteDataSource: CallRemoteDataSource(),
                    ),
                  ),
                  answerCallUseCase: AnswerCallUseCase(
                    repository: CallRepositoryImpl(
                      callRemoteDataSource: CallRemoteDataSource(),
                    ),
                  ),
                  declineCallUseCase: DeclineCallUseCase(
                    repository: CallRepositoryImpl(
                      callRemoteDataSource: CallRemoteDataSource(),
                    ),
                  ),
                )..add(GetCallsEvent()),
          ),
        ],
        child: Scaffold(
          appBar: AppBar(),
          body: RefreshIndicator(
            color: AppColors.secondary,
            onRefresh: () async {
              context.read<CallBloc>().add(GetCallsEvent());
            },
            child: const CallList(),
          ),
        ),
      );
    }
  }
}
