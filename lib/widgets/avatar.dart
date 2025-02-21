import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/app.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({Key? key, this.url, this.onTap, required this.radius})
  : super(key: key);

  const Avatar.small({
    Key? key, this.url, this.onTap
  }) : radius = 18, super(key: key);

  const Avatar.medium({
    Key? key, this.url, this.onTap
  }) : radius = 26, super(key: key);

  const Avatar.large({
    Key? key, this.url, this.onTap
  }) : radius = 34, super(key: key);

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
