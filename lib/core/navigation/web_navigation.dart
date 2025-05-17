import 'package:web/web.dart' hide Text;

/// Web navigation utilities for direct URL manipulation
class WebNavigation {
  /// Navigate to the admin panel
  static void navigateToAdmin() {
    window.location.href = '/admin';
  }

  /// Navigate to the client app
  static void navigateToClient() {
    window.location.href = '/';
  }

  /// Get the current path from the browser URL
  static String getCurrentPath() {
    return window.location.pathname ?? '/';
  }

  /// Check if the current path is for the admin panel
  static bool isAdminRoute() {
    final path = getCurrentPath();
    return path.contains('admin');
  }

  /// Update the URL without reloading the page
  static void updateUrlWithoutReload(String path) {
    // Use history API to change URL without page reload
    window.history.pushState(null, '', path);
  }
}
