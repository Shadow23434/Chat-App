import 'package:chat_app/utils/platform_specific/web_adapter.dart';

/// Web navigation utilities for direct URL manipulation
class WebNavigation {
  /// Navigate to the admin panel
  static void navigateToAdmin() {
    WebAdapter.redirect('/admin');
  }

  /// Navigate to the client app
  static void navigateToClient() {
    WebAdapter.redirect('/');
  }

  /// Get the current path from the browser URL
  static String getCurrentPath() {
    return WebAdapter.getCurrentPath();
  }

  /// Check if the current path is for the admin panel
  static bool isAdminRoute() {
    final path = getCurrentPath();
    return path.contains('admin');
  }

  /// Update the URL without reloading the page
  static void updateUrlWithoutReload(String path) {
    // Use history API to change URL without page reload
    WebAdapter.updateUrlWithoutReload(path);
  }
}
