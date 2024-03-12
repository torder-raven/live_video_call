import 'package:flutter/material.dart';
import 'package:live_video_call/constant/theme.dart';
import 'package:live_video_call/screen/home/home_screen.dart';

void main() {
  runApp(
    MaterialApp(
      home: const HomeScreen(),
      theme: homeTheme,
    ),
  );
}
