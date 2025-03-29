import 'dart:math';
import 'package:chat_app/admin_panel_ui/models/users.dart' as admin;
import 'app.dart';

abstract class Helpers {
  static final random = Random();

  static String randomPictureUrl() {
    final randomInt = random.nextInt(1000);
    return 'https://picsum.photos/seed/$randomInt/300/300';
  }

  static DateTime randomDate() {
    final random = Random();
    final currentDate = DateTime.now();
    return currentDate.subtract(Duration(seconds: random.nextInt(200000)));
  }

  static String formatTimer(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  // static String getChannelName(Channel channel, admin.User currentUser) {
  //   if (channel.name != null) {
  //     return channel.name!;
  //   } else if (channel.state?.members.isNotEmpty ?? false) {
  //     final otherMembers =
  //         channel.state?.members
  //             .where((element) => element.userId != currentUser.id)
  //             .toList();
  //     if (otherMembers?.length == 1) {
  //       return otherMembers!.first.user?.name ?? 'Unknown';
  //     } else {
  //       return 'Multiple Users';
  //     }
  //   } else {
  //     return 'No Channel Name';
  //   }
  // }

  // static String? getChannelImage(Channel channel, admin.User currentUser) {
  //   if (channel.image != null) {
  //     return channel.image!;
  //   } else if (channel.state?.members.isNotEmpty ?? false) {
  //     final otherMembers =
  //         channel.state?.members
  //             .where((element) => element.userId != currentUser.id)
  //             .toList();
  //     if (otherMembers?.length == 1) {
  //       return otherMembers!.first.user?.image;
  //     }
  //   } else {
  //     return null;
  //   }
  //   return null;
  // }

  static String? nameInputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot be empty!';
    }
    return null;
  }

  static String? emailInputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot be empty!';
    }
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? passwordInputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot be empty!';
    }
    if (value.length < 8) {
      return 'Must be at least 8 characters';
    }
    return null;
  }

  static admin.User? getUserById(String userId) {
    try {
      return admin.users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }
}
