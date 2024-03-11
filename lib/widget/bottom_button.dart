import 'package:flutter/material.dart';
import 'package:live_video_call/constant/strings.dart';

class BottomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BottomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
      child: Text(
        text,
        style: textTheme.titleMedium,
      ),
    );
  }
}
