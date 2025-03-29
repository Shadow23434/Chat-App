import 'package:flutter/material.dart';

class EditAvatarDialog extends StatelessWidget {
  const EditAvatarDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(content: Center(child: Text('Open image library!')));
  }
}
