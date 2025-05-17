import 'dart:async';
import 'package:chat_app/admin_panel_ui/admin.dart';
import 'package:chat_app/chat_app_ui/app.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:chat_app/core/navigation/web_navigation.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';

/// Widget that switches between admin and client apps based on URL
class AppSwitcher extends StatefulWidget {
  final AppTheme appTheme;
  final AuthRepository authRepository;

  const AppSwitcher({
    super.key,
    required this.appTheme,
    required this.authRepository,
  });

  @override
  State<AppSwitcher> createState() => _AppSwitcherState();
}

class _AppSwitcherState extends State<AppSwitcher> {
  bool isAdminRoute = false;
  Timer? _routeCheckTimer;
  String? _lastPath;

  @override
  void initState() {
    super.initState();
    _checkCurrentRoute();

    _routeCheckTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      _checkCurrentRoute();
    });
  }

  @override
  void dispose() {
    _routeCheckTimer?.cancel();
    super.dispose();
  }

  void _checkCurrentRoute() {
    final currentPath = WebNavigation.getCurrentPath();

    if (_lastPath != currentPath) {
      _lastPath = currentPath;
      print('URL CHANGED TO: $currentPath');

      setState(() {
        isAdminRoute = WebNavigation.isAdminRoute();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isAdminRoute) {
      return Admin(appTheme: widget.appTheme);
    } else {
      return MyApp(
        appTheme: widget.appTheme,
        authRepository: widget.authRepository,
      );
    }
  }
}
