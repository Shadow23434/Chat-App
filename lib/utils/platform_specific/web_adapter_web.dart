// Web implementation using dart:html
import 'dart:html' as html;

// Redirect to a URL
void redirectImpl(String url) {
  html.window.location.href = url;
}

// Get current path
String getCurrentPathImpl() {
  return html.window.location.pathname ?? '/';
}

// Update URL without reload
void updateUrlWithoutReloadImpl(String path) {
  html.window.history.pushState(null, '', path);
} 