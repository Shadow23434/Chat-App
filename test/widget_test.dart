// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:chat_app/chat_app_ui/app.dart';
import 'package:chat_app/chat_app_ui/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chat_app/core/app_switcher/app_switcher.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final authRepository = AuthRepositoryImpl(
      authRemoteDataSource: AuthRemoteDataSource(),
    );
    await tester.pumpWidget(
      AppSwitcher(appTheme: AppTheme(), authRepository: authRepository),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
