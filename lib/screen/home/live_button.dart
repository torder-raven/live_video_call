import 'package:flutter/material.dart';

import '../../constant/strings.dart';

class LiveButton extends StatelessWidget {
  const LiveButton({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[300]!,
            blurRadius: 12.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam,
              color: Colors.white,
              size: 40.0,
            ),
            const SizedBox(
              width: 12.0,
            ),
            Text(
              Strings.LIVE_TEXT,
              style: textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
