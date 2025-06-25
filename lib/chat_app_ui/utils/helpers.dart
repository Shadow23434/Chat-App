import 'dart:math';
import 'package:chat_app/chat_app_ui/features/auth/data/models/user_model.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';

abstract class Helpers {
  static final random = Random();

  static String randomPictureUrl() {
    final randomInt = random.nextInt(1000);
    return 'https://picsum.photos/seed/$randomInt/300/300';
  }

  static DateTime randomDate() {
    final random = Random();
    final currentDate = DateTime.now();
    return currentDate.subtract(Duration(seconds: random.nextInt(200000)));
  }

  static String formatTimer(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  static String? nameInputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot be empty!';
    }
    return null;
  }

  static String? emailInputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot be empty!';
    }
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? passwordInputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot be empty!';
    }
    if (value.length < 8) {
      return 'Must be at least 8 characters';
    }
    return null;
  }

  static List<UserModel> users = [];
  static UserModel? getUserById(String userId) {
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Get current user ID from AuthBloc
  /// Returns null if user is not logged in
  static String? getCurrentUserId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      return authState.user.id;
    }
    return null;
  }

  /// Get current user from AuthBloc
  /// Returns null if user is not logged in
  static UserEntity? getCurrentUser(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      return authState.user;
    }
    return null;
  }

  /// Format time ago in a human-readable format
  /// Examples: 5s, 2m, 1h, 3d, 2w, 6mo, 1y
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo';
    } else {
      return '${(difference.inDays / 365).floor()}y';
    }
  }

  /// Format time ago with more detailed text
  /// Examples: "5 seconds ago", "2 minutes ago", "1 hour ago"
  static String formatTimeAgoDetailed(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} second${difference.inSeconds == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }
}
