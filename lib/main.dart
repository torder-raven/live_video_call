import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:live_video_call/constant/constants.dart';
import 'package:live_video_call/constant/theme.dart';
import 'package:live_video_call/screen/home/home_screen.dart';

void main() async {
  await dotenv.load(fileName: Constants.ENV_FILE_NAME);

  runApp(
    MaterialApp(
      home: const HomeScreen(),
      theme: homeTheme,
    ),
  );
}
