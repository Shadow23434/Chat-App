import 'package:chat_app/admin_panel_ui/admin.dart';
import 'package:chat_app/chat_app_ui/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chat_app/chat_app_ui/services/uni_services.dart';
import 'package:chat_app/core/app_switcher/app_switcher.dart';
import 'package:chat_app/core/navigation/web_navigation.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/theme/theme_notifier.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  UniServices.init();

  final authRepository = AuthRepositoryImpl(
    authRemoteDataSource: AuthRemoteDataSource(),
  );

  final currentUrl = WebNavigation.getCurrentPath();
  if (currentUrl.contains('admin')) {
    runApp(Admin(appTheme: AppTheme()));
  } else {
    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: AppSwitcher(
          appTheme: AppTheme(),
          authRepository: authRepository,
        ),
      ),
    );
  }
}
