import 'package:flutter/material.dart';
import 'package:live_video_call/screen/home_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "NotoSans"),
      home: HomeScreen(),
    ),
  );
}
