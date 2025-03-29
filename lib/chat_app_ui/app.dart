import 'package:chat_app/admin_panel_ui/models/users.dart';
import 'package:logger/logger.dart' as log;

final String defaultAvatarUrl = 'https://randomuser.me/api/portraits/men/1.jpg';

var logger = log.Logger();
// static final _emailRegex = RegExp(
//   r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
// );
final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

User currentUser = users.first;
// extension StreamChatContext on BuildContext {
//   String? get currentUserImage => currentUser?.image ?? defaultAvatarUrl;
//   User? get currentUser => StreamChatCore.of(this).currentUser;
// }
