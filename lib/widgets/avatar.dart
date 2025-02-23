import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/app.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.url, this.onTap, required this.radius});

  const Avatar.small({
    super.key, this.url, this.onTap
  }) : radius = 18;

  const Avatar.medium({
    super.key, this.url, this.onTap
  }) : radius = 26;

  const Avatar.large({
    super.key, this.url, this.onTap
  }) : radius = 34;

  final String? url;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _avatar(context),
    );
  }

  Widget _avatar(BuildContext context) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(url ?? defaultAvatarUrl),
        backgroundColor: Theme.of(context).cardColor,
      );
  }
}
