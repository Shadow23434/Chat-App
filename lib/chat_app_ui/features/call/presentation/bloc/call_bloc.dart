import 'package:chat_app/chat_app_ui/core/usecases/usecase.dart';
import 'package:chat_app/chat_app_ui/features/call/data/models/call_model.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/usecases/get_calls.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object> get props => [];
}

class GetCallsEvent extends CallEvent {}

// States
abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object> get props => [];
}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallLoaded extends CallState {
  final List<CallModel> calls;

  const CallLoaded(this.calls);

  @override
  List<Object> get props => [calls];
}

class CallError extends CallState {
  final String message;

  const CallError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class CallBloc extends Bloc<CallEvent, CallState> {
  final GetCalls getCalls;

  CallBloc({required this.getCalls}) : super(CallInitial()) {
    on<GetCallsEvent>(_onGetCalls);
  }

  Future<void> _onGetCalls(GetCallsEvent event, Emitter<CallState> emit) async {
    emit(CallLoading());
    final result = await getCalls(NoParams());
    result.fold(
      (failure) => emit(CallError('Failed to load calls')),
      (calls) => emit(CallLoaded(calls)),
    );
  }
}
