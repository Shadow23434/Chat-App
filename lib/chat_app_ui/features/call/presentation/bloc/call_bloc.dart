import 'package:chat_app/chat_app_ui/features/call/domain/entities/call.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/usecases/get_calls.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/usecases/create_call_use_case.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/usecases/end_call_use_case.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/usecases/answer_call_use_case.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/usecases/decline_call_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object> get props => [];
}

class GetCallsEvent extends CallEvent {}

class CreateCallEvent extends CallEvent {
  final String participantId;
  final String callType;

  const CreateCallEvent({required this.participantId, required this.callType});

  @override
  List<Object> get props => [participantId, callType];
}

class EndCallEvent extends CallEvent {
  final String callId;
  final String status;

  const EndCallEvent({required this.callId, required this.status});

  @override
  List<Object> get props => [callId, status];
}

class AnswerCallEvent extends CallEvent {
  final String callId;

  const AnswerCallEvent({required this.callId});

  @override
  List<Object> get props => [callId];
}

class DeclineCallEvent extends CallEvent {
  final String callId;

  const DeclineCallEvent({required this.callId});

  @override
  List<Object> get props => [callId];
}

// States
abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object> get props => [];
}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallLoaded extends CallState {
  final List<CallEntity> calls;

  const CallLoaded(this.calls);

  @override
  List<Object> get props => [calls];
}

class CallCreated extends CallState {
  final CallEntity call;

  const CallCreated(this.call);

  @override
  List<Object> get props => [call];
}

class CallEnded extends CallState {
  final String message;

  const CallEnded(this.message);

  @override
  List<Object> get props => [message];
}

class CallAnswered extends CallState {
  final String message;

  const CallAnswered(this.message);

  @override
  List<Object> get props => [message];
}

class CallDeclined extends CallState {
  final String message;

  const CallDeclined(this.message);

  @override
  List<Object> get props => [message];
}

class CallError extends CallState {
  final String message;

  const CallError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class CallBloc extends Bloc<CallEvent, CallState> {
  final GetCallsUseCase getCallsUseCase;
  final CreateCallUseCase createCallUseCase;
  final EndCallUseCase endCallUseCase;
  final AnswerCallUseCase answerCallUseCase;
  final DeclineCallUseCase declineCallUseCase;

  CallBloc({
    required this.getCallsUseCase,
    required this.createCallUseCase,
    required this.endCallUseCase,
    required this.answerCallUseCase,
    required this.declineCallUseCase,
  }) : super(CallInitial()) {
    on<GetCallsEvent>(_onGetCalls);
    on<CreateCallEvent>(_onCreateCall);
    on<EndCallEvent>(_onEndCall);
    on<AnswerCallEvent>(_onAnswerCall);
    on<DeclineCallEvent>(_onDeclineCall);
  }

  Future<void> _onGetCalls(GetCallsEvent event, Emitter<CallState> emit) async {
    emit(CallLoading());
    try {
      final calls = await getCallsUseCase.call();
      emit(CallLoaded(calls));
    } catch (e) {
      emit(CallError('Failed to load calls: ${e.toString()}'));
    }
  }

  Future<void> _onCreateCall(
    CreateCallEvent event,
    Emitter<CallState> emit,
  ) async {
    emit(CallLoading());
    try {
      final call = await createCallUseCase.call(
        event.participantId,
        event.callType,
      );
      emit(CallCreated(call));
    } catch (e) {
      emit(CallError('Failed to create call: ${e.toString()}'));
    }
  }

  Future<void> _onEndCall(EndCallEvent event, Emitter<CallState> emit) async {
    emit(CallLoading());
    try {
      await endCallUseCase.call(event.callId, event.status);
      emit(CallEnded('Call ended successfully'));
    } catch (e) {
      emit(CallError('Failed to end call: ${e.toString()}'));
    }
  }

  Future<void> _onAnswerCall(
    AnswerCallEvent event,
    Emitter<CallState> emit,
  ) async {
    emit(CallLoading());
    try {
      await answerCallUseCase.call(event.callId);
      emit(CallAnswered('Call answered successfully'));
    } catch (e) {
      emit(CallError('Failed to answer call: ${e.toString()}'));
    }
  }

  Future<void> _onDeclineCall(
    DeclineCallEvent event,
    Emitter<CallState> emit,
  ) async {
    emit(CallLoading());
    try {
      await declineCallUseCase.call(event.callId);
      emit(CallDeclined('Call declined successfully'));
    } catch (e) {
      emit(CallError('Failed to decline call: ${e.toString()}'));
    }
  }
}
