import 'package:flutter/material.dart';
import 'package:live_video_call/constant/strings.dart';

class EntryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EntryButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
      child: Text(
        Strings.LIVE_ENTRY_TEXT,
        style: textTheme.titleMedium,
      ),
    );
  }
}
