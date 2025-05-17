import 'dart:html' as html;

void handleWebDeepLink(Function(Uri) uniHandler) {
  final uri = Uri.parse(html.window.location.href);
  uniHandler(uri);
}
