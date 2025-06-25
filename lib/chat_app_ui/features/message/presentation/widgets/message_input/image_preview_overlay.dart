import 'dart:io';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewOverlay extends StatelessWidget {
  final XFile pickedImage;
  final VoidCallback onSend;
  final VoidCallback onRemove;
  final Future<void> Function() onPickAnother;
  final bool isSending;

  const ImagePreviewOverlay({
    super.key,
    required this.pickedImage,
    required this.onSend,
    required this.onRemove,
    required this.onPickAnother,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.4),
            child: SafeArea(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(
                    minWidth: 320,
                    minHeight: 320,
                    maxWidth: 500,
                    maxHeight: 500,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(pickedImage.path),
                          width: 280,
                          height: 280,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (isSending)
                        Container(
                          width: 280,
                          height: 280,
                          color: Colors.black.withOpacity(0.4),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pick another image button
                            Material(
                              color: Colors.white,
                              elevation: 6,
                              shape: const CircleBorder(),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.image_search,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                                tooltip: 'Pick another image',
                                onPressed: isSending ? null : onPickAnother,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Send image button
                            Material(
                              color: AppColors.secondary,
                              elevation: 8,
                              shape: const CircleBorder(),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                tooltip: 'Send image',
                                onPressed: isSending ? null : onSend,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Remove image button
                            Material(
                              color: Colors.white,
                              elevation: 6,
                              shape: const CircleBorder(),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 28,
                                ),
                                tooltip: 'Remove image',
                                onPressed: isSending ? null : onRemove,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
