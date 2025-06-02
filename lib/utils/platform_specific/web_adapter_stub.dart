// Stub implementation for non-web platforms

// Redirect to a URL (no-op on non-web)
void redirectImpl(String url) {
  print('URL redirection not supported on this platform: $url');
}

// Get current path (returns default on non-web)
String getCurrentPathImpl() {
  return '/';
}

// Update URL without reload (no-op on non-web)
void updateUrlWithoutReloadImpl(String path) {
  print('URL updating not supported on this platform: $path');
} 