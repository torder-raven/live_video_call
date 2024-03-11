import 'package:flutter/material.dart';
import 'package:live_video_call/screen/home_screen.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: "NotoSans"
      ),
      home: HomeScreen(),
    ),
  );
}
