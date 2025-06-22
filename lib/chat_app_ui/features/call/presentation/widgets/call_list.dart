import 'package:chat_app/chat_app_ui/features/call/presentation/bloc/call_bloc.dart';
import 'package:chat_app/chat_app_ui/features/call/presentation/widgets/call_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallList extends StatelessWidget {
  const CallList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallBloc, CallState>(
      builder: (context, state) {
        if (state is CallLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CallLoaded) {
          return ListView.builder(
            itemCount: state.calls.length,
            itemBuilder: (context, index) {
              final call = state.calls[index];
              return CallItem(call: call);
            },
          );
        } else if (state is CallError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
