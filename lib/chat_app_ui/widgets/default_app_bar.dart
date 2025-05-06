import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({super.key, this.hasQr = false});
  final bool hasQr;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 54,
      leading: Align(
        alignment: Alignment.centerRight,
        child: IconNoBorder(
          icon: Icons.arrow_back_ios_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      actions:
          hasQr
              ? [
                Padding(
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  child: IconNoBorder(
                    icon: Icons.qr_code_scanner,
                    color: AppColors.secondary,
                    onTap: () {},
                  ),
                ),
              ]
              : null,
    );
  }
}
