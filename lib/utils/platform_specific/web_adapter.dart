// This file provides safe web functionality across platforms
// It uses conditional imports based on the platform

// Import the correct implementation based on platform
import 'web_adapter_stub.dart'
    if (dart.library.html) 'web_adapter_web.dart';

// Platform-neutral API
class WebAdapter {
  // Redirect to a URL
  static void redirect(String url) {
    redirectImpl(url);
  }

  // Get the current URL path
  static String getCurrentPath() {
    return getCurrentPathImpl();
  }

  // Update URL without reloading the page
  static void updateUrlWithoutReload(String path) {
    updateUrlWithoutReloadImpl(path);
  }
} 