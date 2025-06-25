import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:chat_app/core/config/index.dart';
import 'package:flutter/services.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({super.key, this.hasQr = false});
  final bool hasQr;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showQrDialog(BuildContext context, String url) {
    final state = BlocProvider.of<AuthBloc>(context).state;
    String? avatarUrl;
    String? username;
    if (state is AuthSuccess) {
      avatarUrl = state.user.profilePic;
      username = state.user.username;
    }
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (avatarUrl != null && avatarUrl.isNotEmpty)
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                  if (username != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: QrImageView(
                      data: url,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scan to view your profile',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        customSnackBar(
                          'Success',
                          'Copied link to clipboard!',
                          Icons.copy,
                          Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy Link'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

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
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return IconNoBorder(
                        icon: Icons.qr_code_scanner,
                        color: AppColors.secondary,
                        onTap: () {
                          if (state is AuthSuccess) {
                            final userId = state.user.id;
                            final url = '${Config.apiUrl}/profiles/get/$userId';
                            _showQrDialog(context, url);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You must be logged in to show QR.',
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ]
              : null,
    );
  }
}
