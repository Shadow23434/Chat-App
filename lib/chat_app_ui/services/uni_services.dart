import 'dart:developer';
import 'package:chat_app/chat_app_ui/services/context_utility.dart';
import 'package:chat_app/chat_app_ui/services/green.dart';
import 'package:chat_app/chat_app_ui/services/red.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

// Conditional import for web deep link handler
import 'package:chat_app/chat_app_ui/services/uni_services_stub.dart'
  if (dart.library.html) 'package:chat_app/chat_app_ui/services/uni_services_web.dart';

class UniServices {
  static String _code = '';
  static String get code => _code;
  static bool get hasCode => _code.isNotEmpty;

  static void reset() => _code = '';

  static init() async {
    if (kIsWeb) {
      handleWebDeepLink(uniHandler);
      return;
    }
    try {
      final Uri? uri = await getInitialUri();
      uniHandler(uri);
    } on PlatformException {
      log('Failed to receive the code');
    } on FormatException {
      log('Failed to receive the code');
    }
    uriLinkStream.listen(
      (Uri? uri) async {
        uniHandler(uri);
      },
      onError: (error) {
        log('OnUriLink Error: $error');
      },
    );
  }

  static uniHandler(Uri? uri) {
    if (uri == null || uri.queryParameters.isEmpty) return;

    Map<String, dynamic> param = uri.queryParameters;
    String receivedCode = param['code'] ?? '';

    if (receivedCode == 'green') {
      Navigator.push(
        ContextUtility.context!,
        MaterialPageRoute(builder: (_) => GreenScreen()),
      );
    } else {
      Navigator.push(
        ContextUtility.context!,
        MaterialPageRoute(builder: (_) => RedScreen()),
      );
    }
  }
}
