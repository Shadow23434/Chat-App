import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as log;
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

final String defaultAvatarUrl =
    'https://th.bing.com/th/id/OIP.e58VxFID01mZce1rP78E6AHaHa?w=167&h=180&c=7&r=0&o=5&pid=1.7';

var logger = log.Logger();
// static final _emailRegex = RegExp(
//   r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
// );
final emailRegex = RegExp(r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$");

// Extensions can be used to add functionality to the SDK.
extension StreamChatContext on BuildContext {
  // Fetches the current user image.
  String? get currentUserImage => currentUser?.image ?? defaultAvatarUrl;
  // Fetches the current user.
  User? get currentUser => StreamChatCore.of(this).currentUser;
}
