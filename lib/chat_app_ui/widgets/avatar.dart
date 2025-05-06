import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/chat_app_ui/utils/app.dart';
import 'package:chat_app/chat_app_ui/widgets/icon_buttons.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.url,
    this.onTap,
    required this.radius,
    this.isEdited = false,
  });

  const Avatar.small({super.key, this.url, this.onTap, this.isEdited = false})
    : radius = 18;

  const Avatar.medium({super.key, this.url, this.onTap, this.isEdited = false})
    : radius = 26;

  const Avatar.large({super.key, this.url, this.onTap, this.isEdited = false})
    : radius = 34;

  final String? url;
  final VoidCallback? onTap;
  final double radius;
  final bool isEdited;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: _avatar(context));
  }

  Widget _avatar(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: CachedNetworkImageProvider(url ?? defaultAvatarUrl),
      backgroundColor: Theme.of(context).cardColor,
      child:
          isEdited
              ? Align(
                alignment: Alignment.bottomRight,
                child: IconBackGround(
                  icon: Icons.border_color_outlined,
                  size: 18,
                  onTap: onTap,
                  circularBorder: true,
                ),
              )
              : null,
    );
  }
}
