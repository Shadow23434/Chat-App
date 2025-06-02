import 'package:chat_app/core/config/api_config.dart';

class Config {
  // API Configuration
  static String get apiUrl => ApiConfig.baseUrl;
  static const int apiTimeout = ApiConfig.timeout;
  static const Map<String, String> apiHeaders = ApiConfig.headers;

  // Asset Configuration
  static const String defaultProfilePic = 'assets/images/default_profile.png';
  static const String defaultGroupPic = 'assets/images/default_group.png';
  static const String defaultMessagePic = 'assets/images/default_message.png';
  static const String defaultErrorPic = 'assets/images/error.png';
  static const String defaultLoadingPic = 'assets/images/loading.gif';

  // Cache Configuration
  static const int cacheDuration = 7 * 24 * 60 * 60; // 7 days in seconds
  static const String cachePrefix = 'chat_app_';
  static const String userCacheKey = 'user_data';
  static const String settingsCacheKey = 'app_settings';
  static const String themeCacheKey = 'app_theme';

  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minPageSize = 10;

  // Message Configuration
  static const int maxMessageLength = 1000;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const int messageRetryCount = 3;
  static const int messageRetryDelay = 1000; // 1 second

  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultIconSize = 24.0;
  static const double defaultAvatarSize = 40.0;
  static const double defaultMessageBubbleWidth = 0.7; // 70% of screen width
  static const int defaultAnimationDuration = 300; // milliseconds

  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error':
        'Network connection error. Please check your internet connection.',
    'server_error': 'Server error. Please try again later.',
    'timeout_error': 'Request timeout. Please try again.',
    'auth_error': 'Authentication error. Please login again.',
    'permission_error': 'Permission denied. Please check your access rights.',
    'validation_error': 'Invalid input. Please check your data.',
    'not_found_error': 'Resource not found.',
    'unknown_error': 'An unknown error occurred. Please try again.',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'message_sent': 'Message sent successfully.',
    'message_deleted': 'Message deleted successfully.',
    'chat_deleted': 'Chat deleted successfully.',
    'profile_updated': 'Profile updated successfully.',
    'settings_updated': 'Settings updated successfully.',
    'login_success': 'Login successful.',
    'logout_success': 'Logout successful.',
  };
}
