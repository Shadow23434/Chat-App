import 'package:chat_app/admin_panel_ui/admin.dart';
import 'package:chat_app/chat_app_ui/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chat_app/chat_app_ui/services/uni_services.dart';
import 'package:chat_app/core/app_switcher/app_switcher.dart';
import 'package:chat_app/core/navigation/web_navigation.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Main entry point for the application
Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  UniServices.init();

  final authRepository = AuthRepositoryImpl(
    authRemoteDataSource: AuthRemoteDataSource(),
  );

  final currentUrl = WebNavigation.getCurrentPath();
  print('BROWSER URL PATH: $currentUrl');

  if (currentUrl.contains('admin')) {
    print('LOADING ADMIN APP');
    runApp(Admin(appTheme: AppTheme()));
  } else {
    print('LOADING CLIENT APP');
    runApp(AppSwitcher(appTheme: AppTheme(), authRepository: authRepository));
  }
}
